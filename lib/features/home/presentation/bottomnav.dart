import 'package:flutter/material.dart';
import 'package:orca/core/utils/bottom_sheet.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/community/presentation/community_page.dart';
import 'package:orca/features/home/presentation/home_page.dart';
import 'package:sizer/sizer.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({super.key});

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final CustomDrawerController _drawerController = CustomDrawerController();
  final ValueNotifier<Widget> _drawerContentNotifier = ValueNotifier(const SizedBox());

  final tabs = [
    {'icon': Icons.auto_fix_high, 'label': 'For you'},
    {'icon': Icons.emoji_events_rounded, 'label': 'Events'},
    {'icon': Icons.fitness_center_rounded, 'label': 'Fitness'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      controller: _drawerController,
      backgroundColor: darkgreen,
      minHeight: 0.0,
      maxHeight: 0.92,
      mainContent: _buildMainContent(),
      drawerContent: ValueListenableBuilder(
        valueListenable: _drawerContentNotifier,
        builder: (context, value, _) => value,
      ),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: whitet50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: whitet150),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Search for events, restaurants, movies...",
                        style: TextStyle(color: whitet150, fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                color: darkgreen,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: green,
                  unselectedLabelColor: whitet150,
                  indicator: const BoxDecoration(),
                  dividerColor: Colors.transparent,
                  tabAlignment: TabAlignment.center,
                  tabs: tabs.map((tab) {
                    return Tab(
                      icon: Icon(tab['icon'] as IconData),
                      text: tab['label'] as String,
                    );
                  }).toList(),
                ),
              ),
            ),

            // TabBarView Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const HomePage(),
                  CommunityPage(
                    drawerController: _drawerController,
                    drawerContentNotifier: _drawerContentNotifier,
                  ),
                  Center(child: Text("Fitness", style: TextStyle(color: white))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
