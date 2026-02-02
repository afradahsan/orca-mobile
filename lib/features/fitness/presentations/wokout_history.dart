import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:sizer/sizer.dart';

class MemberWorkoutLog {
  final String workoutName;
  final int duration;
  final int calories;
  final int auraEarned;
  final DateTime date;

  MemberWorkoutLog({
    required this.workoutName,
    required this.duration,
    required this.calories,
    required this.auraEarned,
    required this.date,
  });
}

/// DEMO DATA
final demoLogs = [
  MemberWorkoutLog(
    workoutName: "Chest & Triceps",
    duration: 35,
    calories: 220,
    auraEarned: 100,
    date: DateTime.now(),
  ),
  MemberWorkoutLog(
    workoutName: "Cardio + Core",
    duration: 25,
    calories: 180,
    auraEarned: 100,
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  MemberWorkoutLog(
    workoutName: "Mobility Stretch",
    duration: 20,
    calories: 90,
    auraEarned: 100,
    date: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

class WorkoutHistoryPage extends StatelessWidget {
  const WorkoutHistoryPage({super.key});

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Workout Thread",
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.bebasNeue().fontFamily,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 12.sp),
        child: ListView.builder(
          itemCount: demoLogs.length,
          itemBuilder: (context, index) {
            final log = demoLogs[index];
            final isLast = index == demoLogs.length - 1;
            return _threadNode(log, isLast);
          },
        ),
      ),
    );
  }

  Widget _threadNode(MemberWorkoutLog log, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// THREAD COLUMN
        Column(
          children: [
            Container(
              width: 10.sp,
              height: 10.sp,
              decoration: BoxDecoration(
                color: green,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 45.sp,
                color: green.withOpacity(0.35),
              ),
          ],
        ),

        SizedBox(width: 10.sp),

        /// CONTENT
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(log.date),
                  style: TextStyle(
                    color: const Color.fromARGB(210, 255, 255, 255),
                    fontSize: 12.sp,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2.sp),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// LEFT TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// WORKOUT NAME
                          Text(
                            log.workoutName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontFamily: GoogleFonts.bebasNeue().fontFamily,
                              letterSpacing: 1,
                            ),
                          ),

                          SizedBox(height: 2.sp),

                          /// STATS
                          Text(
                            "${log.duration} min • ${log.calories} kcal",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// RIGHT SIDE
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        /// DATE
                        Text(
                          _formatDate(log.date),
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(height: 2.sp),

                        /// AURA
                        Text(
                          "+${log.auraEarned}",
                          style: TextStyle(
                            color: green,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
