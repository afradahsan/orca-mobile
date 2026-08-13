import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/fitness/data/workout_log_service.dart';
import 'package:orca/features/fitness/domain/workout_log.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class WorkoutLogPage extends StatefulWidget {
  const WorkoutLogPage({super.key});

  @override
  State<WorkoutLogPage> createState() => _WorkoutLogPageState();
}

class _WorkoutLogPageState extends State<WorkoutLogPage> {
  final List<String> categories = ["Chest", "Back", "Legs", "Arms", "Shoulders"];
  int selectedCategory = 0;

  List<Map<String, dynamic>> logs = [];
  bool isLoading = true;

  String selectedMood = "🙂";
  final WorkoutLogService _workoutLogService = WorkoutLogService();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.loadAuthData();
      final token = auth.token ?? '';

      if (token.isNotEmpty) {
        final fetchedLogs = await _workoutLogService.getWorkoutLogs(token);
        if (mounted) {
          setState(() {
            logs = fetchedLogs.map((l) {
              return {
                "id": l.id,
                "exercise": l.exerciseName,
                "category": l.category,
                "weight": l.weight,
                "sets": l.sets,
                "reps": l.reps,
                "mood": l.mood,
                "date": l.date,
              };
            }).toList();
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading logs in WorkoutLogPage: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _openAddWorkoutSheet() {
    final exerciseController = TextEditingController();
    final weightController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();

    String selectedFormCategory = categories[selectedCategory];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.sp,
                right: 16.sp,
                top: 16.sp,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.sp,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _inputField("Exercise Name", exerciseController),
                    SizedBox(height: 12.sp),
                    DropdownButtonFormField<String>(
                      value: selectedFormCategory,
                      dropdownColor: Colors.black,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedFormCategory = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 12.sp),
                    _inputField("Weight (kg)", weightController, isNumber: true),
                    SizedBox(height: 12.sp),
                    _inputField("Sets", setsController, isNumber: true),
                    SizedBox(height: 12.sp),
                    _inputField("Reps", repsController, isNumber: true),
                    SizedBox(height: 18.sp),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "How did it feel?",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ["😵", "😓", "🙂", "😄", "🔥"].map((emoji) {
                        final selected = selectedMood == emoji;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedMood = emoji;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(10.sp),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected ? white.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                            ),
                            child: Text(
                              emoji,
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.sp),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          padding: EdgeInsets.symmetric(vertical: 14.sp),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final exerciseName = exerciseController.text.trim();
                          if (exerciseName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter an exercise name"),
                                backgroundColor: Colors.orangeAccent,
                              ),
                            );
                            return;
                          }

                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          await auth.loadAuthData();
                          final token = auth.token ?? '';

                          final double weight = double.tryParse(weightController.text) ?? 0.0;
                          final int sets = int.tryParse(setsController.text) ?? 0;
                          final int reps = int.tryParse(repsController.text) ?? 0;

                          final success = await _workoutLogService.createWorkoutLog(
                            token: token,
                            exerciseName: exerciseName,
                            category: selectedFormCategory,
                            weight: weight,
                            sets: sets,
                            reps: reps,
                            mood: selectedMood,
                            date: DateTime.now(),
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Workout log saved! 💪"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _loadLogs();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to save workout log to server"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          "SAVE WORKOUT",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: GoogleFonts.bebasNeue().fontFamily,
                            fontSize: 16.sp,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _todaySummaryCard() {
    final todayLogs = logs.where((log) {
      final d = log["date"];
      return d is DateTime && d.day == DateTime.now().day && d.month == DateTime.now().month && d.year == DateTime.now().year;
    }).toList();

    final totalSets = todayLogs.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item["sets"].toString()) ?? 0),
    );

    final moods = todayLogs.map((e) => e["mood"]).toList();
    final todayMood = moods.isNotEmpty ? moods.last : "🙂";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
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
                const Text("Today", style: TextStyle(color: Colors.white70)),
                SizedBox(height: 4.sp),
                Text(
                  "${todayLogs.length} exercises",
                  style: TextStyle(
                    color: green,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$totalSets sets  $todayMood",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _weeklyProgressCard() {
    final weekData = [12, 18, 10, 0, 14, 20, 16];
    final days = ["M", "T", "W", "T", "F", "S", "S"];

    final maxValue = weekData.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Progress",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 16.sp),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final height = (weekData[index] / maxValue) * 60;

              return Column(
                children: [
                  Container(
                    width: 16.sp,
                    height: height * 1.5,
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 6.sp),
                  Text(
                    days[index],
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11.sp,
                    ),
                  )
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = logs.where((log) => log["category"] == categories[selectedCategory]).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "WORKOUT LOG",
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.bebasNeue().fontFamily,
            fontSize: 18.sp,
            letterSpacing: 4,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: green,
        onPressed: _openAddWorkoutSheet,
        icon: const Icon(Icons.fitness_center, color: Colors.black),
        label: const Text(
          "Add Log",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: green))
          : SingleChildScrollView(
              padding: EdgeInsets.all(14.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _todaySummaryCard(),
                  SizedBox(height: 14.sp),
                  _weeklyProgressCard(),
                  SizedBox(height: 18.sp),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(categories.length, (index) {
                        final selected = selectedCategory == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = index;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10.sp),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.sp,
                              vertical: 8.sp,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: selected ? green.withOpacity(0.9) : Colors.white.withOpacity(0.04),
                              border: Border.all(
                                color: selected ? green : Colors.grey.shade800,
                              ),
                            ),
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                color: selected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 18.sp),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 10.sp),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.025),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: _header("Date")),
                        Expanded(flex: 3, child: _header("Exercise")),
                        Expanded(child: _header("Kg")),
                        Expanded(child: _header("Sets")),
                        Expanded(child: _header("Reps")),
                        Expanded(child: _header("Feel")),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  if (filteredLogs.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.sp),
                        child: const Text(
                          "No workouts logged yet",
                          style: TextStyle(
                            color: Colors.white38,
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredLogs.map((log) {
                      final DateTime d = log["date"] is DateTime ? log["date"] : DateTime.now();

                      return Container(
                        margin: EdgeInsets.only(bottom: 6.sp),
                        padding: EdgeInsets.symmetric(
                          vertical: 12.sp,
                          horizontal: 10.sp,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "${d.day} ${_monthName(d.month)}",
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                (log["exercise"] ?? "").toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                (log["weight"] ?? "0").toString(),
                                style: const TextStyle(
                                  color: green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(child: Text((log["sets"] ?? "0").toString(), style: const TextStyle(color: Colors.white))),
                            Expanded(child: Text((log["reps"] ?? "0").toString(), style: const TextStyle(color: Colors.white))),
                            Expanded(child: Text((log["mood"] ?? "🙂").toString(), style: TextStyle(fontSize: 16.sp))),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _header(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white54,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _inputField(
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? [
              FilteringTextInputFormatter.digitsOnly,
            ]
          : [],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? months[month] : '';
  }
}
