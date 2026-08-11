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
import 'package:orca/features/notifications/domain/notification_provider.dart';
import 'package:orca/features/notifications/data/push_notification_service.dart';
import 'package:orca/features/notifications/presentation/notification_bell.dart';
import 'package:orca/features/notifications/presentation/notification_center.dart';
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
  int _selectedTab = 0; // 0: Exercises, 1: Members, 2: Challenges, 3: Guides, 4: Announcements Log

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
    final notifProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 8.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1️⃣ Header Bar with Title, Bell & Logout
                _buildAdminHeader(),
                SizedBox(height: 14.sp),

                // 2️⃣ Hero Push Announcement Card
                _buildHeroPushCard(),
                SizedBox(height: 16.sp),

                // 3️⃣ Metrics Overview 2x2 Grid
                _buildMetricsGrid(notifProvider.notifications.length),
                SizedBox(height: 18.sp),

                // 4️⃣ Segmented Tab Bar Navigation
                _buildSegmentedTabNav(),
                SizedBox(height: 14.sp),

                // 5️⃣ Active Tab Section Header (+ Add Button)
                _buildActiveTabHeader(),
                SizedBox(height: 10.sp),

                // 6️⃣ Active Content Display
                _buildActiveTabContent(notifProvider),
                SizedBox(height: 24.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Portal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'ORCA Fitness Control Center',
              style: TextStyle(
                color: green,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const NotificationBell(),
            SizedBox(width: 8.sp),
            GestureDetector(
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const GetStarted()),
                  (route) => false,
                );
              },
              child: Container(
                padding: EdgeInsets.all(6.sp),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                ),
                child: Icon(Icons.logout, color: Colors.redAccent, size: 16.sp),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroPushCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [green.withOpacity(0.25), Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: green.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              color: green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.campaign_rounded, color: green, size: 24.sp),
          ),
          SizedBox(width: 12.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push In-App Announcement',
                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.sp),
                Text(
                  'Broadcast competitions, workouts & news to users',
                  style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.sp),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
            ),
            onPressed: _sendNotificationForm,
            icon: const Icon(Icons.send_rounded, color: Colors.black, size: 14),
            label: Text(
              'Push',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(int notifCount) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10.sp,
      mainAxisSpacing: 10.sp,
      childAspectRatio: 2.4,
      children: [
        _metricTile('Exercises', '${exercises.length}', Icons.fitness_center, green, 0),
        _metricTile('Members', '${memberUsers.length}', Icons.people_alt, Colors.cyanAccent, 1),
        _metricTile('Challenges', '${challenges.length}', Icons.emoji_events, Colors.amber, 2),
        _metricTile('Broadcasts', '$notifCount', Icons.notifications_active, Colors.purpleAccent, 4),
      ],
    );
  }

  Widget _metricTile(String label, String value, IconData icon, Color color, int tabIndex) {
    final isSelected = _selectedTab == tabIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey[900],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.sp),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16.sp),
            ),
            SizedBox(width: 8.sp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTabNav() {
    final tabs = [
      {'label': 'Exercises', 'icon': Icons.fitness_center},
      {'label': 'Members', 'icon': Icons.people},
      {'label': 'Challenges', 'icon': Icons.emoji_events},
      {'label': 'Guides', 'icon': Icons.menu_book},
      {'label': 'Log', 'icon': Icons.history},
    ];

    return SizedBox(
      height: 34.sp,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: EdgeInsets.only(right: 8.sp),
            child: ChoiceChip(
              avatar: Icon(
                tabs[index]['icon'] as IconData,
                size: 13.sp,
                color: isSelected ? Colors.black : Colors.white70,
              ),
              label: Text(tabs[index]['label'] as String),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedTab = index),
              selectedColor: green,
              backgroundColor: Colors.grey[900],
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 10.sp,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? green : Colors.white12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveTabHeader() {
    String title = "";
    VoidCallback? onAdd;
    String addLabel = "+ Add";

    switch (_selectedTab) {
      case 0:
        title = "Exercises (${exercises.length})";
        onAdd = _addExerciseForm;
        addLabel = "+ Exercise";
        break;
      case 1:
        title = "Gym Members (${memberUsers.length})";
        onAdd = _addMemberForm;
        addLabel = "+ Member";
        break;
      case 2:
        title = "Challenges (${challenges.length})";
        onAdd = _addChallengeForm;
        addLabel = "+ Challenge";
        break;
      case 3:
        title = "PDF Guides (${guides.length})";
        onAdd = _addGuideForm;
        addLabel = "+ Guide";
        break;
      case 4:
        title = "Broadcast History";
        onAdd = _sendNotificationForm;
        addLabel = "+ Push Alert";
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onAdd != null)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
            ),
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Colors.black, size: 14),
            label: Text(
              addLabel,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10.sp),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveTabContent(NotificationProvider notifProvider) {
    switch (_selectedTab) {
      case 0:
        return _buildExercisesList();
      case 1:
        return _buildMembersList();
      case 2:
        return _buildChallengesList();
      case 3:
        return _buildGuidesList();
      case 4:
        return _buildAnnouncementsList(notifProvider);
      default:
        return const SizedBox();
    }
  }

  Widget _buildEmptyState(String message, IconData icon, VoidCallback? onAction, String? actionLabel) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.sp),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white24, size: 36.sp),
          SizedBox(height: 10.sp),
          Text(
            message,
            style: TextStyle(color: Colors.white60, fontSize: 12.sp),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionLabel != null) ...[
            SizedBox(height: 12.sp),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    if (exercises.isEmpty) {
      return _buildEmptyState("No exercises added yet", Icons.fitness_center, _addExerciseForm, "+ Add Exercise");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final e = exercises[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8.sp),
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fitness_center, color: green, size: 18.sp),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name ?? 'Exercise',
                      style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      "${e.duration ?? 0} sec | ${e.category ?? 'General'}",
                      style: TextStyle(color: Colors.white60, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    exercises.removeAt(index);
                  });
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembersList() {
    if (memberUsers.isEmpty) {
      return _buildEmptyState("No members added yet", Icons.person_off, _addMemberForm, "+ Add Member");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: memberUsers.length,
      itemBuilder: (context, index) {
        final m = memberUsers[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8.sp),
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                child: Icon(Icons.person, color: Colors.cyanAccent, size: 18.sp),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.name,
                      style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      m.email.isNotEmpty ? m.email : (m.phone ?? 'No contact'),
                      style: TextStyle(color: Colors.white60, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                decoration: BoxDecoration(
                  color: green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Member',
                  style: TextStyle(color: green, fontSize: 9.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChallengesList() {
    if (challenges.isEmpty) {
      return _buildEmptyState("No active challenges yet", Icons.emoji_events_outlined, _addChallengeForm, "+ Add Challenge");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final c = challenges[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8.sp),
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events, color: Colors.amber, size: 18.sp),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.title,
                      style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      "Difficulty: ${c.difficulty}",
                      style: TextStyle(color: Colors.white60, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuidesList() {
    if (guides.isEmpty) {
      return _buildEmptyState("No PDF guides uploaded yet", Icons.menu_book, _addGuideForm, "+ Upload Guide");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: guides.length,
      itemBuilder: (context, index) {
        final g = guides[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8.sp),
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.picture_as_pdf, color: Colors.purpleAccent, size: 18.sp),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.title,
                      style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      "Category: ${g.category}",
                      style: TextStyle(color: Colors.white60, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementsList(NotificationProvider notifProvider) {
    final list = notifProvider.notifications;
    if (list.isEmpty) {
      return _buildEmptyState("No notifications pushed yet", Icons.notifications_none, _sendNotificationForm, "+ Push Alert");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final n = list[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8.sp),
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: green.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.campaign, color: green, size: 18.sp),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      n.message,
                      style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                    ),
                    SizedBox(height: 4.sp),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                          decoration: BoxDecoration(
                            color: green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            n.category,
                            style: TextStyle(color: green, fontSize: 8.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${n.createdAt.hour}:${n.createdAt.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(color: Colors.white38, fontSize: 8.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  void _sendNotificationForm() {
    String title = "";
    String message = "";
    String category = "Competition";
    String actionTarget = "competitions";

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
            child: StatefulBuilder(
              builder: (context, setSB) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.campaign, color: green, size: 20.sp),
                          SizedBox(width: 8.sp),
                          Text(
                            "Push Announcement",
                            style: TextStyle(
                              color: green,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.sp),
                      _styledField(
                        label: "Title (e.g. New Competition!)",
                        onChanged: (v) => title = v,
                      ),
                      _styledField(
                        label: "Message Body / Details",
                        maxLines: 3,
                        onChanged: (v) => message = v,
                      ),
                      SizedBox(height: 10.sp),
                      _dropdown(
                        "Category",
                        category,
                        ["Competition", "Fitness", "General", "Merch"],
                        (v) => setSB(() {
                          category = v;
                          if (v == "Competition") actionTarget = "competitions";
                          else if (v == "Fitness") actionTarget = "fitness";
                          else if (v == "Merch") actionTarget = "ecom";
                          else actionTarget = "";
                        }),
                      ),
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
                              if (title.trim().isEmpty || message.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter both title and message")),
                                );
                                return;
                              }

                              final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
                              await notifProvider.addNotification(
                                title: title.trim(),
                                message: message.trim(),
                                category: category,
                                actionTarget: actionTarget.isNotEmpty ? actionTarget : null,
                              );

                              // Trigger Device System Tray & Lock-Screen Push Alert
                              await PushNotificationService.instance.showLocalNotification(
                                title: title.trim(),
                                body: message.trim(),
                                payload: actionTarget.isNotEmpty ? actionTarget : null,
                              );

                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.black),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Notification pushed: '$title'",
                                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: green,
                                    duration: const Duration(seconds: 4),
                                    action: SnackBarAction(
                                      label: "VIEW LIVE",
                                      textColor: Colors.black,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const NotificationCenter(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text("Push Now", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
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

  // 📌 User Manager
  Widget _buildUserManager() {
    return const Center(
      child: Text("User management UI same as before"),
    );
  }
}
