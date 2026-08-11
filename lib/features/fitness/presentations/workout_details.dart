import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/fitness/data/member_challenge_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

enum TimerPhase { work, rest }

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
  Timer? _timer;

  bool _isPlaying = false;
  bool _isCompleted = false;

  int _timerSeconds = 0;

  int _currentExerciseIndex = 0;
  int _currentSet = 1;

  TimerPhase _phase = TimerPhase.work;

  // ✅ fallback work time if backend doesn’t provide
  static const int defaultWorkSeconds = 30;

  int _parseInt(dynamic val, int defaultValue) {
    if (val == null) return defaultValue;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  Map<String, dynamic> get currentExercise => widget.exercises.isNotEmpty ? widget.exercises[_currentExerciseIndex] : {};

  int get sets => _parseInt(currentExercise['sets'], 1);
  int get reps => _parseInt(currentExercise['reps'], 0);
  int get restTime => _parseInt(currentExercise['restTime'], 30);

  // optional: if you later add duration in backend
  int get workTime => _parseInt(currentExercise['duration'], defaultWorkSeconds);

  @override
  void initState() {
    super.initState();
    _resetForNewExercise();
  }

  void _resetForNewExercise() {
    _timer?.cancel();

    setState(() {
      _phase = TimerPhase.work;
      _timerSeconds = workTime;
      _isPlaying = false;
      _isCompleted = false;
      _currentSet = 1;
    });
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
        _handleTimerFinished();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _togglePlayPause() {
    if (_isCompleted) {
      _restartPhase();
      return;
    }

    setState(() => _isPlaying = !_isPlaying);

    if (_isPlaying) {
      _startTimer();
    } else {
      _pauseTimer();
    }
  }

  void _restartPhase() {
    _timer?.cancel();

    setState(() {
      _isCompleted = false;
      _isPlaying = true;
      _timerSeconds = _phase == TimerPhase.work ? workTime : restTime;
    });

    _startTimer();
  }

  void _stopTimerManually() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _isCompleted = false;
      _timerSeconds = _phase == TimerPhase.work ? workTime : restTime;
    });
  }

  // ✅ This is the MAIN logic
  void _handleTimerFinished() {
    setState(() {
      _isPlaying = false;
      _isCompleted = true;
      _timerSeconds = 0;
    });

    // If WORK ends -> go REST
    if (_phase == TimerPhase.work) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;

        setState(() {
          _phase = TimerPhase.rest;
          _timerSeconds = restTime;
          _isCompleted = false;
          _isPlaying = true;
        });

        _startTimer();
      });
      return;
    }

    // If REST ends -> next set or next exercise
    if (_phase == TimerPhase.rest) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;

        // next set
        if (_currentSet < sets) {
          setState(() {
            _currentSet++;
            _phase = TimerPhase.work;
            _timerSeconds = workTime;
            _isCompleted = false;
            _isPlaying = false;
          });
          return;
        }

        // next exercise
        if (_currentExerciseIndex < widget.exercises.length - 1) {
          setState(() {
            _currentExerciseIndex++;
          });
          _resetForNewExercise();
          return;
        }

        // finished last exercise
        setState(() {
          _isCompleted = true;
        });
      });

      return;
    }
  }

  // ✅ Skip rest button
  void _skipRest() {
    if (_phase != TimerPhase.rest) return;

    _timer?.cancel();

    // next set
    if (_currentSet < sets) {
      setState(() {
        _currentSet++;
        _phase = TimerPhase.work;
        _timerSeconds = workTime;
        _isCompleted = false;
        _isPlaying = false;
      });
      return;
    }

    // next exercise
    if (_currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
      _resetForNewExercise();
      return;
    }

    // last exercise done
    setState(() {
      _isCompleted = true;
      _isPlaying = false;
    });
  }

  Future<void> _logWorkoutToChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("member_token");
    final challengeId = prefs.getString("active_challenge_id");

    if (token == null || challengeId == null) return;

    try {
      final updated = await MemberChallengeService().logWorkout(challengeId, token);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          content: Text(
            "+${updated.auraEarnedToday} Aura✨",
            style: const TextStyle(color: Colors.greenAccent, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastExercise = _currentExerciseIndex == widget.exercises.length - 1;
    final bool showFinishButton = isLastExercise && _currentSet == sets && _phase == TimerPhase.rest;

    final String title = (currentExercise['title'] ?? "Workout").toString();
    final String imageUrl = (currentExercise['imageUrl'] ?? "").toString();

    final String timerLabel = _phase == TimerPhase.work ? "WORK" : "REST";

    final Color timerColor = _phase == TimerPhase.work ? green : Colors.white;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.bebasNeue().fontFamily,
            letterSpacing: 5,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 18.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Hero Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 50.sp,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  "assets/images/gym.png",
                  width: double.infinity,
                  height: 60.sp,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 14.sp),

            // 📌 Set progress
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 14.sp),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SET PROGRESS",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white54,
                            letterSpacing: 2,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                        SizedBox(height: 6.sp),
                        Text(
                          "Set $_currentSet / $sets • $reps reps",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: green,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.bebasNeue().fontFamily,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  SizedBox(
                    width: 90,
                    child: LinearProgressIndicator(
                      value: (_currentSet / sets).clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation(green),
                      borderRadius: BorderRadius.circular(50),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.sp),

            // 🧩 Grid Tiles (2×2)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _infoTile(Icons.bar_chart, "Difficulty", currentExercise['difficulty']),
                _infoTile(Icons.category, "Category", currentExercise['category']),
                _infoTile(Icons.fitness_center, "Equipment", currentExercise['equipment']),
                _infoTile(Icons.accessibility_new, "Target", currentExercise['targetMuscles']),
              ],
            ),
          ],
        ),
      ),

      // ⏱ Timer + Controls
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16.sp, 12.sp, 16.sp, 16.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timerLabel,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12.sp,
                letterSpacing: 3,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
            SizedBox(height: 4.sp),
            Text(
              "00:${_timerSeconds.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.w600,
                color: timerColor,
                fontFamily: GoogleFonts.bebasNeue().fontFamily,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 12.sp),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play/Pause
                _actionButton(
                  icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                  onTap: _togglePlayPause,
                  backgroundColor: green,
                  iconColor: Colors.black,
                ),

                if (_isPlaying) SizedBox(width: 14.sp),

                // Skip Rest (only during rest)
                if (_phase == TimerPhase.rest)
                  _actionButton(
                    icon: Icons.fast_forward,
                    onTap: _skipRest,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    iconColor: green,
                    borderColor: green,
                    borderRadius: 16.sp,
                  ),
                SizedBox(width: 14.sp),

                // Stop
                if (_isPlaying)
                  _actionButton(
                    icon: Icons.stop,
                    onTap: _stopTimerManually,
                    backgroundColor: Colors.white,
                    iconColor: Colors.black,
                    borderRadius: 16.sp,
                  ),

                if (!_isPlaying && _phase == TimerPhase.rest) SizedBox(width: 14.sp),

                // Skip Rest in bottom too (optional)
                if (!_isPlaying && _phase == TimerPhase.rest)
                  _actionButton(
                    icon: Icons.fast_forward,
                    onTap: _skipRest,
                    backgroundColor: Colors.transparent,
                    iconColor: green,
                    borderColor: green,
                    borderRadius: 16.sp,
                  ),
              ],
            ),

            SizedBox(height: 10.sp),

            // Finish button
            if (showFinishButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: EdgeInsets.symmetric(vertical: 14.sp),
                  ),
                  onPressed: () async {
                    await _logWorkoutToChallenge();
                    if (mounted) Navigator.pop(context);
                  },
                  child: Text(
                    "FINISH",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      fontFamily: GoogleFonts.bebasNeue().fontFamily,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔥 Premium grid tile
  Widget _infoTile(IconData icon, String title, dynamic value) {
    final String displayValue = value is List ? value.join(', ') : value?.toString() ?? "-";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 32.sp,
            height: 32.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: green.withOpacity(0.12),
            ),
            child: Icon(icon, color: green, size: 18.sp),
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                SizedBox(height: 2.sp),
                Text(
                  displayValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.bebasNeue().fontFamily,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _miniTile(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10.sp,
              letterSpacing: 2,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          SizedBox(height: 4.sp),
          Text(
            value,
            style: TextStyle(
              color: green,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.bebasNeue().fontFamily,
              letterSpacing: 2,
            ),
          ),
        ],
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
        padding: EdgeInsets.all(12.sp),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor != null ? BorderSide(color: borderColor, width: 2) : BorderSide.none,
        ),
      ),
      child: Icon(icon, color: iconColor, size: 20.sp),
    );
  }
}
