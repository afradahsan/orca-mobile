import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:orca/core/utils/bottom_sheet.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/competitions/presentations/competitions_page.dart';
import 'package:orca/features/ecom/presentation/ecom_page.dart';
import 'package:orca/features/fitness/presentations/fitness_page.dart';
import 'package:orca/features/home/presentation/profile_page.dart';
import 'package:sizer/sizer.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({super.key, this.initialTabIndex = 0, this.token});

  final int initialTabIndex;
  final String? token;

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final CustomDrawerController _drawerController = CustomDrawerController();
  final ValueNotifier<Widget> _drawerContentNotifier = ValueNotifier(const SizedBox());
  late ScrollController _scrollController;
  bool _isNavBarVisible = true;

  final tabs = [
    {'icon': "assets/images/shopping-bag.png", 'label': 'Merch'},
    {'icon': "assets/images/dumbbells.png", 'label': 'EFC'},
    {'icon': "assets/images/winner-medal.png", 'label': 'Competitions'},
    {'icon': "assets/images/people.png", 'label': 'Profile'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this, initialIndex: widget.initialTabIndex);

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isNavBarVisible) {
          setState(() => _isNavBarVisible = false);
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isNavBarVisible) {
          setState(() => _isNavBarVisible = true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: AnimatedSwitcher(
              duration:  const Duration(milliseconds: 100),
              child: TabBarView(
                controller: _tabController,
                children: [
                  EcomPage(),
                  FitnessPage(
                    token: widget.token,
                  ),
                  CompetitionsPage(drawerController: CustomDrawerController(), drawerContentNotifier: _drawerContentNotifier),
                  ProfilePage(
                    token: widget.token
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _isNavBarVisible ? const Offset(0, 0) : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isNavBarVisible ? 1 : 0,
                child: _buildNavBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      height: 64,
      width: double.infinity,
      color: const Color(0xFF1C1C1C), // flat dark bar
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(tabs.length, (index) {
          final isSelected = _tabController.index == index;

          return GestureDetector(
            onTap: () => setState(() => _tabController.index = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? green : Colors.transparent,
                borderRadius: BorderRadius.circular(12), // subtle only for active
              ),
              child: Row(
                children: [
                  Image.asset(
                    tabs[index]['icon']!,
                    width: 22,
                    height: 22,
                    color: isSelected ? Colors.black : Colors.white60,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      tabs[index]['label']!,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
