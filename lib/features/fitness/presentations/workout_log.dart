import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:orca/core/utils/colors.dart';

class WorkoutLogPage extends StatefulWidget {
  const WorkoutLogPage({super.key});

  @override
  State<WorkoutLogPage> createState() => _WorkoutLogPageState();
}

class _WorkoutLogPageState extends State<WorkoutLogPage> {
  final List<String> categories = ["Chest", "Back", "Legs", "Arms", "Shoulders"];
  int selectedCategory = 0;

  List<Map<String, dynamic>> logs = [];

  String selectedMood = "🙂";

  void _openAddWorkoutSheet() {
    final exerciseController = TextEditingController();
    final weightController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();

    String selectedFormCategory = categories[selectedCategory];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(16.sp),
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
                          child: Text(cat, style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedFormCategory = value!;
                        });
                      },
                    ),
                    SizedBox(height: 12.sp),
                    _inputField("Weight (kg)", weightController, isNumber: true),
                    SizedBox(height: 12.sp,),
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
                            duration: Duration(milliseconds: 200),
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
                        onPressed: () {
                          final today = DateTime.now();

                          final existingIndex = logs.indexWhere(
                            (log) =>
                                log["exercise"].toString().toLowerCase() == exerciseController.text.toLowerCase() &&
                                log["category"] == selectedFormCategory &&
                                log["date"].day == today.day &&
                                log["date"].month == today.month &&
                                log["date"].year == today.year,
                          );

                          if (existingIndex != -1) {
                            logs[existingIndex] = {
                              "exercise": exerciseController.text,
                              "weight": weightController.text,
                              "sets": setsController.text,
                              "reps": repsController.text,
                              "category": selectedFormCategory,
                              "date": today,
                              "mood": selectedMood,
                            };
                          } else {
                            logs.add({
                              "exercise": exerciseController.text,
                              "weight": weightController.text,
                              "sets": setsController.text,
                              "reps": repsController.text,
                              "category": selectedFormCategory,
                              "date": today,
                              "mood": selectedMood,
                            });
                          }

                          setState(() {});
                          Navigator.pop(context);
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
      (sum, item) => sum + int.tryParse(item["sets"].toString())!,
    );

    final moods = todayLogs.map((e) => e["mood"]).toList();
    final todayMood = moods.isNotEmpty ? moods.last : "🙂";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF181818),
            const Color(0xFF101010),
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
                Text("Today", style: TextStyle(color: Colors.white70)),
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
            style: TextStyle(color: Colors.white),
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
                    height: height*1.5,
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
        icon: Icon(Icons.fitness_center, color: Colors.black),
        label: Text(
          "Add Log",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                  child: Text(
                    "No workouts logged yet",
                    style: TextStyle(
                      color: Colors.white38,
                    ),
                  ),
                ),
              )
            else
              ...filteredLogs.map((log) {
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
                          "${log["date"].day} ${_monthName(log["date"].month)}",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          log["exercise"],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          log["weight"],
                          style: TextStyle(
                            color: green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Text(log["sets"], style: TextStyle(color: Colors.white))),
                      Expanded(child: Text(log["reps"], style: TextStyle(color: Colors.white))),
                      Expanded(child: Text(log["mood"], style: TextStyle(fontSize: 16.sp))),
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
      style: TextStyle(
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
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }
}
