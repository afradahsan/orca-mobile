import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/fitness/presentations/workout_details.dart';
import 'package:sizer/sizer.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Full Body Workout',
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.bebasNeue().fontFamily, letterSpacing: 2),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/gym.png',
                width: double.infinity,
                height: 40.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.sp),
            // Text('Workout Description',
            //     style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
            // SizedBox(height: 6.sp),
            Text(
                'This full body workout is perfect for beginners and requires no equipment. It targets all major muscle groups to improve strength, flexibility, and endurance. Repeat 3 rounds for better results.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14.sp,
                )),
            SizedBox(height: 16.sp),
            Text('Exercises', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600, fontFamily: GoogleFonts.bebasNeue().fontFamily)),
            SizedBox(height: 8.sp),
            _buildExerciseTile("Jumping Jacks", "30 Sec", "assets/images/gym.png", context),
            _buildExerciseTile("Squats", "45 Sec", "assets/images/gym.png", context),
            _buildExerciseTile("Push-ups", "40 Sec", "assets/images/gym.png", context),
            _buildExerciseTile("Lunges", "60 Sec", "assets/images/gym.png", context),
            _buildExerciseTile("Plank", "30 Sec", "assets/images/gym.png", context),
            SizedBox(height: 20.sp),

            // Center(
            //   child: NeoPopButton(
            //     color: Color(0xFFB9F708),
            //     bottomShadowColor: green,
            //     rightShadowColor: green,
            //     onTapUp: () {
            //       Navigator.of(context).push(MaterialPageRoute(
            //         builder: (context) => const WorkoutDetailsPage(exercises: [
            //           {
            //             'title': 'Jumping Jacks',
            //             'level': 'Easy',
            //             'imageUrl': 'assets/images/jumping-jacks.gif',
            //             'equipment': 'Dumbells',
            //             'exercises': ['A', 'B'],
            //             'description': 'This is a sample description for the workout.',
            //             'muscle': 'Biceps, Shoulders',
            //           },
            //           {
            //             'title': 'Squats',
            //             'level': 'Easy',
            //             'imageUrl': 'assets/images/jumping-jacks.gif',
            //             'equipment': 'Dumbells',
            //             'exercises': ['A', 'B'],
            //             'description': 'This is a sample description for the workout.',
            //             'muscle': 'Biceps',
            //           }
            //         ]),
            //       ));
            //     },
            //     child: Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
            //       child: const Text('Start Exercise'),
            //     ),
            //   ),
            // ),
            // sizedten(context)
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(String name, String time, String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => WorkoutDetailsPage(exercises: [
            {
              'title': name,
              'level': 'Easy',
              'imageUrl': 'assets/images/jumping-jacks.gif',
              'equipment': 'Dumbells',
              'exercises': ['A', 'B'],
              'description': 'This is a sample description for the workout.',
              'muscle': 'Biceps, Shoulders',
            },
            {
              'title': 'Squats',
              'level': 'Easy',
              'imageUrl': 'assets/images/jumping-jacks.gif',
              'equipment': 'Dumbells',
              'exercises': ['A', 'B'],
              'description': 'This is a sample description for the workout.',
              'muscle': 'Biceps',
            }
          ]),
        ));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.sp),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 14.w,
              height: 14.w,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 18.sp,
                fontFamily: GoogleFonts.bebasNeue().fontFamily,
              )),
          subtitle: Text(time, style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
          trailing: Icon(Icons.play_circle_fill, color: const Color(0xFFB9F708), size: 22.sp),
        ),
      ),
    );
  }
}
