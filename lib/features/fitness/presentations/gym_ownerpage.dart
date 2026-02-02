import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/auth_services.dart';
import 'package:orca/features/auth/data/gym_owner_service.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/auth/domain/user_model.dart';
import 'package:orca/features/auth/presentation/get_started.dart';
import 'package:orca/features/fitness/data/challenge_services.dart';
import 'package:orca/features/fitness/data/exercise_service.dart';
import 'package:orca/features/fitness/domain/challenge_model.dart';
import 'package:orca/features/fitness/domain/challenge_task_model.dart';
import 'package:orca/features/fitness/domain/exercise_model.dart';
import 'package:orca/features/fitness/domain/guide_model.dart';
import 'package:orca/features/fitness/domain/member_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class GymOwnerPage extends StatefulWidget {
  const GymOwnerPage({super.key, this.token});

  final String? token;

  @override
  State<GymOwnerPage> createState() => _GymOwnerPageState();
}

class _GymOwnerPageState extends State<GymOwnerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List exercises = [];
  List<Challenge> challenges = [];
  List<Guide> guides = [];
  List<UserModel> memberUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    loadData();
  }

  String? extractUserId(dynamic userIdField) {
    if (userIdField == null) return null;

    if (userIdField is String) return userIdField;

    if (userIdField is Map<String, dynamic>) {
      return userIdField["_id"] ?? userIdField["id"];
    }

    return null;
  }

  void loadData() async {
    debugPrint('Called loadData()');

    final gymOwnerService = GymOwnerService();
    final challengeService = ChallengeService();

    // 1️⃣ Load exercises
    try {
      final backendExercises = await gymOwnerService.getExercises();
      setState(() {
        exercises = backendExercises;
      });
    } catch (e) {
      debugPrint("❌ Exercise load failed: $e");
    }

    // 2️⃣ Load members
    try {
      final members = await gymOwnerService.getMembers();

      List<UserModel> fetchedMembers = members.where((m) => m.user != null).map((m) => m.user).toList();

      final uniqueMembers = <String, UserModel>{};
      for (var u in fetchedMembers) {
        uniqueMembers[u.id] = u;
      }

      setState(() {
        memberUsers = uniqueMembers.values.toList();
      });
    } catch (e) {
      debugPrint("❌ Member load failed: $e");
    }

    // 3️⃣ Load challenges (EXPECTED TO FAIL for gym owner)
    try {
      final backendChallenges = await challengeService.getChallenges(widget.token!);
      setState(() {
        challenges = backendChallenges;
      });
    } catch (e) {
      debugPrint("⚠️ Challenges skipped: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 8.sp),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5.sp),
                        Text(
                          'Welcome Back Owner!',
                          style: TextStyle(
                            color: white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Manage your Fitness Center',
                          style: TextStyle(
                            color: green,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.sp),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        debugPrint('logg out');
                        Provider.of<AuthProvider>(context, listen: false).logout();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => GetStarted()), (route) => false);
                      },
                      child: CircleAvatar(
                        radius: 18.sp,
                        backgroundImage: const AssetImage('assets/images/gym.png'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 22.sp),

                Row(
                  children: [
                    Text(
                      'Exercises',
                      style: TextStyle(color: white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _addExerciseForm,
                      child: Icon(Icons.add_circle, color: green, size: 22.sp),
                    ),
                  ],
                ),
                SizedBox(height: 10.sp),
                _horizontalScroll(
                  exercises
                      .map((e) => _dashboardCard(
                            title: e.name,
                            subtitle: "${e.duration} sec",
                            onTap: () => {},
                          ))
                      .toList(),
                ),

                SizedBox(height: 24.sp),
                Row(
                  children: [
                    Text("Members", style: TextStyle(color: white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    Spacer(),
                    GestureDetector(
                      onTap: _addMemberForm,
                      child: Icon(Icons.person_add, color: green, size: 22.sp),
                    )
                  ],
                ),
                SizedBox(height: 10.sp),

                _horizontalScroll(
                  memberUsers
                      .map((m) => _dashboardCard(
                            title: m.name,
                            subtitle: m.email,
                            onTap: () {},
                          ))
                      .toList(),
                ),

                SizedBox(height: 24.sp),

                // ===== Challenges Section =====
                Row(
                  children: [
                    Text(
                      'Challenges',
                      style: TextStyle(color: white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _addChallengeForm,
                      child: Icon(Icons.add_circle, color: green, size: 22.sp),
                    )
                  ],
                ),
                SizedBox(height: 10.sp),
                // _horizontalScroll(
                //   challenges
                //       .map((c) => _dashboardCard(
                //             title: c.title,
                //             subtitle: "Target: ${c.difficulty}",
                //             onTap: () {},
                //           ))
                //       .toList(),
                // ),

                SizedBox(height: 24.sp),

                // ===== Guides Section =====
                Row(
                  children: [
                    Text(
                      'Guides',
                      style: TextStyle(color: white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _addGuideForm,
                      child: Icon(Icons.add_circle, color: green, size: 22.sp),
                    )
                  ],
                ),
                SizedBox(height: 10.sp),
                _horizontalScroll(
                  guides
                      .map((g) => _dashboardCard(
                            title: g.title,
                            subtitle: g.category,
                            onTap: () {},
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _horizontalScroll(List<Widget> children) {
    if (children.isEmpty) {
      return Text("No items yet", style: TextStyle(color: Colors.white54));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: children.map((w) => Padding(padding: EdgeInsets.only(right: 14.sp), child: w)).toList(),
      ),
    );
  }

  Widget _dashboardCard({required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55.sp,
        height: 50.sp,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Color(0xFFD6FF00),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white70, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentManager() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ExpansionTile(
          title: const Text("Exercises"),
          children: [
            ElevatedButton.icon(
              onPressed: _addExerciseForm,
              icon: const Icon(Icons.add),
              label: const Text("Add Exercise"),
            ),
            ...exercises.map((e) => Card(
                  child: ListTile(
                    title: Text(e.name),
                    subtitle: Text("${e.duration} | ${e.caloriesBurned} kcal"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          exercises.remove(e);
                        });
                      },
                    ),
                  ),
                )),
          ],
        ),
        ExpansionTile(
          title: const Text("Challenges"),
          children: [
            ElevatedButton.icon(
              onPressed: _addChallengeForm,
              icon: const Icon(Icons.add_task),
              label: const Text("Add Challenge"),
            ),
            ...challenges.map((c) => Card(
                  child: ListTile(
                    title: Text(c.title),
                    subtitle: Text("${c.startDate} → ${c.endDate}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          challenges.remove(c);
                        });
                      },
                    ),
                  ),
                )),
          ],
        ),
        ExpansionTile(
          title: const Text("PDF Guides"),
          children: [
            ElevatedButton.icon(
              onPressed: _addGuideForm,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Upload Guide"),
            ),
            ...guides.map((g) => Card(
                  child: ListTile(
                    title: Text(g.title),
                    subtitle: Text(g.category),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          guides.remove(g);
                        });
                      },
                    ),
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget _styledField({
    required String label,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: TextField(
        maxLines: maxLines,
        style: TextStyle(color: white),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: whitet200),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.sp),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _styledNumberField({
    required String label,
    required Function(String) onChanged,
  }) {
    return _styledField(
      label: label,
      onChanged: onChanged,
      maxLines: 1,
    );
  }

  void _addExerciseForm() {
    String name = "";
    String description = "";

    String type = "Other";
    String category = "Other";
    String difficulty = "Beginner";

    int duration = 10;
    int sets = 3;
    int reps = 10;
    int restTime = 30;
    int calories = 0;

    String imageUrl = "";
    String videoUrl = "";

    List<String> equipment = [];
    List<String> muscles = [];

    final equipmentOptions = ["Dumbbell", "Barbell", "Resistance Band", "Kettlebell", "Machine", "Bodyweight"];

    final muscleOptions = ["Chest", "Back", "Legs", "Shoulders", "Biceps", "Triceps", "Core"];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0A0F0A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(18.sp),
            child: StatefulBuilder(builder: (context, setSB) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Add Exercise", style: TextStyle(color: green, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12.sp),
                    _styledField(label: "Exercise Name", onChanged: (v) => name = v),
                    _styledField(label: "Description", maxLines: 2, onChanged: (v) => description = v),
                    SizedBox(height: 12.sp),
                    _dropdown("Type", type, ["Strength", "Cardio", "Yoga", "Flexibility", "Balance", "Other"], (v) => setSB(() => type = v)),
                    _dropdown("Category", category, ["Full Body", "Upper Body", "Lower Body", "Core", "HIIT", "Endurance", "Warm-up", "Cool-down", "Other"], (v) => setSB(() => category = v)),
                    _dropdown("Difficulty", difficulty, ["Beginner", "Intermediate", "Advanced"], (v) => setSB(() => difficulty = v)),
                    _numberField("Duration (minutes)", (v) => duration = int.tryParse(v) ?? 10),
                    Divider(color: Colors.white12),
                    if (type == "Strength") ...[
                      _numberField("Sets", (v) => sets = int.tryParse(v) ?? 3),
                      _numberField("Reps", (v) => reps = int.tryParse(v) ?? 10),
                      _numberField("Rest Time (sec)", (v) => restTime = int.tryParse(v) ?? 30),
                    ],
                    SizedBox(height: 10.sp),
                    Text("Equipment", style: TextStyle(color: white)),
                    Wrap(
                      spacing: 6,
                      children: equipmentOptions.map((e) {
                        final selected = equipment.contains(e);
                        return ChoiceChip(
                          label: Text(e),
                          selected: selected,
                          onSelected: (_) {
                            setSB(() {
                              selected ? equipment.remove(e) : equipment.add(e);
                            });
                          },
                          selectedColor: green,
                          backgroundColor: Colors.grey[900],
                          labelStyle: selected ? TextStyle(color: Colors.black) : TextStyle(color: white),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10.sp),
                    Text("Target Muscles", style: TextStyle(color: white)),
                    Wrap(
                      spacing: 6,
                      children: muscleOptions.map((m) {
                        final selected = muscles.contains(m);
                        return ChoiceChip(
                          label: Text(m),
                          selected: selected,
                          onSelected: (_) {
                            setSB(() {
                              selected ? muscles.remove(m) : muscles.add(m);
                            });
                          },
                          selectedColor: green,
                          backgroundColor: Colors.grey[900],
                          labelStyle: selected ? TextStyle(color: Colors.black) : TextStyle(color: white),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10.sp),
                    _styledField(label: "Image URL", onChanged: (v) => imageUrl = v),
                    _styledField(label: "Video URL", onChanged: (v) => videoUrl = v),
                    _numberField("Calories Burned (optional)", (v) => calories = int.tryParse(v) ?? 0),
                    SizedBox(height: 18.sp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel", style: TextStyle(color: white)),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 10.sp),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
                          ),
                          onPressed: () async {
                            final exercise = Exercise(
                              id: "",
                              name: name,
                              description: description,
                              type: type,
                              category: category,
                              difficulty: difficulty,
                              duration: duration,
                              sets: sets,
                              reps: reps,
                              restTime: restTime,
                              equipment: equipment,
                              targetMuscles: muscles,
                              imageUrl: imageUrl,
                              videoUrl: videoUrl,
                              caloriesBurned: calories == 0 ? null : calories,
                            );

                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString("gym_token");

                            final result = await ExerciseService().addExercise(exercise, token!);

                            if (result["exercise"] != null) {
                              Navigator.pop(context);
                              loadData();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exercise added")));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add")));
                            }
                          },
                          child: Text("Save", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        )
                      ],
                    )
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _dropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: whitet200)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.sp),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            underline: SizedBox(),
            dropdownColor: Colors.grey[900],
            style: TextStyle(color: white),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => onChanged(v!),
          ),
        ),
        SizedBox(height: 10.sp),
      ],
    );
  }

  Widget _numberField(String label, Function(String) onChanged) {
    return _styledNumberField(label: label, onChanged: onChanged);
  }

  void _addChallengeForm() {
    String title = "";
    String description = "";
    String difficulty = "Beginner";
    int durationDays = 7;
    List<String> selectedExerciseIds = [];

    // Convert exercises to dropdown items
    List<DropdownMenuItem<String>> exerciseDropdownItems = exercises
        .map<DropdownMenuItem<String>>(
          (e) => DropdownMenuItem(
            value: e.id,
            child: Text(e.name, style: TextStyle(color: white)),
          ),
        )
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0A0F0A),
          insetPadding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(18.sp),
            child: StatefulBuilder(
              builder: (context, setSB) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add Challenge",
                        style: TextStyle(
                          color: green,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 12.sp),

                      // Title
                      _styledField(
                        label: "Title",
                        onChanged: (v) => title = v,
                      ),

                      // Description
                      _styledField(
                        label: "Description",
                        maxLines: 2,
                        onChanged: (v) => description = v,
                      ),

                      SizedBox(height: 12.sp),

                      // Difficulty dropdown
                      Text("Difficulty", style: TextStyle(color: whitet200)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.sp),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                        child: DropdownButton<String>(
                          dropdownColor: Colors.grey[900],
                          isExpanded: true,
                          value: difficulty,
                          underline: SizedBox(),
                          style: TextStyle(color: white),
                          items: ["Beginner", "Intermediate", "Advanced"]
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d, style: TextStyle(color: white)),
                                  ))
                              .toList(),
                          onChanged: (v) => setSB(() => difficulty = v!),
                        ),
                      ),

                      SizedBox(height: 12.sp),

                      // Duration (Days)
                      _styledField(
                        label: "Duration (days)",
                        onChanged: (v) => durationDays = int.tryParse(v) ?? 7,
                      ),

                      SizedBox(height: 12.sp),

                      // Exercises multi-select
                      Text("Assign Exercises", style: TextStyle(color: whitet200)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.sp),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(border: InputBorder.none),
                          dropdownColor: Colors.black,
                          items: exerciseDropdownItems,
                          onChanged: (val) {
                            if (val != null && !selectedExerciseIds.contains(val)) {
                              setSB(() => selectedExerciseIds.add(val));
                            }
                          },
                          hint: Text("Select Exercise", style: TextStyle(color: white)),
                        ),
                      ),

                      if (selectedExerciseIds.isNotEmpty) ...[
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: selectedExerciseIds.map((id) {
                            final ex = exercises.firstWhere((e) => e.id == id);
                            return Chip(
                              backgroundColor: Colors.grey[800],
                              label: Text(ex.name, style: TextStyle(color: Colors.white)),
                              deleteIcon: Icon(Icons.close, size: 16),
                              onDeleted: () => setSB(() => selectedExerciseIds.remove(id)),
                            );
                          }).toList(),
                        )
                      ],

                      SizedBox(height: 18.sp),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel", style: TextStyle(color: white)),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: green,
                              padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 10.sp),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                            ),
                            onPressed: () async {
                              final challengeData = {
                                "title": title,
                                "description": description,
                                "difficulty": difficulty,
                                "durationDays": durationDays,
                                "exercises": selectedExerciseIds,
                              };

                              final token = await SharedPreferences.getInstance().then((prefs) => prefs.getString("gym_token"));

                              final result = await ChallengeService().createChallenge(
                                challengeData,
                              );

                              if (result) {
                                Navigator.pop(context);
                                loadData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Challenge created!"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error adding challenges!'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _addGuideForm() {
    String title = "";
    String category = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Guide"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Title"),
                onChanged: (val) => title = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Category"),
                onChanged: (val) => category = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  guides.add(Guide(
                    title: title,
                    category: category,
                    pdfUrl: "", id: '', duration: '', // will be updated when file upload is added
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  void _addMemberForm() {
    String email = "";
    String phone = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Add Member", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Email"),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => email = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Phone"),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => phone = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final service = GymOwnerService();
              final success = await service.addMember(email, phone);

              if (success) Navigator.pop(context);
            },
            child: const Text("Add", style: TextStyle(color: Colors.green)),
          )
        ],
      ),
    );
  }

  // 📌 User Manager
  Widget _buildUserManager() {
    return const Center(
      child: Text("User management UI same as before"),
    );
  }
}
