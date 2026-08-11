import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/auth_services.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/auth/domain/auth_repo.dart';
import 'package:orca/features/auth/presentation/get_started.dart';
import 'package:orca/features/home/presentation/my_orders.dart';
import 'package:orca/features/notifications/presentation/notification_bell.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({required this.token, super.key});

  final String token;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _logout() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authRepo = AuthRepo(authServices: AuthServices());
      await authRepo.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => GetStarted(),
        ),
        (route) => false,
      );
    }
  }

  Widget _metricCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12.sp,
        horizontal: 10.sp,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16.sp,
              ),
              SizedBox(width: 7.sp),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.sp),
          Text(
            label,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8.sp),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('token: ${widget.token}');
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(18.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  CircleAvatar(
                    radius: 24.sp,
                    backgroundImage: const AssetImage('assets/images/gym.png'),
                  ),
                  SizedBox(width: 12.sp),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Afrad",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Gym Member • Since 2024",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const NotificationBell(),
                  SizedBox(width: 8.sp),
                  Icon(
                    Icons.edit_outlined,
                    color: Colors.white54,
                    size: 20.sp,
                  ),
                ],
              ),

              SizedBox(height: 20.sp),

              /// FITNESS SNAPSHOT
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF171717),
                      const Color(0xFF101010),
                    ],
                  ),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            "72 kg",
                            "Current Weight",
                            Icons.person,
                            green,
                          ),
                        ),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: _metricCard(
                            "22.1",
                            "BMI",
                            Icons.auto_graph,
                            Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.sp),
                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            "14 Days",
                            "Workout Streak",
                            Icons.fitness_center,
                            Colors.orangeAccent,
                          ),
                        ),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: _metricCard(
                            "Gold",
                            "Membership",
                            Icons.card_membership,
                            Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.sp),

              /// TODAY STATUS
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.sp),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, color: green),
                    SizedBox(width: 10.sp),
                    Expanded(
                      child: Text(
                        "You logged 3 workouts today 🔥",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.sp),

              /// GYM IDENTITY
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.sp),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.025),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Row(
                  children: [
                    Icon(Icons.fitness_center, color: green),
                    SizedBox(width: 10.sp),
                    Text(
                      "Member at Trounce Pulstion",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.sp),

              /// QUICK ACTIONS
              Text(
                "Quick Actions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12.sp),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 3 / 2.3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildActionCard(
                    Icons.shopping_bag_outlined,
                    "My Orders",
                    Colors.greenAccent,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MyOrders(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    Icons.card_membership,
                    "Subscriptions",
                    Colors.blueAccent,
                    () {},
                  ),
                  _buildActionCard(
                    Icons.favorite_outline,
                    "Saved Workouts",
                    Colors.pinkAccent,
                    () {},
                  ),
                  _buildActionCard(
                    Icons.settings_outlined,
                    "Settings",
                    Colors.orangeAccent,
                    () {},
                  ),
                ],
              ),

              SizedBox(height: 24.sp),

              /// PROFILE COMPLETION
              Text(
                "Profile Completion",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                ),
              ),

              SizedBox(height: 8.sp),

              LinearProgressIndicator(
                value: 0.75,
                backgroundColor: Colors.white12,
                color: green,
                borderRadius: BorderRadius.circular(10),
              ),

              SizedBox(height: 6.sp),

              Text(
                "75% complete",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11.sp,
                ),
              ),

              SizedBox(height: 28.sp),

              /// LOGOUT
              GestureDetector(
                onTap: _logout,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 14.sp,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent),
                      SizedBox(width: 8.sp),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
