import 'package:flutter/material.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/presentation/height_select.dart';
import 'package:sizer/sizer.dart';

class WeightSelectionScreen extends StatefulWidget {
  @override
  _WeightSelectionScreenState createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  int selectedWeight = 75;
  final PageController _controller =
      PageController(viewportFraction: 0.2, initialPage: 75 - 30);

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

            SizedBox(height: 60.sp),

            const Text(
              "What's Your Weight?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4FF00),
              ),
            ),
            SizedBox(
              height: 46.sp,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 0,
                    child: CustomPaint(
                      size: Size(MediaQuery.of(context).size.width, 40),
                      painter: ScalePainter(),
                    ),
                  ),

                  PageView.builder(
                    controller: _controller,
                    itemCount: 150,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() {
                        selectedWeight = 30 + index;
                      });
                    },
                    itemBuilder: (context, index) {
                      int weight = 30 + index;
                      bool isSelected = weight == selectedWeight;

                      return Center(
                        child: Text(
                          "$weight",
                          style: TextStyle(
                            fontSize: isSelected ? 32 : 22,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFFD4FF00)
                                : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 2,
                      height: 40,
                      color: Color(0xFFD4FF00),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HeightSelectionScreen()));
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

// Custom Painter for Static Scale
class ScalePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    double startX = 0;
    double gap = size.width / 20; // Spacing between lines

    for (int i = 0; i <= 20; i++) {
      bool isMajor = i % 5 == 0;
      double lineHeight = isMajor ? size.height : size.height * 0.5;
      canvas.drawLine(Offset(startX, size.height),
          Offset(startX, size.height - lineHeight), paint);
      startX += gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
