import 'package:flutter/material.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/presentation/bmi_screen.dart';
import 'package:sizer/sizer.dart';

class HeightSelectionScreen extends StatefulWidget {
  @override
  _HeightSelectionScreenState createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  int selectedHeight = 165;
  final PageController _controller =
      PageController(viewportFraction: 0.2, initialPage: 165 - 30);

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
                child: IconButton(
                  icon: const Icon(Icons.arrow_right_alt,
                      color: Color(0xFFD4FF00),
                      textDirection: TextDirection.rtl),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            SizedBox(height: 12.h),
            const Text(
              "What's Your Height?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4FF00),
              ),
            ),
            SizedBox(height: 3.h),
            Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 22,
                  left: MediaQuery.of(context).size.width * 0.6,
                  child: CustomPaint(
                    size: Size(40, 200),
                    painter: ScalePainter(),
                  ),
                ),
                SizedBox(
                  height: 70.sp,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: 150,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index) {
                      setState(() {
                        selectedHeight = 30 + index;
                      });
                    },
                    itemBuilder: (context, index) {
                      int height = 30 + index;
                      bool isSelected = height == selectedHeight;

                      return Center(
                        child: Text(
                          "$height",
                          style: TextStyle(
                            fontSize: isSelected ? 32 : 22,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFFD4FF00)
                                : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(bottom: 40.sp),
              child: NeoPopButton(
                color: darkgreen,
                bottomShadowColor: green,
                rightShadowColor: green,
                onTapUp: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BmiScreen()));
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

class ScalePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    double startY = 0;
    double gap = size.height / 16; 

    for (int i = 0; i <= 20; i++) {
      bool isMajor = i % 5 == 0;
      double lineWidth = isMajor ? size.width : size.width * 0.5;
      canvas.drawLine(
        Offset(size.width, startY), // Move scale to right of the numbers
        Offset(size.width - lineWidth, startY),
        paint,
      );
      startY += gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
