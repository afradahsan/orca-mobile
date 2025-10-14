import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/fitness/data/challenge_model.dart';
import 'package:orca/features/fitness/data/challenge_task_model.dart';
import 'package:orca/features/fitness/data/exercise_model.dart';
import 'package:orca/features/fitness/data/guide_model.dart';
import 'package:orca/features/fitness/presentations/account_fitness.dart';
import 'package:orca/features/fitness/presentations/all_workouts.dart';
import 'package:orca/features/fitness/presentations/fitness_guide.dart';
import 'package:orca/features/fitness/presentations/weekly_challenge.dart';
import 'package:orca/features/fitness/presentations/workout_page.dart';
import 'package:orca/features/home/presentation/profile_page.dart';
import 'package:sizer/sizer.dart';

class FitnessPage extends StatefulWidget {
  const FitnessPage({super.key});

  @override
  State<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage> {
  int selectedIndex = 1;
  double progress = 0.2;

  final List<Exercise> exercises = [
    Exercise(
      id: "1",
      title: "Squat Exercise",
      category: "Legs",
      duration: "12 Min",
      difficulty: "Beginner",
      steps: ["Stand straight", "Bend knees", "Repeat"],
      calories: 45,
    ),
    Exercise(
      id: "2",
      title: "Full Body Stretching",
      category: "Stretch",
      duration: "12 Min",
      difficulty: "Beginner",
      steps: ["Stretch arms", "Hold pose", "Repeat"],
      calories: 45,
    ),
  ];

  final Guide guide = Guide(
    id: "g1",
    title: "Calisthenics Workout!",
    category: "Workout",
    duration: "10 Min",
    pdfUrl: "https://example.com/guide.pdf",
  );

  late Challenge weeklyChallenge;

  @override
  void initState() {
    super.initState();
    weeklyChallenge = Challenge(
      id: "c1",
      title: "Weekly Fat Burn",
      description: "Complete 10 sessions this week",
      target: 10,
      tasks: [
        ChallengeTask(id: "t1", day: "Monday", taskName: "Do 30 pushups"),
        ChallengeTask(id: "t2", day: "Tuesday", taskName: "15 min Run"),
      ],
      startDate: DateTime(2025, 09, 11),
      endDate: DateTime(2025, 09, 11),
    );
    progress = weeklyChallenge.target > 0 ? weeklyChallenge.progress / weeklyChallenge.target : 0;
  }

  void onIconTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ));
                      },
                      child: CircleAvatar(
                        radius: 18.sp,
                        backgroundColor: Colors.transparent,
                        backgroundImage: const AssetImage('assets/images/gym.png'),
                      ),
                    )
                  ],
                ),

                dailyTracker(),
                sizedten(context),

                // Explore
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

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: exercises.map((ex) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildWorkoutCard(
                          "assets/images/gym.png",
                          ex.title,
                          ex.duration,
                          "120 Kcal",
                        ),
                      );
                    }).toList(),
                  ),
                ),

                sizedtwenty(context),

                Text('Weekly Challenge', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.sp),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WeeklyChallenge(),
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
                                    Text('${weeklyChallenge.progress}/${weeklyChallenge.target} Complete - ${(progress * 100).toInt()}%',
                                        style: const TextStyle(color: Colors.white, letterSpacing: 1)),
                                    SizedBox(height: 10.sp),
                                    SizedBox(
                                      width: 66.sp,
                                      child: LinearProgressIndicator(
                                        borderRadius: BorderRadius.circular(16),
                                        value: progress,
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
                      builder: (context) => FitnessGuidePage(),
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

  Widget _buildWorkoutCard(
    String imagePath,
    String title,
    String duration,
    String calories,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return WorkoutPage();
          },
        ));
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
                // Positioned(
                //   bottom: -12.sp,
                //   right: 10.sp,
                //   child: Container(
                //     padding: const EdgeInsets.all(6),
                //     decoration: BoxDecoration(
                //       color: Colors.purple,
                //       shape: BoxShape.circle,
                //     ),
                //     child: Icon(Icons.play_arrow, color: Colors.white),
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(
                  color: Color(0xFFD6FF00),
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
                  Icon(Icons.access_time, color: Colors.purple, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.local_fire_department, color: Colors.purple, size: 16.sp),
                  const SizedBox(width: 4),
                  Text(
                    calories,
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
