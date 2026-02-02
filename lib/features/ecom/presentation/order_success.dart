import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:orca/core/utils/colors.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: Colors.greenAccent, size: 70.sp),
              SizedBox(height: 20.sp),
              Text(
                "Payment Successful",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.sp),
              Text(
                "Order ID: $orderId",
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 30.sp),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  padding:
                      EdgeInsets.symmetric(horizontal: 26.sp, vertical: 12.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(
                  "CONTINUE SHOPPING",
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}