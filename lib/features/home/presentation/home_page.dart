import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 1;
  double progress = 0.2;

  void _onIconTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Recommendations', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('View All', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  Icon(
                    Icons.arrow_right,
                    size: 20.sp,
                    color: green,
                  )
                ],
              ),
              SizedBox(height: 12.sp),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildWorkoutCard(
                      "assets/images/gym.png",
                      "Squat Exercise",
                      "12 Min",
                      "120 Kcal",
                    ),
                    const SizedBox(width: 16),
                    _buildWorkoutCard(
                      "assets/images/gym.png",
                      "Full Body Stretching",
                      "12 Min",
                      "120 Kcal",
                    ),
                  ],
                ),
              ),
              sizedtwenty(context),
              Text('Weekly Challenge', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 12.sp),
              Stack(
                children: [
                  Container(
                    height: 57.sp,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/challenge.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Container(
                      height: 57.sp,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 16.sp, left: 14.sp),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('2/10 Complete - 20%', style: TextStyle(color: Colors.white, letterSpacing: 1)),
                                      SizedBox(
                                        height: 10.sp,
                                      ),
                                      SizedBox(
                                        width: 66.sp,
                                        child: LinearProgressIndicator(
                                          borderRadius: BorderRadius.circular(16),
                                          value: progress,
                                          backgroundColor: green.withOpacity(0.4),
                                          valueColor: AlwaysStoppedAnimation<Color>(green),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12.sp, right: 14.sp),
                                  child: Icon(Icons.arrow_forward, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ],
              ),
              sizedtwenty(context),
              Text('Fitness Guide', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 12.sp,
              ),
              Container(
                width: 48.sp, // Adjust width
                height: 54.sp,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/challenge.png',
                        width: double.infinity,
                        height: 48.sp,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Star Icon (Favorite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.bookmark,
                        color: green,
                        size: 24,
                      ),
                    ),

                    // Title Text
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Text(
                        'Calisthenics Workout!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(
    String imagePath,
    String title,
    String duration,
    String calories,
  ) {
    return Container(
      width: 53.sp,
      height: 52.sp,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  imagePath,
                  width: 54.sp,
                  height: 40.sp,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8.sp,
                right: 10.sp,
                child: Icon(
                  Icons.star_border_rounded,
                  color: const Color(0xFFFFE600),
                ),
              ),
              // Positioned(
              //   bottom: -12.sp,
              //   right: 10.sp,
              //   child: Container(
              //     padding: const EdgeInsets.all(6),
              //     decoration: BoxDecoration(
              //       color: Colors.purple,
              //       shape: BoxShape.circle,
              //     ),
              //     child: Icon(Icons.play_arrow, color: Colors.white),
              //   ),
              // ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                color: Color(0xFFD6FF00),
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.purple, size: 16),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 12),
                Icon(Icons.local_fire_department, color: Colors.purple, size: 16.sp),
                const SizedBox(width: 4),
                Text(
                  calories,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
