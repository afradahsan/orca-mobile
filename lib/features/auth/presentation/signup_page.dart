import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/auth_services.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ProgressiveSignupPage extends StatefulWidget {
  final String phoneNumber;

  const ProgressiveSignupPage({super.key, required this.phoneNumber});

  @override
  State<ProgressiveSignupPage> createState() => _ProgressiveSignupPageState();
}

class _ProgressiveSignupPageState extends State<ProgressiveSignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  File? _imageFile;
  int _step = 1;
  bool _isLoading = false;
  bool _obscurePassword = true;
  final AuthServices _authService = AuthServices();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  /// Sends real registration details to backend which triggers SMS OTP
  Future<void> _sendOtp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authService.registerUser(
        name: name,
        email: email,
        password: password,
        phone: widget.phoneNumber,
      );

      debugPrint("registerUser response: $response");

      if (response['message']?.toString().toLowerCase().contains('otp sent') == true) {
        if (!mounted) return;
        setState(() => _step = 4);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP sent successfully to ${widget.phoneNumber}"),
            backgroundColor: Colors.green.shade800,
          ),
        );
      } else {
        if (!mounted) return;
        final errorMsg = response['error'] ?? response['message'] ?? 'Failed to send OTP';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$errorMsg"),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error sending OTP: $e"),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Verifies the OTP with the backend, finalizes user creation, and logs the user in
  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authService.verifyOtpAndRegister(
        phone: widget.phoneNumber,
        otp: otp,
      );

      debugPrint("verifyOtp response: $response");

      final msg = response['message']?.toString().toLowerCase() ?? '';
      if (msg.contains('successful') || response['token'] != null) {
        // Authenticate user session with backend
        final loginRes = await _authService.loginWithPhone(
          phone: widget.phoneNumber,
          password: passwordController.text.trim(),
        );

        final token = loginRes['token'] ?? response['token'];
        if (token != null && mounted) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          await auth.login(token, "User", userName: nameController.text.trim());
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Phone verified & registered successfully!"),
            backgroundColor: Colors.green.shade800,
          ),
        );

        setState(() => _step = 5); // move to optional profile picture step
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Invalid OTP code. Please try again.'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error verifying OTP: $e"),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _finishSignup() {
    FocusScope.of(context).unfocus();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Center(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 1:
        return _buildNameStep();
      case 2:
        return _buildEmailStep();
      case 3:
        return _buildPasswordStep();
      case 4:
        return _buildOtpStep();
      case 5:
        return _buildProfileStep();
      default:
        return _buildNameStep();
    }
  }

  // 🔹 STEP 1: NAME
  Widget _buildNameStep() {
    return Column(
      key: const ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Welcome Aboard!",
          style: TextStyle(
            color: white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.sp),
        Text(
          "What is your full name?",
          style: TextStyle(color: whitet150),
        ),
        SizedBox(height: 25.sp),
        TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            filled: true,
            fillColor: whitet50,
            hintText: 'Full Name',
            hintStyle: TextStyle(color: whitet150),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 25.sp),
        _adaptiveButton(
          label: "Next",
          onPressed: () {
            if (nameController.text.trim().length < 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter your name")),
              );
              return;
            }
            setState(() => _step = 2);
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Change phone number", style: TextStyle(color: whitet150)),
        ),
      ],
    );
  }

  // 🔹 STEP 2: EMAIL
  Widget _buildEmailStep() {
    final firstName = nameController.text.trim().split(' ').first;
    return Column(
      key: const ValueKey(2),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Nice to meet you, $firstName!",
          style: TextStyle(
            color: white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.sp),
        Text(
          "Where can we reach you?",
          style: TextStyle(color: whitet150),
        ),
        SizedBox(height: 25.sp),
        TextField(
          controller: emailController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: whitet50,
            hintText: 'Email Address',
            hintStyle: TextStyle(color: whitet150),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 25.sp),
        _adaptiveButton(
          label: "Next",
          onPressed: () {
            final email = emailController.text.trim();
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(email)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter a valid email address")),
              );
              return;
            }
            setState(() => _step = 3);
          },
        ),
        TextButton(
          onPressed: () => setState(() => _step = 1),
          child: Text("Back", style: TextStyle(color: whitet150)),
        ),
      ],
    );
  }

  // 🔹 STEP 3: PASSWORD & TRIGGER OTP
  Widget _buildPasswordStep() {
    return Column(
      key: const ValueKey(3),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Create a Password",
          style: TextStyle(
            color: white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.sp),
        Text(
          "Set a secure password (min 6 characters)",
          style: TextStyle(color: whitet150),
        ),
        SizedBox(height: 25.sp),
        TextField(
          controller: passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: whitet50,
            hintText: 'Password',
            hintStyle: TextStyle(color: whitet150),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: whitet150,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 25.sp),
        _adaptiveButton(
          label: _isLoading ? "Sending OTP..." : "Continue to Verification",
          onPressed: _isLoading ? () {} : _sendOtp,
        ),
        TextButton(
          onPressed: () => setState(() => _step = 2),
          child: Text("Back", style: TextStyle(color: whitet150)),
        ),
      ],
    );
  }

  // 🔹 STEP 4: OTP VERIFICATION
  Widget _buildOtpStep() {
    return Column(
      key: const ValueKey(4),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Verify your phone",
          style: TextStyle(
            color: white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.sp),
        Text(
          "We’ve sent an OTP code to ${widget.phoneNumber}",
          style: TextStyle(color: whitet150),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 25.sp),
        TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 20),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: whitet50,
            hintText: 'Enter OTP',
            hintStyle: TextStyle(color: whitet150, letterSpacing: 1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 20.sp),
        _adaptiveButton(
          label: _isLoading ? "Verifying..." : "Verify OTP",
          onPressed: _isLoading ? () {} : _verifyOtp,
        ),
        SizedBox(height: 10.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _isLoading ? null : _sendOtp,
              child: Text(
                "Resend OTP",
                style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ),
            Text(
              "•",
              style: TextStyle(color: whitet150),
            ),
            TextButton(
              onPressed: () => setState(() => _step = 3),
              child: Text("Edit details", style: TextStyle(color: whitet150, fontSize: 13.sp)),
            ),
          ],
        ),
      ],
    );
  }

  // 🔹 STEP 5: PROFILE IMAGE (OPTIONAL)
  Widget _buildProfileStep() {
    return Column(
      key: const ValueKey(5),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Almost there!",
          style: TextStyle(
            color: white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.sp),
        Text(
          "Add a profile picture (optional)",
          style: TextStyle(color: whitet150),
        ),
        SizedBox(height: 25.sp),
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 45.sp,
                backgroundColor: whitet50,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : const AssetImage('assets/images/istockphoto-1682296067-612x612.jpg') as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(6.sp),
                  decoration: BoxDecoration(color: green, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.black, size: 16),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 25.sp),
        _adaptiveButton(
          label: "Complete & Get Started",
          onPressed: _finishSignup,
        ),
        TextButton(
          onPressed: _finishSignup,
          child: Text("Skip for now", style: TextStyle(color: whitet150)),
        ),
      ],
    );
  }

  Widget _adaptiveButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          padding: EdgeInsets.symmetric(vertical: 14.sp),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
