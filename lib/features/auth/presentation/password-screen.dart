import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/auth_services.dart';
import 'package:orca/features/auth/domain/auth_repo.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:sizer/sizer.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({required this.email, required this.phoneNumber, super.key});

  final String phoneNumber;
  final String email;

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController passController = TextEditingController();
  bool _isLoading = false;
  AuthRepo _authRepo = AuthRepo(authServices: AuthServices());
  bool _obscureText = false;

  Future<void> _handleLogin() async {
    if (passController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password cannot be empty")),
      );
      return;
    }
    debugPrint('handle login called..');
    setState(() => _isLoading = true);
    try {
      final response = await _authRepo.login(
        email: widget.email,
        phone: widget.phoneNumber,
        password: passController.text.trim(),
      );
      debugPrint("Login Success: $response");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NavBarPage()),
      );
    } catch (e) {
      debugPrint("Login Failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
                          'Enter your password',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                        // SizedBox(height: 10.sp),
                        // Text(
                        //   'Enter your ${_useEmail ? "email address" : "phone number"} to get started',
                        //   style: TextStyle(color: whitet150),
                        //   textAlign: TextAlign.center,
                        // ),
                        SizedBox(height: 20.sp),
                        TextField(
                          controller: passController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: white),
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                color: white.withOpacity(0.5),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
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
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? SizedBox(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: const CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 12.sp),
                      ],
                    ),
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
