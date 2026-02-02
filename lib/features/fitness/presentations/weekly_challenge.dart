import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/fitness/data/member_challenge_service.dart';
import 'package:orca/features/fitness/domain/challenge_model.dart';
import 'package:orca/features/fitness/domain/challenge_task_model.dart';
import 'package:orca/features/fitness/domain/member_challenge_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class WeeklyChallenge extends StatefulWidget {
  final Challenge challenge;

  const WeeklyChallenge({
    super.key,
    required this.challenge,
  });

  @override
  State<WeeklyChallenge> createState() => _WeeklyChallengeState();
}

class _WeeklyChallengeState extends State<WeeklyChallenge> {
  late Challenge challenge;

  /// HABIT LOOP CORE
  late int weeklyTarget;
  int completedWorkouts = 0;
  bool hasJoined = true;

  /// REWARD SYSTEM
  int weeklyStreak = 0;

  /// OPTIONAL SUGGESTED PLAN
  late List<ChallengeTask> suggestedPlan;
  MemberChallengeProgress? progressData;
  bool loadingProgress = true;

  @override
  void initState() {
    super.initState();
    challenge = widget.challenge;

    weeklyTarget = challenge.exerciseIds.length;
    completedWorkouts = challenge.progress ?? 0;
    weeklyStreak = 2; // later from backend

    _loadSuggestedPlan();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("member_token");

    final data = await MemberChallengeService().getProgress(challenge.id, token!);

    setState(() {
      progressData = data;
      loadingProgress = false;
    });
  }

  void _loadSuggestedPlan() {
    suggestedPlan = [
      ChallengeTask(id: '1', day: 'Mon', taskName: 'Upper Body', completed: false),
      ChallengeTask(id: '2', day: 'Tue', taskName: 'Lower Body', completed: false),
      ChallengeTask(id: '3', day: 'Wed', taskName: 'Mobility', completed: false),
      ChallengeTask(id: '4', day: 'Thu', taskName: 'Cardio', completed: false),
      ChallengeTask(id: '5', day: 'Fri', taskName: 'Full Body', completed: false),
    ];
  }

  /// Derived
  double get progress => weeklyTarget == 0 ? 0 : completedWorkouts / weeklyTarget;
  int get remainingWorkouts => weeklyTarget - completedWorkouts;

  bool get bronzeUnlocked => completedWorkouts >= (weeklyTarget * 0.4);
  bool get silverUnlocked => completedWorkouts >= (weeklyTarget * 0.7);
  bool get goldUnlocked => completedWorkouts >= weeklyTarget;

  /// Log workout (habit action → reward)
  void _logWorkoutConfirmed() {
    if (completedWorkouts >= weeklyTarget) return;

    setState(() {
      completedWorkouts += 1;
      if (completedWorkouts == weeklyTarget) {
        weeklyStreak += 1;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          completedWorkouts == weeklyTarget ? "🔥 Challenge completed! Streak +1" : "Workout logged. Keep going 💪",
        ),
        backgroundColor: Colors.greenAccent.withOpacity(0.9),
      ),
    );
  }

