import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/fitness/data/challenge_model.dart';
import 'package:orca/features/fitness/data/challenge_task_model.dart';
import 'package:sizer/sizer.dart';

class WeeklyChallenge extends StatefulWidget {
  const WeeklyChallenge({super.key});

  @override
  State<WeeklyChallenge> createState() => _WeeklyChallengeState();
}

class _WeeklyChallengeState extends State<WeeklyChallenge> {
  late Challenge challenge;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  void _loadChallenge() {
    challenge = Challenge(
      id: '1',
      title: 'Complete 5 workouts in 7 days',
      description: 'Finish at least 5 workouts this week to stay consistent.',
      target: 5,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 6)),
      progress: 3,
      tasks: [
        ChallengeTask(id: '1', day: 'Monday', taskName: 'Chest Day', completed: true),
        ChallengeTask(id: '2', day: 'Tuesday', taskName: 'Leg Day', completed: true),
        ChallengeTask(id: '3', day: 'Wednesday', taskName: 'Rest', completed: false),
        ChallengeTask(id: '4', day: 'Thursday', taskName: 'Cardio + Core', completed: true),
        ChallengeTask(id: '5', day: 'Friday', taskName: 'Back + Biceps', completed: false),
        ChallengeTask(id: '6', day: 'Saturday', taskName: 'Stretch & Recovery', completed: false),
      ],
    );
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      challenge.tasks[index].completed = !challenge.tasks[index].completed;
      challenge.progress = challenge.tasks.where((t) => t.completed).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double completionPercent =
        challenge.progress / challenge.target > 1 ? 1 : challenge.progress / challenge.target;

    final Duration remaining = challenge.endDate.difference(DateTime.now());
    final String remainingText = '${remaining.inDays}d ${(remaining.inHours % 24)}h';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Weekly Challenge',
          style: TextStyle(
            color: white,
            fontFamily: GoogleFonts.bebasNeue().fontFamily,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('JOIN CHALLENGE'),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _challengeHeader(remainingText),
            SizedBox(height: 3.h),
            _progressTracker(completionPercent),
            SizedBox(height: 2.h),
            const Divider(color: Colors.white24),
            SizedBox(height: 2.h),
            Expanded(child: _dailyTasks()),
          ],
        ),
      ),
    );
  }

  Widget _challengeHeader(String remainingText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🔥 This Week\'s Challenge', style: TextStyle(fontSize: 14.sp, color: Colors.white70)),
        SizedBox(height: 0.5.h),
        Text(
          challenge.title,
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            const Icon(Icons.timer, color: Colors.orangeAccent),
            SizedBox(width: 1.w),
            Text(
              'Ends in $remainingText',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 14.sp,
                fontFamily: GoogleFonts.bebasNeue().fontFamily,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _progressTracker(double completionPercent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontFamily: GoogleFonts.bebasNeue().fontFamily,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 1.h),
        Stack(
          children: [
            Container(
              height: 15,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 15,
              width: completionPercent * 100.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.greenAccent, Colors.lightGreen]),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          '${challenge.progress} of ${challenge.target} done',
          style: const TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _dailyTasks() {
    return ListView.separated(
      itemCount: challenge.tasks.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.transparent),
      itemBuilder: (context, index) {
        final task = challenge.tasks[index];
        return InkWell(
          onTap: () => _toggleTaskCompletion(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 14.sp),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white38, width: 3.sp),
              borderRadius: BorderRadius.circular(12.sp),
              color: task.completed ? Colors.green.withOpacity(0.1) : Colors.transparent,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: const AssetImage('assets/images/gym.png'),
                ),
                sizedwten(context),
                Text(
                  task.taskName,
                  style: TextStyle(
                    color: task.completed ? Colors.white.withAlpha(180) : Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.bebasNeue().fontFamily,
                    letterSpacing: 1,
                    decoration: task.completed ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.greenAccent,
                  ),
                ),
                const Spacer(),
                Icon(
                  task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: task.completed ? Colors.greenAccent : Colors.white38,
                  size: 20.sp,
                ),
                sizedwfive(context),
              ],
            ),
          ),
        );
      },
    );
  }
}
