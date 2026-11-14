import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/auth_services.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/auth/domain/auth_repo.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:provider/provider.dart';
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
  bool _isSuccess = false;
  final AuthRepo _authRepo = AuthRepo(authServices: AuthServices());
  bool _obscureText = true;

  @override
  void dispose() {
    passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final password = passController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your password")),
      );
      return;
    }

    // Dismiss soft keyboard immediately so it doesn't fight the page transition
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _isSuccess = false;
    });

    try {
      final response = await _authRepo.login(
        email: widget.email,
        phone: widget.phoneNumber,
        password: password,
      );

      final token = response["token"];
      if (token == null || token.toString().isEmpty) {
        final error = response["error"] ?? response["message"] ?? "Incorrect password. Please try again.";
        throw Exception(error);
      }

      final String? name = response["user"]?["name"];

      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(token, "User", userName: name);

      if (!mounted) return;

      // Provide smooth success feedback on the button
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;

      // Smooth custom transition into NavBarPage
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const NavBarPage(),
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
          transitionDuration: const Duration(milliseconds: 320),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint("Login Failed: $e");
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSuccess = false;
      });

      String userMessage = e.toString().replaceFirst("Exception: ", "").trim();
      if (userMessage.contains("Null") ||
          userMessage.contains("subtype") ||
          userMessage.toLowerCase().contains("invalid credentials")) {
        userMessage = "Incorrect password. Please check your password and try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
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
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                        SizedBox(height: 8.sp),
                        Text(
                          widget.phoneNumber.isNotEmpty
                              ? 'Enter the password for ${widget.phoneNumber}'
                              : 'Enter your account password',
                          style: TextStyle(color: whitet150),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.sp),
                        TextField(
                          controller: passController,
                          obscureText: _obscureText,
                          style: TextStyle(color: white),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                color: white.withOpacity(0.6),
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
                          onSubmitted: (_) => _handleLogin(),
                        ),
                        SizedBox(height: 18.sp),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSuccess ? Colors.lightGreenAccent.shade400 : green,
                              padding: EdgeInsets.symmetric(vertical: 14.sp),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                              elevation: _isLoading ? 0 : 2,
                            ),
                            onPressed: (_isLoading || _isSuccess) ? null : _handleLogin,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _isLoading
                                  ? SizedBox(
                                      key: const ValueKey("loading"),
                                      height: 20.sp,
                                      width: 20.sp,
                                      child: const CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : _isSuccess
                                      ? Row(
                                          key: const ValueKey("success"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.check_circle_rounded, color: Colors.black, size: 22),
                                            SizedBox(width: 6.sp),
                                            Text(
                                              'Success!',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'Sign In',
                                          key: const ValueKey("signin"),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.sp),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Change phone number',
                            style: TextStyle(color: whitet150, fontSize: 13.sp),
                          ),
                        ),
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
