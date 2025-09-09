import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  String otpCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      body: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter OTP',
              style: TextStyle(
                color: white,
                fontWeight: FontWeight.bold,
                fontSize: 22.sp,
              ),
            ),
            SizedBox(height: 10.sp),
            Text(
              widget.phoneNumber.isEmpty ? 'A 6 digit code was sent to +91xxxxxxx' : 'A 6 digit code was sent to ${widget.phoneNumber}',
              style: TextStyle(color: whitet150),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15.sp),

            PinCodeTextField(
              length: 6,
              appContext: context,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              textStyle: TextStyle(color: white, fontSize: 18.sp),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12.sp),
                fieldHeight: 30.sp,
                fieldWidth: 30.sp,
                inactiveColor: whitet50,
                selectedColor: green,
                activeColor: green,
                activeFillColor: whitet50,
                selectedFillColor: whitet50,
                inactiveFillColor: whitet50,
              ),
              enableActiveFill: true,
              onChanged: (value) => otpCode = value,
              onCompleted: (value) {
                debugPrint('OTP entered: $value');
              },
            ),

            SizedBox(height: 5.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Resend Code',
                  style: TextStyle(color: green, fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            sizedten(context),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                padding: EdgeInsets.symmetric(vertical: 14.sp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.sp),
                ),
              ),
              onPressed: () {
                // You can use controller.text and _selectedCountryCode here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NavBarPage()),
                );
              },
              child: Center(
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
