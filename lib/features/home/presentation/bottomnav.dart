import 'package:flutter/material.dart';
import 'package:orca/core/utils/bottom_sheet.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/ecom/presentation/ecom_page.dart';
import 'package:orca/features/fitness/data/role_provider.dart';
import 'package:orca/features/fitness/presentations/account_fitness.dart';
import 'package:orca/features/fitness/presentations/fitness_page.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final CustomDrawerController _drawerController = CustomDrawerController();
  final ValueNotifier<Widget> _drawerContentNotifier = ValueNotifier(const SizedBox());

  final tabs = [
    // {'icon': Icons.auto_fix_high, 'label': 'Club'},
    {'icon': Icons.shopping_bag_rounded, 'label': 'Merch'},
    {'icon': Icons.fitness_center_rounded, 'label': 'EFC'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this, initialIndex: widget.initialTabIndex);
    debugPrint('Tab not called');
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final role = Provider.of<RoleProvider>(context, listen: false).role;

    //   _tabController.addListener(() {
    //     if (_tabController.index == 1 && role == '') {
    //       debugPrint('Tab: ${_tabController.index}');
    //       Future.microtask(() {
    //         _tabController.index = 1;
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (_) => AccountFitness(),
    //           ),
    //         );
    //       });
    //     } else {
    //       debugPrint('Tab changed to: ${_tabController.index}');
    //     }
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_drawerController.isOpen) {
            _drawerController.close();
            return false;
          }
          return true;
        },
        child: CustomDrawer(
            controller: _drawerController,
            backgroundColor: darkgreen,
            minHeight: 0.0,
            maxHeight: 0.92,
            mainContent: _buildMainContent(),
            drawerContent: ValueListenableBuilder(
              valueListenable: _drawerContentNotifier,
              builder: (context, value, _) => value,
            )));
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  EcomPage(),
                  FitnessPage(),
                ],
              ),
            ),
            Container(
              height: 35.sp,
              color: darkgreen,
              child: TabBar(
                controller: _tabController,
                labelColor: green,
                unselectedLabelColor: whitet150,
                indicator: const BoxDecoration(),
                onTap: (index) {
                  final role = Provider.of<RoleProvider>(context, listen: false).role;
                    _tabController.animateTo(index);
                },
                tabs: tabs.asMap().entries.map((entry) {
                  int index = entry.key;
                  var tab = entry.value;

                  if (index == 2) {
                    return Tab(
                      iconMargin: EdgeInsets.only(bottom: 8.sp),
                      icon: Container(
                          width: 21.sp,
                          height: 21.sp,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: white,
                              width: 4.sp,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Container(
                            width: 25.sp,
                            height: 25.sp,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/spiti.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          )),
                      text: tab['label'] as String,
                    );
                  } else {
                    return Tab(
                      icon: Icon(tab['icon'] as IconData),
                      text: tab['label'] as String,
                    );
                  }
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
