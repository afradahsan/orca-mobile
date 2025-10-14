import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/auth/presentation/age_select.dart';
import 'package:orca/features/fitness/data/role_provider.dart';
import 'package:orca/features/fitness/presentations/all_workouts.dart';
import 'package:orca/features/fitness/presentations/fitness_page.dart';
import 'package:orca/features/fitness/presentations/gym_ownerpage.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AccountFitness extends StatefulWidget {
  const AccountFitness({super.key});

  @override
  State<AccountFitness> createState() => _AccountFitnessState();
}

class _AccountFitnessState extends State<AccountFitness> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Who are you?",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
              sizedten(context),
              ElevatedButton(
                onPressed: () {
                  Provider.of<RoleProvider>(context, listen: false).setRole('Gym Member');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AgeSelectionScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB9F708),
                  padding: EdgeInsets.symmetric(horizontal: 34.sp, vertical: 12.sp),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
                ),
                child: Text(
                  'Gym Member',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
              ),
              sizedfive(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _roleButton("Trainer"),
                  sizedwfive(context),
                  _roleButton("Gym Owner"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleButton(String role) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          Provider.of<RoleProvider>(context, listen: false).setRole('Gym Member');
          role == 'Gym Member'
              ? Navigator.push(context, MaterialPageRoute(builder: (context) => FitnessPage()))
              : Navigator.push(context, MaterialPageRoute(builder: (context) => GymOwnerPage()));
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: green,
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 12.sp),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: Colors.black,
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      ),
    );
  }
}
