import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/fitness/data/member_challenge_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class WorkoutDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;

  const WorkoutDetailsPage({
    super.key,
    required this.exercises,
  });

  @override
  State<WorkoutDetailsPage> createState() => _WorkoutDetailsPageState();
}

class _WorkoutDetailsPageState extends State<WorkoutDetailsPage> {
  bool _isPlaying = false;
  int _timerSeconds = 30;
  Timer? _timer;
  bool _isCompleted = false;
  int _currentExerciseIndex = 0;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        _stopTimer();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _isCompleted = true;
      _timerSeconds = 0;
    });

    if (_currentExerciseIndex < widget.exercises.length - 1) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isCompleted) {
          _nextExercise();
        }
      });
    }
  }

  void _togglePlayPause() {
    if (_isCompleted) {
      _restartExercise();
      return;
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startTimer();
    } else {
      _pauseTimer();
    }
  }

  void _restartExercise() {
    setState(() {
      _timerSeconds = 30;
      _isCompleted = false;
      _isPlaying = true;
    });
    _startTimer();
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _timerSeconds = 30;
        _isCompleted = false;
        _isPlaying = false;
      });
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _timerSeconds = 30;
        _isCompleted = false;
        _isPlaying = false;
      });
    }
  }

  Future<void> _logWorkoutToChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("member_token");
    final challengeId = prefs.getString("active_challenge_id");

    if (token == null || challengeId == null) return;

    try {
      final updated = await MemberChallengeService().logWorkout(challengeId, token);

      // optional aura popup
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.black,
            content: Text(
              "+${updated.auraEarnedToday} Aura✨",
              style: TextStyle(color: Colors.greenAccent, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context);
      }
    } catch (_) {
      // silently fail if already logged today
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.exercises[_currentExerciseIndex];
    final isLastExercise = _currentExerciseIndex == widget.exercises.length - 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(currentExercise['title'], style: TextStyle(color: Colors.white, fontFamily: GoogleFonts.bebasNeue().fontFamily, letterSpacing: 6.sp)),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 18.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                currentExercise['imageUrl'] ?? '',
                width: double.infinity,
                height: 75.sp,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  "assets/images/gym.png",
                  height: 70.sp,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 6.sp),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 14.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoBlock(context, Icons.bar_chart, 'Difficulty', currentExercise['difficulty']),
                  sizedten(context),
                  _infoBlock(context, Icons.category, 'Category', currentExercise['category']),
                  sizedten(context),
                  _infoBlock(context, Icons.fitness_center, 'Equipment', currentExercise['equipment']),
                  sizedten(context),
                  _infoBlock(context, Icons.accessibility_new, 'Target Muscles', currentExercise['targetMuscles']),
                  sizedten(context),
                  _infoBlock(context, Icons.repeat, 'Sets / Reps', "${currentExercise['sets']} x ${currentExercise['reps']}"),
                  sizedten(context),
                  _infoBlock(context, Icons.timer, 'Rest Time', "${currentExercise['restTime']} sec"),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '00:${_timerSeconds.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 35.sp,
                fontWeight: FontWeight.w500,
                color: green,
                fontFamily: GoogleFonts.bebasNeue().fontFamily,
              ),
            ),
            sizedfive(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isCompleted) ...[
                  _actionButton(
                    icon: Icons.replay,
                    onTap: _restartExercise,
                    backgroundColor: Color(0xFFB9F708),
                    iconColor: darkgreen,
                  ),
                  if (!isLastExercise) SizedBox(width: 6.w),
                  if (!isLastExercise)
                    _actionButton(
                      icon: Icons.arrow_forward_rounded,
                      onTap: _nextExercise,
                      backgroundColor: Colors.transparent,
                      iconColor: Colors.white,
                      borderColor: Color(0xFFB9F708),
                    ),
                  if (isLastExercise) SizedBox(width: 8.w),
                  if (isLastExercise)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      ),
                      onPressed: () async {
                        await _logWorkoutToChallenge();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Finish',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.sp,
                          letterSpacing: 4.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                    ),
                ] else ...[
                  _actionButton(
                    icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                    onTap: _togglePlayPause,
                    backgroundColor: Color(0xFFB9F708),
                    iconColor: darkgreen,
                  ),
                  if (_isPlaying) SizedBox(width: 16),
                  if (_isPlaying)
                    _actionButton(
                      icon: Icons.stop,
                      onTap: _stopTimer,
                      backgroundColor: Colors.white,
                      iconColor: darkgreen,
                      borderRadius: 16.sp,
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
    Color? borderColor,
    double borderRadius = 50,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(10.sp),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor != null ? BorderSide(color: borderColor, width: 2) : BorderSide.none,
        ),
      ),
      child: Icon(icon, color: iconColor, size: 20.sp),
    );
  }

  Widget _infoBlock(
    BuildContext context,
    IconData icon,
    String title,
    dynamic value,
  ) {
    final String displayValue = value is List ? value.join(', ') : value?.toString() ?? '';

    return Container(
      height: 32.sp,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 3.sp),
      decoration: BoxDecoration(
        color: const Color.fromARGB(70, 53, 53, 53),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8b7a6b), size: 20.sp),
          sizedwfive(context),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: green,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                displayValue,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: green,
                  fontFamily: GoogleFonts.bebasNeue().fontFamily,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
