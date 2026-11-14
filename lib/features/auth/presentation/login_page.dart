import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/auth_services.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/auth/domain/auth_repo.dart';
import 'package:orca/features/auth/presentation/otp_verify.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.token, super.key});

  final String token;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthRepo _authRepo = AuthRepo(authServices: AuthServices());

  final bool _useEmail = false;
  bool _isGoogleLoading = false;

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
                  controller: passwordController,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OtpVerifyScreen(
                                phoneNumber: phoneController.text,
                                token: widget.token,
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
                  onPressed: _isGoogleLoading
                      ? null
                      : () async {
                          setState(() => _isGoogleLoading = true);
                          try {
                            final result = await _authRepo.handleSignIn();
                            if (!mounted) return;

                            if (result.isSuccess && result.user != null) {
                              final auth = Provider.of<AuthProvider>(context, listen: false);
                              final token = await result.user!.getIdToken() ?? result.user!.uid;
                              await auth.login(token, "User");

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const NavBarPage()),
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
    );
  }
}
