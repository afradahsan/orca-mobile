import 'package:flutter/material.dart';

class GymOwnerPage extends StatefulWidget {
  const GymOwnerPage({super.key});

  @override
  State<GymOwnerPage> createState() => _GymOwnerPageState();
}

class _GymOwnerPageState extends State<GymOwnerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> exercises = [];
  List<Map<String, dynamic>> guides = [];
  List<Map<String, dynamic>> challenges = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Fitness Content"),
            Tab(text: "User Access"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContentManager(),
          _buildUserManager(),
        ],
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
                    title: Text(e["title"]),
                    subtitle: Text("${e["duration"]} | ${e["calories"]} kcal"),
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
                    title: Text(c["title"]),
                    subtitle: Text("${c["startDate"]} → ${c["endDate"]}"),
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
                    title: Text(g["title"]),
                    subtitle: Text(g["category"]),
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

  void _addExerciseForm() {
    String title = "";
    String duration = "";
    String calories = "";
    String difficulty = "Beginner";
    String description = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateSB) {
          return AlertDialog(
            title: const Text("Add Exercise"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: "Title"),
                    onChanged: (val) => title = val,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Duration (e.g. 12 min)"),
                    onChanged: (val) => duration = val,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Calories Burned"),
                    onChanged: (val) => calories = val,
                  ),
                  DropdownButton<String>(
                    value: difficulty,
                    items: ["Beginner", "Intermediate", "Advanced"]
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) => setStateSB(() => difficulty = val!),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Description"),
                    onChanged: (val) => description = val,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    exercises.add({
                      "title": title,
                      "duration": duration,
                      "calories": calories,
                      "difficulty": difficulty,
                      "description": description,
                    });
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              )
            ],
          );
        });
      },
    );
  }

  void _addChallengeForm() {
    String title = "";
    String desc = "";
    String startDate = "";
    String endDate = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Challenge"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Title"),
                onChanged: (val) => title = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Description"),
                onChanged: (val) => desc = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Start Date"),
                onChanged: (val) => startDate = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "End Date"),
                onChanged: (val) => endDate = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  challenges.add({
                    "title": title,
                    "desc": desc,
                    "startDate": startDate,
                    "endDate": endDate,
                  });
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
                  guides.add({
                    "title": title,
                    "category": category,
                  });
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

  // 📌 User Manager
  Widget _buildUserManager() {
    return const Center(
      child: Text("User management UI same as before"),
    );
  }
}
