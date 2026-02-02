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
import 'package:orca/features/fitness/presentations/workout_page.dart';
import 'package:orca/features/home/presentation/profile_page.dart';
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

  String _challengeStageText(Challenge c) {
    final int p = c.progress;

    if (p == 0) return "Stage: Onboarding";
    if (p == 1) return "Stage: Momentum";
    if (p == 2) return "Stage: Consistent";
    if (p == 3) return "Stage: Strong";
    if (p >= c.target) return "Stage: Complete";

    return "Stage: Progressing";
  }

  List<Exercise> exercises = [];
  bool _isLoading = true;
  final ExerciseService _exerciseService = ExerciseService();

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

      final fetched = await _challengeService.getChallenges(auth.token!);

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

  Future<void> fetchAllExercises() async {
    try {
      debugPrint("Fetching exercises...");

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.loadAuthData();

      final exercisesList = await _exerciseService.fetchExercises(auth.token!);
      debugPrint('${exercisesList.length} exercises fetched.');
      setState(() {
        debugPrint('ex: $exercisesList');
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Challenge? weeklyChallenge = challenges.isNotEmpty ? challenges.first : null;
    final double challengeProgress = weeklyChallenge == null ? 0 : (weeklyChallenge.progress / weeklyChallenge.target).clamp(0.0, 1.0);

    return Scaffold(
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
                    IconButton(onPressed: (){}, icon: Icon(Icons.search_rounded, color: white, size: 20.sp))
                  ],
                ),
                dailyTracker(),
                sizedten(context),
                Row(
                  children: [
                    Text('Explore', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AllWorkouts(),
                        ));
                      },
                      child: Row(
                        children: [
                          Text('View All', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_right, size: 20.sp, color: green),
                        ],
                      ),
                    )
                  ],
                ),
                sizedtwenty(context),
                _isLoading
                    ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(3, (_) => workoutShimmer())))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: exercises.map((ex) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: _buildWorkoutCard(ex),
                            );
                          }).toList(),
                        ),
                      ),
                sizedtwenty(context),
                Text('Weekly Challenge', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                Text(
                  "Aura building through consistency",
                  style: TextStyle(
                    color: Colors.greenAccent.withOpacity(0.8),
                    fontSize: 12.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 12.sp),
                loadingChallenges
                    ? Center(child: challengeShimmer())
                    : (weeklyChallenge == null)
                        ? Text("No challenges available", style: TextStyle(color: Colors.white54))
                        : GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => WeeklyChallenge(challenge: challenges[0],),
                              ));
                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: 57.sp,
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    image: const DecorationImage(
                                      image: AssetImage("assets/images/challenge.png"),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                Container(
                                  height: 57.sp,
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 16.sp, left: 14.sp),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _challengeStageText(weeklyChallenge),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  letterSpacing: 1,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 10.sp),
                                              SizedBox(
                                                width: 66.sp,
                                                child: LinearProgressIndicator(
                                                  borderRadius: BorderRadius.circular(16),
                                                  value: challengeProgress,
                                                  backgroundColor: green.withOpacity(0.4),
                                                  valueColor: AlwaysStoppedAnimation<Color>(green),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 12.sp, right: 14.sp),
                                          child: const Icon(Icons.arrow_forward, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                  child: Image.asset(
                    imagePath,
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
