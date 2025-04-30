import 'package:flutter/material.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/presentation/set_goals.dart';
import 'package:sizer/sizer.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_right_alt,
                      color: Color(0xFFD4FF00),
                      textDirection: TextDirection.rtl),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 45.sp),
              Image.asset('assets/images/bmi-index.png', width: 250),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(12.sp),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your BMI Is:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "19.6 kg/m",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFD4FF00),
                            ),
                          ),
                          TextSpan(
                            text: "²",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4FF00),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    
                    // Category
                    Text(
                      "(Normal)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    
                    // Description
                    Text(
                      "A BMI of 18.5 - 24.9 indicates that you are at a healthy weight for your height. By maintaining a healthy weight, you lower your risk of developing serious health problems.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 35.sp),
              const Text(
                "Keep Grinding and maintain \n your healthy lifestyle!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
              padding: EdgeInsets.only(bottom: 34.sp),
              child: NeoPopButton(
                color: darkgreen,
                bottomShadowColor: green,
                rightShadowColor: green,
                onTapUp: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SetGoalScreen()));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.sp, vertical: 12.sp),
                    child: Text('Set a Goal', style: TextStyle(color: green,))
                ),),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
