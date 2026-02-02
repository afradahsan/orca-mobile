import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/auth_services.dart';
import 'package:orca/features/auth/domain/auth_repo.dart';
import 'package:orca/features/auth/presentation/gym_owner_login.dart';
import 'package:orca/features/auth/presentation/password-screen.dart';
import 'package:orca/features/auth/presentation/register_gym.dart';
import 'package:orca/features/auth/presentation/signup_page.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:sizer/sizer.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({super.key});

  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _useEmail = false;
  final AuthRepo _authRepo = AuthRepo(authServices: AuthServices());
  bool _isLoading = false;

  String _selectedCountryCode = '+91';
  final List<String> _countryCodes = ['+91', '+1', '+44', '+61', '+971'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.sp),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome Aboard!',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                        SizedBox(height: 10.sp),
                        Text(
                          'Enter your ${_useEmail ? "email address" : "phone number"} to get started',
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
                              listTileDivider: Container(
                                height: 3.sp,
                                color: green,
                              ),
                              searchFieldCursorColor: white,
                              searchFieldInputDecoration: InputDecoration(
                                hintText: 'Search country',
                                hintStyle: TextStyle(color: whitet150),
                              ),
                            ),
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
                        if (_useEmail)
                          TextField(
                            controller: emailController,
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
                                  emailController.clear();
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
                            backgroundColor:green, 
                            padding: EdgeInsets.symmetric(vertical: 14.sp),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                            ),
                          ),
                          onPressed: _isLoading
                              ? (){}
                              : () async {
                                  final phone = phoneController.text.trim();
                                  if (phone.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please enter a valid phone number")),
                                    );
                                    return;
                                  }

                                  setState(() => _isLoading = true);

                                  try {
                                    final exists = await _authRepo.checkUserExistence(phone);

                                    if (exists) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PasswordScreen(
                                            phoneNumber: phone,
                                            email: emailController.text,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProgressiveSignupPage(phoneNumber: phone),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error: $e")),
                                    );
                                  } finally {
                                    setState(() => _isLoading = false);
                                  }
                                },
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                                    height: 18.sp,
                                    width: 18.sp,
                                    child: const CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : Text(
                                    'Continue',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 12.sp),
                        Text(
                          'OR',
                          style: TextStyle(
                            color: whitet200,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
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
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => NavBarPage()),
                                (route) => false,
                              );
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
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.sp),
              child: GestureDetector(
                onTap: () {},
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Are you a gym owner? ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: 'Proceed here →',
                        style: TextStyle(
                          color: green, // your theme green
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GymOwnerLoginPage(),
                              ),
                            );
                          },
                      ),
                    ],
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
