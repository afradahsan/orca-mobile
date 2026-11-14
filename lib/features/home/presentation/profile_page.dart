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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of OS CLUB?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authRepo = AuthRepo(authServices: AuthServices());
      await authRepo.signOut();

      if (mounted) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await auth.logout();
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const GetStarted(),
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
        color: surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: surfaceBorder),
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
              color: Colors.white60,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withOpacity(0.12),
        highlightColor: color.withOpacity(0.06),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: surfaceBorder),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final String displayName = (auth.userName != null && auth.userName!.trim().isNotEmpty)
        ? auth.userName!.trim()
        : "Athlete";

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(18.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  CircleAvatar(
                    radius: 24.sp,
                    backgroundColor: surfaceBorder,
                    backgroundImage: const AssetImage('assets/images/gym.png'),
                  ),
                  SizedBox(width: 12.sp),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "OS Club Member",
                        style: TextStyle(
                          color: green,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const NotificationBell(),
                ],
              ),

              SizedBox(height: 20.sp),

              /// FITNESS SNAPSHOT
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF10151E),
                  border: Border.all(color: surfaceBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            "72 kg",
                            "Current Weight",
                            Icons.person_outline,
                            green,
                          ),
                        ),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: _metricCard(
                            "22.1",
                            "BMI Index",
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
                            Icons.local_fire_department,
                            Colors.orangeAccent,
                          ),
                        ),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: _metricCard(
                            "Pro Tier",
                            "Membership",
                            Icons.verified,
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
                  color: surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: green, size: 24),
                    SizedBox(width: 10.sp),
                    Expanded(
                      child: Text(
                        "You crushed your workouts today 🔥",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
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
                  fontSize: 16.sp,
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
                          builder: (_) => const MyOrders(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    Icons.card_membership_rounded,
                    "Subscriptions",
                    Colors.blueAccent,
                    () {},
                  ),
                  _buildActionCard(
                    Icons.favorite_outline_rounded,
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

              SizedBox(height: 28.sp),

              /// LOGOUT
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _logout,
                  borderRadius: BorderRadius.circular(14),
                  splashColor: Colors.red.withOpacity(0.18),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 14.sp,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: Colors.redAccent),
                        SizedBox(width: 8.sp),
                        const Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
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
