import 'package:flutter/material.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/presentation/weight_select.dart';
import 'package:sizer/sizer.dart';

class AgeSelectionScreen extends StatefulWidget {
  @override
  _AgeSelectionScreenState createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  int selectedAge = 20;
  final PageController _controller = PageController(viewportFraction: 0.2, initialPage: 8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_right_alt, color: Color(0xFFD4FF00), textDirection: TextDirection.rtl),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 5.sp,),
                    Text('Welcome!')
                  ],
                ),
              ),
            ),
            SizedBox(height: 66.sp,),
            const Text(
              "Before we proceed,",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4FF00),
              ),
            ),
            const Text(
              "How Old Are You?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4FF00),
              ),
            ),
            SizedBox(height: 12.sp),
            SizedBox(
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: 50,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() {
                        selectedAge = 12 + index;
                      });
                    },
                    itemBuilder: (context, index) {
                      int age = 12 + index;
                      bool isSelected = age == selectedAge;

                      return Center(
                        child: Text(
                          "$age",
                          style: TextStyle(
                            fontSize: isSelected ? 32 : 22,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFFD4FF00) : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),

                  Positioned(
                    top: 10,
                    bottom: 10,
                    child: Row(
                      children: [
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.white,
                        ),
                        SizedBox(width: 35.sp),
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 55.sp,),
            Padding(
              padding: EdgeInsets.only(bottom: 40.sp),
              child: NeoPopButton(
                color: darkgreen,
                bottomShadowColor: green,
                rightShadowColor: green,
                onTapUp: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WeightSelectionScreen()));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.sp, vertical: 12.sp),
                    child: Icon(Icons.arrow_right_alt, color: green),
                ),),
            ),
          ],
        ),
      ),
    );
  }
}
