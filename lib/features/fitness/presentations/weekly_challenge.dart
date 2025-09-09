import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:sizer/sizer.dart';

class WeeklyChallenge extends StatelessWidget {
  const WeeklyChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Weekly Challenge',
          style: TextStyle(color: white, fontFamily: GoogleFonts.bebasNeue().fontFamily, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){}, child: Text('JOIN CHALLENGE'),),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _challengeHeader(),
            SizedBox(height: 3.h),
            _progressTracker(),
            SizedBox(height: 2.h),
            const Divider(color: Colors.white24),
            SizedBox(height: 2.h),
            Expanded(child: _dailyTasks()),
          ],
        ),
      ),
    );
  }

  Widget _challengeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🔥 This Weeks Challenge', style: TextStyle(fontSize: 14.sp, color: Colors.white70)),
        SizedBox(height: 0.5.h),
        Text('Complete 5 workouts in 7 days', style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 1.h),
        Row(
          children: [
            const Icon(Icons.timer, color: Colors.orangeAccent),
            SizedBox(width: 1.w),
            Text('Ends in 3d 4h', style: TextStyle(color: Colors.orangeAccent, fontSize: 14.sp, fontFamily: GoogleFonts.bebasNeue().fontFamily, letterSpacing: 2))
          ],
        )
      ],
    );
  }

  Widget _progressTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Progress', style: TextStyle(fontSize: 18.sp, color: Colors.white, fontFamily: GoogleFonts.bebasNeue().fontFamily, letterSpacing: 2)),
        SizedBox(height: 1.h),
        Stack(
          children: [
            Container(
              height: 15,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            Container(
              height: 15,
              width: 60.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.greenAccent, Colors.lightGreen]),
                borderRadius: BorderRadius.circular(30),
              ),
            )
          ],
        ),
        SizedBox(height: 1.h),
        Text('3 of 5 done', style: TextStyle(color: Colors.white54))
      ],
    );
  }

  Widget _dailyTasks() {
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (_, __) => const Divider(color: Colors.transparent),
      itemBuilder: (context, index) {
        // final item = days[index];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 14.sp),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white38, width: 3.sp),
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/images/gym.png'),
              ),
              sizedwten(context),
              Text('Chest Day', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.bebasNeue().fontFamily, letterSpacing: 1)),
              Spacer(),
              Icon(Icons.check_circle, color: Colors.greenAccent, size: 20.sp),
              sizedwfive(context)
            ],
          ),
        );
      },
    );
  }
}
