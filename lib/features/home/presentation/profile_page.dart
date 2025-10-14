import 'package:flutter/material.dart';
import 'package:orca/features/auth/data/auth_services.dart';
import 'package:orca/features/auth/domain/auth_repo.dart';
import 'package:orca/features/auth/presentation/get_started.dart';
import 'package:orca/features/auth/presentation/signup_page.dart';
import 'package:sizer/sizer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<Map<String, dynamic>> orders = [
    {"image": "assets/images/gym.png", "title": "Whey Protein (1kg)", "price": "₹1499", "status": "Delivered"},
    {"image": "assets/images/gym.png", "title": "Resistance Bands Set", "price": "₹799", "status": "In Transit"},
    {"image": "assets/images/gym.png", "title": "Fitness Gloves", "price": "₹499", "status": "Cancelled"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(18.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Header ----------
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
                        "Hey Afrad 👋",
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
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20.sp),

              // ---------- Membership Card ----------
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.sp),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gold Membership",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.sp),
                    Text(
                      "Valid till: 30 Dec 2025",
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                    SizedBox(height: 12.sp),
                    LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: Colors.white24,
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      "70% progress to next tier",
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.sp),

              // ---------- Quick Actions ----------
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
                  _buildActionCard(Icons.shopping_bag_outlined, "My Orders", Colors.greenAccent, () {}),
                  _buildActionCard(Icons.card_membership, "My Subscriptions", Colors.blueAccent, () {}),
                  _buildActionCard(Icons.favorite_outline, "Saved Workouts", Colors.pinkAccent, () {}),
                  _buildActionCard(Icons.settings_outlined, "Settings", Colors.orangeAccent, () {}),
                ],
              ),

              SizedBox(height: 30.sp),

              // ---------- Orders Section ----------
              Text(
                "My Orders",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.sp),

              Column(
                children: orders.map((order) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.sp),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(order['image'], width: 42, height: 42, fit: BoxFit.cover),
                      ),
                      title: Text(
                        order['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                      subtitle: Text(
                        order['price'],
                        style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
                      ),
                      trailing: Text(
                        order['status'],
                        style: TextStyle(
                          color: order['status'] == "Delivered"
                              ? Colors.greenAccent
                              : order['status'] == "In Transit"
                                  ? Colors.orangeAccent
                                  : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 20.sp),

              // ---------- Logout ----------
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 10.sp),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final authRepo = AuthRepo(authServices: AuthServices());
                      await authRepo.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                          return GetStarted();
                        },),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Logout", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, Color color, VoidCallback onTap) {
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
            SizedBox(height: 6.sp),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
