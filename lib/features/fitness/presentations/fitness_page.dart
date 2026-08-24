import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/fitness/data/challenge_services.dart';
import 'package:orca/features/fitness/data/exercise_service.dart';
import 'package:orca/features/fitness/domain/challenge_model.dart';
import 'package:orca/features/fitness/domain/exercise_model.dart';
import 'package:orca/features/fitness/domain/guide_model.dart';
import 'package:orca/features/fitness/presentations/all_workouts.dart';
import 'package:orca/features/fitness/presentations/weekly_challenge.dart';
import 'package:orca/features/fitness/presentations/wokout_history.dart';
import 'package:orca/features/fitness/presentations/workout_details.dart';
import 'package:orca/features/fitness/presentations/workout_log.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class FitnessPage extends StatefulWidget {
  const FitnessPage({super.key, this.token});

  final String? token;

  @override
  State<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage> with AutomaticKeepAliveClientMixin {
  int selectedIndex = 1;

  // String _challengeStageText(Challenge c) {
  //   final int p = c.progress;
  //   if (p == 0) return "Stage: Onboarding";
  //   if (p == 1) return "Stage: Momentum";
  //   if (p == 2) return "Stage: Consistent";
  //   if (p == 3) return "Stage: Strong";
  //   if (p >= c.target) return "Stage: Complete";
  //   return "Stage: Progressing";
  // }

  List<Exercise> exercises = [];
  bool _isLoading = true;
  final ExerciseService _exerciseService = ExerciseService();

  List<Exercise> allExercises = [];
  bool isSearching = false;
  String searchQuery = "";

  List<Challenge> challenges = [];
  bool loadingChallenges = true;
  bool _dataLoaded = false;
  final ChallengeService _challengeService = ChallengeService();

  final Guide guide = Guide(
    id: "g1",
    title: "Calisthenics Workout!",
    category: "Workout",
    duration: "10 Min",
    pdfUrl: "https://example.com/guide.pdf",
  );

  late Challenge weeklyChallenge;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    if (!_dataLoaded) {
      fetchAllExercises();
      fetchChallenges();
      _dataLoaded = true;
    }

    // weeklyChallenge = Challenge(
    //   id: "c1",
    //   title: "Weekly Fat Burn",
    //   description: "Burn fat and stay active for the week",
    //   difficulty: "Beginner",
    //   durationDays: 7,
    //   startDate: DateTime(2025, 09, 11),
    //   endDate: DateTime(2025, 09, 18),
    //   exerciseIds: ["1", "2"],
    //   isActive: true,
    //   progress: 3,
    //   target: 5,
    // );
  }

  Future<void> fetchChallenges() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.loadAuthData();

      final String token = auth.token ?? '';
      if (token.isEmpty) {
        setState(() => loadingChallenges = false);
        return;
      }

      final fetched = await _challengeService.getChallenges(token);

      setState(() {
        challenges = fetched;
        loadingChallenges = false;
      });

      debugPrint("Fetched ${challenges.length} challenges");
    } catch (e) {
      debugPrint("Challenge Load Error: $e");
      setState(() => loadingChallenges = false);
    }
  }

  Widget workoutShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade600,
      child: Container(
        width: 51.sp,
        height: 52.sp,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget challengeShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade600,
      child: Container(
        width: 160.sp,
        height: 52.sp,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _filterExercises(String query) {
    if (query.isEmpty) {
      setState(() {
        exercises = allExercises;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();

    setState(() {
      exercises = allExercises.where((ex) {
        return ex.name.toLowerCase().contains(lowerQuery) || (ex.equipment?.join(",").toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    });

    debugPrint("🔎 filtered: ${exercises.length}");
  }

  Future<void> fetchAllExercises() async {
    try {
      debugPrint("Fetching exercises...");

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.loadAuthData();

      final String token = auth.token ?? '';
      if (token.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final exercisesList = await _exerciseService.fetchExercises(token);
      debugPrint('${exercisesList.length} exercises fetched.');
      setState(() {
        debugPrint('ex: $exercisesList');
        allExercises = exercisesList;
        exercises = exercisesList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("exercise Load Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void onIconTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  String _getTodayFocus() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return "Legs";
      case DateTime.tuesday:
        return "Back";
      case DateTime.wednesday:
        return "Shoulders";
      case DateTime.thursday:
        return "Chest";
      case DateTime.friday:
        return "Arms";
      case DateTime.saturday:
        return "Chest";
      case DateTime.sunday:
      default:
        return "Full Body";
    }
  }

  List<Exercise> getTodayRoutine() {
    final day = DateTime.now().weekday;

    String focus = "legs";

    if (day == 1) focus = "chest";
    if (day == 2) focus = "back";
    if (day == 3) focus = "legs";
    if (day == 4) focus = "shoulders";
    if (day == 5) focus = "arms";
    if (day == 6) focus = "full";
    if (day == 7) focus = "core";

    final filtered = _filterByFocus(focus);

    // ✅ return 1–5 exercises
    return filtered.take(5).toList();
  }

  List<Map<String, dynamic>> toWorkoutDetailsList(List<Exercise> list) {
    return list.map((ex) {
      return {
        "title": ex.name,
        "imageUrl": ex.imageUrl ?? "",
        "difficulty": ex.difficulty ?? "Beginner",
        "category": ex.category ?? "General",
        "equipment": ex.equipment ?? [],
        "targetMuscles": ex.targetMuscles ?? [],
        "sets": ex.sets ?? 0,
        "reps": ex.reps ?? 0,
        "restTime": ex.restTime ?? 30,
      };
    }).toList();
  }

  List<String> _getFocusChips(String focus) {
    switch (focus) {
      case "Chest":
        return ["Upper", "Mid", "Lower"];
      case "Back":
        return ["Lats", "Traps", "Rear Delts"];
      case "Legs":
        return ["Quads", "Glutes", "Hamstrings"];
      case "Shoulders":
        return ["Front", "Side", "Rear"];
      case "Arms":
        return ["Biceps", "Triceps", "Forearms"];
      case "Core":
        return ["Abs", "Obliques", "Lower Back"];
      default:
        return ["Strength", "Mobility", "Endurance"];
    }
  }

  String _getFocusSubtitle(String focus) {
    switch (focus) {
      case "Chest":
        return "Push power & strength";
      case "Back":
        return "Pull strength & posture";
      case "Legs":
        return "Power • stability • stamina";
      case "Shoulders":
        return "Shape • control • strength";
      case "Arms":
        return "Pump • definition • volume";
      case "Core":
        return "Balance • control • endurance";
      default:
        return "Move better • feel stronger";
    }
  }

  List<Exercise> _filterByFocus(String focus) {
    final f = focus.toLowerCase();

    return allExercises.where((ex) {
      final name = ex.name.toLowerCase();

      // Try matching by name first (works even without backend tags)
      if (name.contains(f)) return true;

      // If you later add muscleGroup or category
      final category = (ex.category ?? "").toLowerCase();
      if (category.contains(f)) return true;

      // equipment match fallback
      final eq = (ex.equipment?.join(",") ?? "").toLowerCase();
      if (eq.contains(f)) return true;

      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Challenge? weeklyChallenge = challenges.isNotEmpty ? challenges.first : null;
    final double challengeProgress = (weeklyChallenge == null || weeklyChallenge.target == 0) ? 0.0 : (weeklyChallenge.progress / weeklyChallenge.target).clamp(0.0, 1.0);

    final todayFocus = _getTodayFocus();
    final todayChips = _getFocusChips(todayFocus);
    final todayExercises = _filterByFocus(todayFocus);

    debugPrint("Today's focus: $todayFocus with ${todayExercises.length} exercises");

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutLogPage(),
            ),
          );
        },
        child: Icon(
          Icons.calendar_today_rounded,
          size: 18.sp,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 8.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sizedfive(context),
                        Text('Hey Afrad!', style: TextStyle(color: white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                        Text('Ready to Grind?', style: TextStyle(color: green, fontSize: 18.sp, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                        sizedten(context),
                      ],
                    ),
                    IconButton(
                      icon: Icon(isSearching ? Icons.close : Icons.search_rounded),
                      onPressed: () {
                        setState(() {
                          isSearching = !isSearching;
                          debugPrint("🔍 isSearching = $isSearching");

                          if (!isSearching) {
                            exercises = allExercises;
                          }
                        });
                      },
                    )
                  ],
                ),
                if (isSearching)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.sp),
                    child: TextField(
                      autofocus: true,
                      style: TextStyle(color: Colors.white),
                      onChanged: _filterExercises,
                      decoration: InputDecoration(
                        hintText: "Search workouts...",
                        hintStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(Icons.search, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                sizedten(context),
                dailyTracker(),
                sizedtwenty(context),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF181818),
                        Color(0xFF101010),
                      ],
                    ),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "This Week",
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(height: 4.sp),
                            Text(
                              "+12%",
                              style: TextStyle(
                                color: green,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.trending_up, color: green, size: 22.sp),
                    ],
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  "Today's Focus",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.sp),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A1A1A),
                        const Color(0xFF0E0E0E),
                      ],
                    ),
                    border: Border.all(color: Colors.grey.shade800, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: green.withOpacity(0.08),
                        blurRadius: 18,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  todayFocus.toUpperCase(),
                                  style: TextStyle(
                                    color: const Color(0xFFD6FF00),
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: GoogleFonts.bebasNeue().fontFamily,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: 6.sp),
                                Text(
                                  _getFocusSubtitle(todayFocus),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.black.withOpacity(0.25),
                              border: Border.all(color: Colors.grey.shade800),
                            ),
                            child: Text(
                              "${todayExercises.length} workouts",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.sp),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: todayChips.map((chip) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.black.withOpacity(0.2),
                              border: Border.all(color: Colors.grey.shade800),
                            ),
                            child: Text(
                              chip,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 14.sp),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AllWorkouts(
                                filter: todayFocus,
                                exercises: toWorkoutDetailsList(todayExercises),
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Start Workout",
                              style: TextStyle(
                                color: green,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_right, size: 20.sp, color: green),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                sizedtwenty(context),
                Text('Workouts for you!', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                sizedten(context),
                _isLoading
                    ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(3, (_) => workoutShimmer())))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: exercises.take(5).map((ex) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: _buildWorkoutCard(ex),
                            );
                          }).toList(),
                        ),
                      ),
                // sizedten(context),
                // Text('Workout Log', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                // Text(
                //   "Track today's strength",
                //   style: TextStyle(
                //     color: Colors.greenAccent.withOpacity(0.8),
                //     fontSize: 12.sp,
                //     fontStyle: FontStyle.italic,
                //   ),
                // ),
                // SizedBox(height: 12.sp),
                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => WorkoutLogPage(),
                //       ),
                //     );
                //   },
                //   child: Container(
                //     height: 57.sp,
                //     width: double.infinity,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(16),
                //       gradient: LinearGradient(
                //         colors: [
                //           Color(0xFF1A1A1A),
                //           Color(0xFF0E0E0E),
                //         ],
                //       ),
                //       border: Border.all(color: Colors.grey.shade800),
                //     ),
                //     child: Padding(
                //       padding: EdgeInsets.all(14.sp),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.end,
                //         children: [
                //           Text(
                //             "Bench Press Logged",
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 16.sp,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //           SizedBox(height: 8.sp),
                //           Text(
                //             "3 sets • 12 reps • 60kg",
                //             style: TextStyle(
                //               color: Colors.white70,
                //               fontSize: 13.sp,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                sizedtwenty(context),
                Text('Fitness Guide', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.sp),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WorkoutHistoryPage(),
                    ));
                  },
                  child: Container(
                    width: 48.sp,
                    height: 54.sp,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/challenge.png',
                            width: double.infinity,
                            height: 48.sp,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(Icons.bookmark, color: green, size: 24),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Text(
                            guide.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dailyTracker() {
    final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    List<int> status = List.filled(7, 0);

    int today = DateTime.now().weekday; // 1-7
    int todayIndex = today - 1; // convert to 0–6 index

    for (int i = 0; i < days.length; i++) {
      if (i < todayIndex) {
        status[i] = 3; // completed
      } else if (i == todayIndex) {
        status[i] = 1; // active
      } else {
        status[i] = 0; // upcoming
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.sp),
        color: const Color(0xFF121212),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(days.length, (index) {
          Color borderColor;
          Color fillColor;
          Color textColor;

          switch (status[index]) {
            case 3: // Completed
              borderColor = const Color.fromARGB(255, 0, 255, 8);
              fillColor = Colors.transparent;
              textColor = Colors.white;
              break;
            case 2: // Missed
              borderColor = Colors.redAccent;
              fillColor = Colors.transparent;
              textColor = Colors.white;
              break;
            case 1: // Active (today)
              borderColor = Colors.white;
              fillColor = Colors.deepPurple;
              textColor = Colors.white;
              break;
            default: // Upcoming
              borderColor = Colors.grey.shade700;
              fillColor = Colors.transparent;
              textColor = Colors.white;
          }

          return Container(
            width: 24.sp,
            height: 24.sp,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
              color: fillColor,
            ),
            child: Text(
              days[index],
              style: TextStyle(
                color: textColor,
                fontFamily: GoogleFonts.bebasNeue().fontFamily,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWorkoutCard(Exercise ex) {
    final imagePath = ex.imageUrl ?? "assets/images/gym.png";

    return GestureDetector(
      onTap: () {
        // Build the map in the format WorkoutDetailsPage expects
        final exerciseMap = {
          'title': ex.name,
          'imageUrl': imagePath,
          // adapt these keys/fields to your Exercise model
          'equipment': ex.equipment ?? 'Bodyweight',
          // 'muscle': ex.muscleGroup ?? 'Full Body',
          // 'level': ex.level ?? 'Beginner',
        };

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkoutDetailsPage(
              // for now we pass a single-exercise list
              exercises: [exerciseMap],
            ),
          ),
        );
      },
      child: Container(
        width: 53.sp,
        height: 52.sp,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          width: 54.sp,
                          height: 40.sp,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/images/gym.png",
                              width: 54.sp,
                              height: 40.sp,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          "assets/images/gym.png",
                          width: 54.sp,
                          height: 40.sp,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 8.sp,
                  right: 10.sp,
                  child: Icon(
                    Icons.star_border_rounded,
                    color: green,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                ex.name,
                style: TextStyle(
                  color: const Color(0xFFD6FF00),
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.bebasNeue().fontFamily,
                  letterSpacing: 1,
                  fontSize: 16.sp,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.purple, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${ex.duration} Min",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.local_fire_department, color: Colors.purple, size: 16.sp),
                  const SizedBox(width: 4),
                  Text(
                    "${ex.caloriesBurned} Kcal",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
