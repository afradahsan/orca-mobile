import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/gym_owner_service.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/auth/presentation/register_gym.dart';
import 'package:orca/features/fitness/presentations/gym_ownerpage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class GymOwnerLoginPage extends StatefulWidget {
  const GymOwnerLoginPage({super.key});

  @override
  State<GymOwnerLoginPage> createState() => _GymOwnerLoginPageState();
}

class _GymOwnerLoginPageState extends State<GymOwnerLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GymOwnerService gymOwnerService = GymOwnerService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      appBar: AppBar(
        backgroundColor: darkgreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: white, size: 18.sp),
        ),
        centerTitle: true,
        title: Text(
          'Gym Owner Login',
          style: TextStyle(color: white, fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 8.sp),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  Text(
                    "Log in to manage your gym profile and members.",
                    style: TextStyle(color: whitet150, fontSize: 14.sp),
                  ),
                  SizedBox(height: 25.sp),
                  _buildField("Email ID", emailController, keyboardType: TextInputType.emailAddress),
                  _buildField("Password", passwordController, obscureText: true),
                  SizedBox(height: 15.sp),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: green, fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 25.sp),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      padding: EdgeInsets.symmetric(vertical: 14.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                    ),
                    onPressed: _isLoading
                        ? () {}
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);

                              final result = await gymOwnerService.loginGymOwner(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );

                              setState(() => _isLoading = false);
                              debugPrint('${result['success']}, ${result["message"]}');

                              final auth = Provider.of<AuthProvider>(context, listen: false);

                              if (result["success"]) {
                                debugPrint('success: ${result["token"]}');
                                await auth.login(result["token"], "GymOwner");

                                try {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setString("gym_token", result["token"]);
                                } catch (e) {
                                  debugPrint("SharedPreferences error: $e");
                                }

                                await Future.delayed(const Duration(milliseconds: 150));

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Login successful")),
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => GymOwnerPage(token: result["token"],)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result["message"] ?? "Login failed")),
                                );
                              }
                            }
                          },
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.2,
                            )
                          : Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterGymOwnerPage(),));
                      },
                      child: Text(
                        "New gym owner? Register here",
                        style: TextStyle(
                          color: green,
                          decoration: TextDecoration.underline,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.sp),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(color: white),
        validator: (v) => v!.isEmpty ? "Enter $label" : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: whitet200),
          filled: true,
          fillColor: whitet50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.sp),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
