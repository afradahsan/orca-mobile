import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/auth_services.dart';
import 'package:orca/features/auth/domain/auth_repo.dart';
import 'package:orca/features/auth/presentation/otp_verify.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _useEmail = false;
  String _selectedCountryCode = '+91';

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
                  'Login',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
                SizedBox(height: 10.sp),
                Text(
                  'Please login to Continue.',
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
                    controller: phoneController,
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

                      phoneController.text = localNumber;
                      phoneController.selection = TextSelection.fromPosition(
                        TextPosition(offset: phoneController.text.length),
                      );

                      debugPrint('Cleaned local number: $localNumber');
                      debugPrint('Full number: ${phone.completeNumber}');
                    },
                  ),
                // For email input
                if (_useEmail)
                  TextField(
                    controller: phoneController,
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

                  TextField(
                    controller: phoneController,
                    style: TextStyle(color: white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: whitet50,
                      hintText: 'Password',
                      hintStyle: TextStyle(color: whitet150),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                                phoneNumber: phoneController.text,
                              )),
                    );
                  },
                  child: Center(
                    child: Text(
                      'Sign in',
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
                    final user = await AuthRepo(authServices: AuthServices()).handleSignIn();
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
