import 'package:flutter/material.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/presentation/signup_page.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:sizer/sizer.dart';

class SetGoalScreen extends StatefulWidget {
  const SetGoalScreen({super.key});

  @override
  State<SetGoalScreen> createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends State<SetGoalScreen> {
  String selectedGoal = "Gain Weight";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_right_alt, color: Color(0xFFD4FF00), textDirection: TextDirection.rtl),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 40.sp),
              const Center(
                child: Text(
                  "Set Your Goal",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildGoalOption("Lose Weight"),
              _buildGoalOption("Gain Weight"),
              _buildGoalOption("Muscle Mass Gain"),
              _buildGoalOption("Shape Body"),
              _buildGoalOption("Others"),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 40.sp),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: NeoPopButton(
                    color: darkgreen,
                    bottomShadowColor: green,
                    rightShadowColor: green,
                    onTapUp: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => NavBarPage(initialTabIndex: 1,)),
                        (route) => false,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
                      child: Icon(Icons.arrow_right_alt, color: green),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for goal options
  Widget _buildGoalOption(String goal) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              goal,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4FF00), width: 2),
                color: selectedGoal == goal ? const Color(0xFFD4FF00) : Colors.transparent,
              ),
              child: selectedGoal == goal ? const Icon(Icons.check, color: Colors.black, size: 18) : null,
            ),
          ],
        ),
      ),
    );
  }
}
