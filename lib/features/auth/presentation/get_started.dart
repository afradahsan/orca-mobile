import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/neopop.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/presentation/age_select.dart';
import 'package:orca/features/auth/presentation/login_page.dart';
import 'package:orca/features/auth/presentation/phone_number.dart';
import 'package:orca/features/auth/presentation/signup_page.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:sizer/sizer.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              children: [
                Image.asset('assets/images/gym.png'),
                Positioned(
                  bottom: 25.sp,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 10.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Ready To Get Fit?',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.w900,
                              color: green,
                            ),
                          ),
                          SizedBox(height: 10.sp),
                          NeoPopButton(
                            color: Colors.black,
                            grandparentColor: green,
                            shadowColor: green,
                            onTapUp: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PhoneNumber()));
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 45.sp, vertical: 12.sp),
                              child: Row(
                                children: [
                                  const Text(
                                    'Get Started',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.arrow_right_alt, color: green),
                                ],
                              ),
                            ),),
                            SizedBox(height: 14.sp,),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context, 
                                  MaterialPageRoute(builder: (context) => NavBarPage()), (route) => false
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontFamily: GoogleFonts.poppins().fontFamily),
                                  children: [
                                    TextSpan(
                                      text: 'Sign in',
                                      style: TextStyle(
                                        color: green,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: GoogleFonts.poppins().fontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}