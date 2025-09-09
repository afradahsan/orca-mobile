import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/auth_repo.dart';
import 'package:orca/features/auth/presentation/otp_verify.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:sizer/sizer.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({super.key});

  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  final TextEditingController controller = TextEditingController();
  bool _useEmail = false;
  String _selectedCountryCode = '+91';

  final List<String> _countryCodes = ['+91', '+1', '+44', '+61', '+971'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
                SizedBox(height: 10.sp),
                Text(
                  'Enter your ${_useEmail ? "email address" : "phone number"}. We’ll send you a confirmation code.',
                  style: TextStyle(color: whitet150),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.sp),

                if (!_useEmail)
                  IntlPhoneField(
                    dropdownIconPosition: IconPosition.trailing,
                    dropdownIcon: Icon(
                      Icons.arrow_drop_down,
                      color: white.withAlpha(200),
                    ),
                    pickerDialogStyle: PickerDialogStyle(
                        backgroundColor: darkgreen,
                        countryNameStyle: TextStyle(color: white),
                        countryCodeStyle: TextStyle(color: white),
                        listTileDivider: Container(height: 3.sp, color: green),
                        searchFieldCursorColor: white,
                        searchFieldInputDecoration: InputDecoration(
                          hintText: 'Search country',
                          hintStyle: TextStyle(color: whitet150),
                        )),
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    dropdownTextStyle: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: whitet50,
                      hintText: 'Phone number',
                      hintStyle: TextStyle(color: whitet150),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    initialCountryCode: 'IN',
                    onChanged: (phone) {
                      String localNumber = phone.number;

                      if (localNumber.startsWith(phone.countryCode.replaceAll('+', ''))) {
                        localNumber = localNumber.replaceFirst(
                          phone.countryCode.replaceAll('+', ''),
                          '',
                        );
                      }

                      localNumber = localNumber.replaceAll('+', '').trim();

                      controller.text = localNumber;
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );

                      debugPrint('Cleaned local number: $localNumber');
                      debugPrint('Full number: ${phone.completeNumber}');
                    },
                  ),
                // For email input
                if (_useEmail)
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: whitet50,
                      hintText: 'Email address',
                      hintStyle: TextStyle(color: whitet150),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                SizedBox(height: 10.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _useEmail = !_useEmail;
                          controller.clear();
                        });
                      },
                      child: Text(
                        _useEmail ? 'Use phone instead' : 'Use email instead',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: white,
                          decorationThickness: 1.5,
                          color: white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),
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
                      MaterialPageRoute(
                          builder: (_) => OtpVerifyScreen(
                                phoneNumber: controller.text,
                              )),
                    );
                  },
                  child: Center(
                    child: Text(
                      'Create account',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.sp),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.sp, horizontal: 15.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                  ),
                  icon: Image.asset(
                    'assets/images/google-logo.png',
                    height: 20.sp,
                  ),
                  label: Text(
                    "Continue with Google",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    final user = await AuthService().handleSignIn();
                    if (user != null) {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavBarPage()), (route) => false);
                      debugPrint('handle sign in');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Google sign-in failed")),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
