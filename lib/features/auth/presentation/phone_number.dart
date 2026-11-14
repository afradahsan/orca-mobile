import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/auth_services.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/auth/domain/auth_repo.dart';
import 'package:orca/features/auth/presentation/gym_owner_login.dart';
import 'package:orca/features/auth/presentation/password-screen.dart';
import 'package:orca/features/auth/presentation/signup_page.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({super.key});

  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  final TextEditingController phoneController = TextEditingController();
  final AuthRepo _authRepo = AuthRepo(authServices: AuthServices());
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Route _smoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

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
                          'Enter your phone number to get started',
                          style: TextStyle(color: whitet150),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.sp),
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
                        SizedBox(height: 15.sp),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            padding: EdgeInsets.symmetric(vertical: 14.sp),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  final phone = phoneController.text.trim();
                                  if (phone.isEmpty || phone.length < 10) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please enter a valid 10-digit phone number")),
                                    );
                                    return;
                                  }

                                  // Dismiss keyboard smoothly
                                  FocusScope.of(context).unfocus();
                                  setState(() => _isLoading = true);

                                  try {
                                    final exists = await _authRepo.checkUserExistence(phone);

                                    if (!mounted) return;

                                    if (exists) {
                                      Navigator.push(
                                        context,
                                        _smoothRoute(
                                          PasswordScreen(
                                            phoneNumber: phone,
                                            email: '',
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        _smoothRoute(
                                          ProgressiveSignupPage(phoneNumber: phone),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                    }
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
                          icon: _isGoogleLoading
                              ? SizedBox(
                                  height: 18.sp,
                                  width: 18.sp,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.black,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/google-logo.png',
                                  height: 20.sp,
                                ),
                          label: Text(
                            _isGoogleLoading ? "Signing in..." : "Continue with Google",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: (_isLoading || _isGoogleLoading)
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();
                                  setState(() => _isGoogleLoading = true);
                                  try {
                                    final result = await _authRepo.handleSignIn();
                                    if (!mounted) return;

                                    if (result.isSuccess && result.user != null) {
                                      final auth = Provider.of<AuthProvider>(context, listen: false);
                                      final token = await result.user!.getIdToken() ?? result.user!.uid;
                                      final name = result.user?.displayName;
                                      await auth.login(token, "User", userName: name);

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        _smoothRoute(const NavBarPage()),
                                        (route) => false,
                                      );
                                      debugPrint('Google Sign-In success: ${result.user?.email}');
                                    } else if (result.isCancelled) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result.errorMessage ?? "Google sign-in was cancelled"),
                                          backgroundColor: Colors.orange.shade800,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result.errorMessage ?? "Google sign-in failed"),
                                          backgroundColor: Colors.red.shade800,
                                          duration: const Duration(seconds: 5),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error: $e"),
                                        backgroundColor: Colors.red.shade800,
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isGoogleLoading = false);
                                    }
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
                          color: green,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              _smoothRoute(const GymOwnerLoginPage()),
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
