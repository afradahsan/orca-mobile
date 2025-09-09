import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/fitness/presentations/workout_page.dart';
import 'package:sizer/sizer.dart';

class AllWorkouts extends StatefulWidget {
  const AllWorkouts({super.key});

  @override
  State<AllWorkouts> createState() => _AllWorkoutsState();
}

class _AllWorkoutsState extends State<AllWorkouts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Workouts',
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.bebasNeue().fontFamily, letterSpacing: 2),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: whitet50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: whitet150),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: Text(
                      "Search here",
                      style: TextStyle(color: whitet150, fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 15,
              separatorBuilder: (context, index) {
                return sizedfive(context);
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return WorkoutPage();
                      },
                    ));
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 17.sp, vertical: 6.sp),
                    padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 12.sp),
                    decoration: BoxDecoration(color: white.withAlpha(20), borderRadius: BorderRadius.circular(10.sp)),
                    child: Row(
                      children: [
                        Container(
                          // decoration: BoxDecoration(border: Border.all(color: Color(0xFFB9F708).withAlpha(180), width: 5.sp), shape: BoxShape.circle),
                          padding: EdgeInsets.all(8.sp),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage('assets/images/gym.png'),
                          ),
                        ),
                        sizedwten(context),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workout ${index + 1}',
                              style: TextStyle(color: Color(0xFFB9F708), fontSize: 16.sp, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Description of workout ${index + 1}',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14.sp),
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.play_circle_fill_rounded, color: Color(0xFFB9F708), size: 20.sp, semanticLabel: 'Play Workout'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      )),
    );
  }
}