  void _showLogWorkoutDialog() {
    showDialog(
      context: context,
      builder: (_) => const LogWorkoutDialog(),
    ).then((result) {
      if (result == true) {
        _logWorkoutConfirmed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final remainingDays = challenge.endDate.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: white,
          onPressed: () => Navigator.pop(context),
        ),
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
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(remainingDays),
              SizedBox(height: 2.5.h),
              _progressSection(),
              SizedBox(height: 2.5.h),
              _streakCard(),
              SizedBox(height: 2.5.h),
              _medalsRow(),
              SizedBox(height: 3.h),
              _actionButton(),
              SizedBox(height: 3.h),
              const Divider(color: Colors.white12),
              SizedBox(height: 2.h),
              _suggestedPlan(),
            ],
          ),
        ),
      ),
    );
  }

  /// HEADER (Cue)
  Widget _header(int remainingDays) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "THIS WEEK",
          style: TextStyle(
            color: Colors.white60,
            fontFamily: GoogleFonts.bebasNeue().fontFamily,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          challenge.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 0.6.h),
        Text(
          challenge.description ?? "",
          style: const TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            const Icon(Icons.bar_chart, color: Colors.orangeAccent),
            SizedBox(width: 6),
            Text(
              challenge.difficulty,
              style: const TextStyle(color: Colors.orangeAccent),
            ),
          ],
        ),
        SizedBox(height: 0.8.h),
        Text(
          remainingDays > 0 ? "$remainingDays days remaining" : "Challenge ended",
          style: const TextStyle(color: Colors.greenAccent),
        ),
      ],
    );
  }

  /// Progress
  Widget _progressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PROGRESS",
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.bebasNeue().fontFamily,
            letterSpacing: 2,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 1.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 12,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          "$completedWorkouts / $weeklyTarget workouts completed",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  /// Streak reward
  Widget _streakCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orangeAccent),
          SizedBox(width: 2.w),
          Text(
            "Streak: $weeklyStreak weeks",
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  /// Medals (milestones)
  Widget _medalsRow() {
    return Row(
      children: [
        _medalChip("Bronze", bronzeUnlocked, Colors.orangeAccent),
        SizedBox(width: 3.w),
        _medalChip("Silver", silverUnlocked, Colors.blueGrey.shade200),
        SizedBox(width: 3.w),
        _medalChip("Gold", goldUnlocked, Colors.amberAccent),
      ],
    );
  }

  Widget _medalChip(String label, bool unlocked, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: unlocked ? color.withOpacity(0.18) : Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: unlocked ? color : Colors.white24),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: unlocked ? color : Colors.white38, size: 16),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.white54,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// Action button (Habit action)
  Widget _actionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: completedWorkouts >= weeklyTarget ? null : _showLogWorkoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.green,
          disabledBackgroundColor: Colors.greenAccent.withOpacity(0.3),
          padding: EdgeInsets.symmetric(vertical: 14.sp),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          completedWorkouts >= weeklyTarget ? "COMPLETED ✔" : "LOG TODAY'S WORKOUT",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Suggested plan (optional)
  Widget _suggestedPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SUGGESTED PLAN (OPTIONAL)",
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.bebasNeue().fontFamily,
            letterSpacing: 2,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        ...suggestedPlan.map(_taskTile),
      ],
    );
  }

  Widget _taskTile(ChallengeTask task) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.2.h),
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 14.sp),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(14.sp),
        color: Colors.black26,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: const AssetImage('assets/images/gym.png'),
          ),
          sizedwten(context),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.day, style: TextStyle(color: Colors.white60, fontSize: 11.sp)),
              Text(
                task.taskName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.bebasNeue().fontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------- LOG WORKOUT DIALOG ----------

class LogWorkoutDialog extends StatefulWidget {
  const LogWorkoutDialog({super.key});

  @override
  State<LogWorkoutDialog> createState() => _LogWorkoutDialogState();
}

class _LogWorkoutDialogState extends State<LogWorkoutDialog> {
  String? workoutType;
  String? duration;

  final List<String> types = ["Gym", "Cardio", "Stretch", "Other"];
  final List<String> durations = ["15 min", "30 min", "45+ min"];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "💪 Log Today’s Workout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.bebasNeue().fontFamily,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("What did you do?", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: types.map(_typeChip).toList(),
            ),
            const SizedBox(height: 16),
            const Text("Duration", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: durations.map(_durationChip).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: workoutType != null && duration != null ? () => Navigator.pop(context, true) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.greenAccent.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("LOG ✔", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String type) {
    final selected = workoutType == type;
    return ChoiceChip(
      label: Text(type),
      selected: selected,
      onSelected: (_) => setState(() => workoutType = type),
      selectedColor: Colors.greenAccent.withOpacity(0.25),
      backgroundColor: Colors.white10,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.white70),
    );
  }

  Widget _durationChip(String d) {
    final selected = duration == d;
    return ChoiceChip(
      label: Text(d),
      selected: selected,
      onSelected: (_) => setState(() => duration = d),
      selectedColor: Colors.greenAccent.withOpacity(0.25),
      backgroundColor: Colors.white10,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.white70),
    );
  }
}
