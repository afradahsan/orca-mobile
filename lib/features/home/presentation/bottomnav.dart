import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:orca/core/utils/bottom_sheet.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/competitions/presentations/competitions_page.dart';
import 'package:orca/features/ecom/presentation/ecom_page.dart';
import 'package:orca/features/fitness/presentations/fitness_page.dart';
import 'package:orca/features/home/presentation/home_page.dart';
import 'package:orca/features/home/presentation/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex;

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<Widget> _drawerContentNotifier = ValueNotifier(const SizedBox());
  late ScrollController _scrollController;
  bool _isNavBarVisible = true;

  final List<Map<String, dynamic>> tabs = [
    {'isMaterialIcon': true, 'icon': Icons.home_rounded, 'label': 'Home'},
    {'isMaterialIcon': false, 'icon': "assets/images/shopping-bag.png", 'label': 'Merch'},
    {'isMaterialIcon': false, 'icon': "assets/images/dumbbells.png", 'label': 'EFC'},
    {'isMaterialIcon': false, 'icon': "assets/images/winner-medal.png", 'label': 'Competitions'},
    {'isMaterialIcon': false, 'icon': "assets/images/people.png", 'label': 'Profile'},
  ];

  String? token = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this, initialIndex: widget.initialTabIndex);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    token = auth.token ?? '';

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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: TabBarView(
                controller: _tabController,
                physics: const ClampingScrollPhysics(),
                children: [
                  HomePage(
                    onTabSelected: (index) {
                      setState(() {
                        _tabController.index = index;
                      });
                    },
                  ),
                  EcomPage(
                    token: token,
                  ),
                  FitnessPage(
                    token: token,
                  ),
                  CompetitionsPage(
                      drawerController: CustomDrawerController(),
                      drawerContentNotifier: _drawerContentNotifier),
                  ProfilePage(token: token ?? ''),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              offset: _isNavBarVisible ? const Offset(0, 0) : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
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
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        border: Border(top: BorderSide(color: Color(0xFF242424), width: 1)),
      ),
      child: Center(
        child: SizedBox(
          height: 52,
          child: TabBar(
            controller: _tabController,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: green, width: 3),
              insets: EdgeInsets.only(bottom: 52 - 3),
            ),
            labelColor: green,
            unselectedLabelColor: Colors.white,
            tabs: tabs.map((tab) {
              return Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    tab['isMaterialIcon']
                        ? Icon(tab['icon'], size: 24)
                        : Image.asset(
                            tab['icon'],
                            width: 24,
                            height: 24,
                            color: _tabController.index == tabs.indexOf(tab) ? green : Colors.white,
                          ),
                    const SizedBox(height: 2),
                    Text(
                      tab['label'],
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
