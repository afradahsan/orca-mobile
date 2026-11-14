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
import 'package:orca/features/fitness/presentations/fitness_guide.dart';
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
        return "Chest";
      case DateTime.tuesday:
        return "Back";
      case DateTime.wednesday:
        return "Legs";
      case DateTime.thursday:
        return "Shoulders";
      case DateTime.friday:
        return "Arms";
      case DateTime.saturday:
        return "Core";
      case DateTime.sunday:
      default:
        return "Full Body";
    }
  }

  List<Map<String, dynamic>> toWorkoutDetailsList(List<Exercise> list) {
    return list.map((ex) {
      return {
        "title": ex.name,
        "name": ex.name,
        "description": ex.description ?? "Follow proper form and control breathing throughout the movement.",
        "imageUrl": ex.imageUrl ?? "",
        "difficulty": ex.difficulty,
        "category": ex.category,
        "equipment": ex.equipment,
        "targetMuscles": ex.targetMuscles,
        "sets": ex.sets,
        "reps": ex.reps,
        "restTime": ex.restTime,
        "duration": ex.duration,
        "caloriesBurned": ex.caloriesBurned ?? 0,
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
        return "Push power & upper strength";
      case "Back":
        return "Pull strength & posture";
      case "Legs":
        return "Power • stability • stamina";
      case "Shoulders":
        return "Shape • control • overhead power";
      case "Arms":
        return "Pump • definition • volume";
      case "Core":
        return "Balance • trunk control • endurance";
      default:
        return "Move better • full body vitality";
    }
  }

  List<Exercise> _filterByFocus(String focus) {
    final f = focus.toLowerCase();
    final chips = _getFocusChips(focus).map((c) => c.toLowerCase()).toList();

    final matches = allExercises.where((ex) {
      final name = ex.name.toLowerCase();
      final category = ex.category.toLowerCase();

      // 1. Direct targetMuscles check (most accurate)
      if (ex.targetMuscles.any((m) {
        final lowerM = m.toLowerCase();
        return lowerM.contains(f) || chips.any((c) => lowerM.contains(c));
      })) {
        return true;
      }

      // 2. Direct name match
      if (name.contains(f) || chips.any((c) => name.contains(c))) {
        return true;
      }

      // 3. Category match
      if (category.contains(f) || chips.any((c) => category.contains(c))) {
        return true;
      }

      // 4. Equipment match fallback
      if (ex.equipment.any((eq) => eq.toLowerCase().contains(f))) {
        return true;
      }

      return false;
    }).toList();

    // Fallback: if backend hasn't tagged specific exercises with this focus, return first 5 exercises so user always has workouts to do
    if (matches.isEmpty && allExercises.isNotEmpty) {
      return allExercises.take(5).toList();
    }

    return matches;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Challenge? weeklyChallenge = challenges.isNotEmpty ? challenges.first : null;
    final double challengeProgress = (weeklyChallenge == null || weeklyChallenge.target == 0)
        ? 0.0
        : (weeklyChallenge.progress / weeklyChallenge.target).clamp(0.0, 1.0);

    final todayFocus = _getTodayFocus();
    final todayChips = _getFocusChips(todayFocus);
    final todayExercises = _filterByFocus(todayFocus);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final String rawName = auth.userName?.trim() ?? '';
    final String athleteName = rawName.isNotEmpty ? rawName.split(' ').first : 'Athlete';

    debugPrint("Today's focus: $todayFocus with ${todayExercises.length} exercises");

    return Scaffold(
      backgroundColor: darkgreen,
      floatingActionButton: FloatingActionButton(
        backgroundColor: green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WorkoutLogPage(),
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
                        Text('Hey $athleteName!',
                            style: TextStyle(color: white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                        Text('Ready to Grind?',
                            style: TextStyle(
                                color: green,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic)),
                        sizedten(context),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Workout History",
                          icon: Icon(Icons.history_rounded, color: Colors.white70, size: 20.sp),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const WorkoutHistoryPage(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(isSearching ? Icons.close : Icons.search_rounded,
                              color: Colors.white, size: 20.sp),
                          onPressed: () {
                            setState(() {
                              isSearching = !isSearching;
                              if (!isSearching) {
                                exercises = allExercises;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (isSearching)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.sp),
                    child: TextField(
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      onChanged: _filterExercises,
                      decoration: InputDecoration(
                        hintText: "Search workouts...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                        filled: true,
                        fillColor: surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: surfaceBorder),
                        ),
                      ),
                    ),
                  ),
                sizedten(context),
                dailyTracker(),

                // Weekly Challenge Section
                if (loadingChallenges)
                  Padding(
                    padding: EdgeInsets.only(top: 14.sp),
                    child: challengeShimmer(),
                  )
                else if (weeklyChallenge != null)
                  Padding(
                    padding: EdgeInsets.only(top: 14.sp),
                    child: _buildWeeklyChallengeCard(weeklyChallenge, challengeProgress),
                  ),

                SizedBox(height: 14.sp),
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
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        surfaceDark,
                        Color(0xFF0E0E0E),
                      ],
                    ),
                    border: Border.all(color: surfaceBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: green.withValues(alpha: 0.08),
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
                                    color: green,
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
                              color: Colors.black.withValues(alpha: 0.25),
                              border: Border.all(color: surfaceBorder),
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
                              color: Colors.black.withValues(alpha: 0.2),
                              border: Border.all(color: surfaceBorder),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fitness Guides & Tips',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FitnessGuidePage(),
                        ));
                      },
                      child: Text('View All',
                          style: TextStyle(color: green, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 12.sp),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FitnessGuidePage(),
                    ));
                  },
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: surfaceBorder, width: 1.2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/challenge.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.92),
                                    Colors.black.withValues(alpha: 0.25),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10.sp,
                            right: 10.sp,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: green.withValues(alpha: 0.6)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bookmark_rounded, color: green, size: 14.sp),
                                  SizedBox(width: 3.sp),
                                  Text(
                                    guide.duration,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12.sp,
                            left: 12.sp,
                            right: 12.sp,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2.5.sp),
                                  decoration: BoxDecoration(
                                    color: green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    guide.category.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.sp),
                                Text(
                                  guide.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
        color: surfaceDark,
        border: Border.all(color: surfaceBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(days.length, (index) {
          Color borderColor;
          Color fillColor;
          Color textColor;

          switch (status[index]) {
            case 3: // Completed
              borderColor = green.withAlpha(200);
              fillColor = green.withAlpha(35);
              textColor = Colors.white;
              break;
            case 2: // Missed
              borderColor = Colors.redAccent;
              fillColor = Colors.transparent;
              textColor = Colors.white;
              break;
            case 1: // Active (today)
              borderColor = green;
              fillColor = green;
              textColor = Colors.black;
              break;
            default: // Upcoming
              borderColor = surfaceBorder;
              fillColor = Colors.transparent;
              textColor = Colors.white38;
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

  Widget _buildWeeklyChallengeCard(Challenge challenge, double progress) {
    final int target = challenge.target > 0 ? challenge.target : challenge.exerciseIds.length;
    final int current = challenge.progress;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: surfaceBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt_rounded, color: green, size: 18.sp),
                  SizedBox(width: 4.sp),
                  Text(
                    'WEEKLY CHALLENGE',
                    style: TextStyle(
                      color: green,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 3.sp),
                decoration: BoxDecoration(
                  color: green.withAlpha(35),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: green.withAlpha(80)),
                ),
                child: Text(
                  challenge.difficulty.toUpperCase(),
                  style: TextStyle(
                    color: green,
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.sp),
          Text(
            challenge.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (challenge.description != null && challenge.description!.isNotEmpty) ...[
            SizedBox(height: 3.sp),
            Text(
              challenge.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
              ),
            ),
          ],
          SizedBox(height: 10.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: $current / $target workouts',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: green,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.sp),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFF262626),
              valueColor: const AlwaysStoppedAnimation<Color>(green),
            ),
          ),
          SizedBox(height: 10.sp),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WeeklyChallenge(challenge: challenge),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Challenge Details',
                        style: TextStyle(
                          color: green,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2.sp),
                      Icon(Icons.arrow_forward_rounded, color: green, size: 13.sp),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Exercise ex) {
    final imagePath = ex.imageUrl ?? "assets/images/gym.png";

    return GestureDetector(
      onTap: () async {
        // Build the map with complete fields for WorkoutDetailsPage
        final exerciseMap = {
          'title': ex.name,
          'imageUrl': imagePath,
          'category': ex.category,
          'difficulty': ex.difficulty,
          'equipment': ex.equipment,
          'targetMuscles': ex.targetMuscles,
          'sets': ex.sets,
          'reps': ex.reps,
          'restTime': ex.restTime,
          'duration': ex.duration,
          'caloriesBurned': ex.caloriesBurned ?? 0,
        };

        final completed = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkoutDetailsPage(
              exercises: [exerciseMap],
            ),
          ),
        );

        if (completed == true && mounted) {
          fetchAllExercises();
          fetchChallenges();
        }
      },
      child: Container(
        width: 53.sp,
        height: 52.sp,
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: surfaceBorder, width: 1),
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
                  color: green,
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
                  const Icon(Icons.access_time, color: green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${ex.duration} Min",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.local_fire_department, color: green, size: 16.sp),
                  const SizedBox(width: 4),
                  Text(
                    "${ex.caloriesBurned ?? 0} Kcal",
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
