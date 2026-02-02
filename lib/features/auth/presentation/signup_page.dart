import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/auth_services.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:sizer/sizer.dart';

class ProgressiveSignupPage extends StatefulWidget {
  final String phoneNumber; // ✅ incoming from PhoneNumber page

  const ProgressiveSignupPage({super.key, required this.phoneNumber});

  @override
  State<ProgressiveSignupPage> createState() => _ProgressiveSignupPageState();
}

class _ProgressiveSignupPageState extends State<ProgressiveSignupPage> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  File? _imageFile;

  int _step = 1;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;
  final AuthServices _authService = AuthServices();

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    try {
      final response = await _authService.registerUser(
        name: "temp",
        email: "temp@example.com",
        password: "temporary123", // stored in Redis only
        phone: widget.phoneNumber,
      );

      if (response['message']?.toString().contains('OTP sent') ?? false) {
        setState(() => _isOtpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Failed to send OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending OTP: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Verify OTP and finalize registration
  Future<void> _verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authService.verifyOtpAndRegister(
        phone: widget.phoneNumber,
        otp: otpController.text.trim(),
      );

      if (response['message']?.toString().contains('Registration successful') ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );
        setState(() => _step = 2); // move to name step
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Invalid OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verifying OTP: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_step == 2 && nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }
    if (_step == 3 && emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }
    setState(() => _step++);
  }

  void _finishSignup() {
    // Navigate to home or send data to backend
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NavBarPage()),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOtp();
    });
  }

  Widget _buildOtpStep() {
    return Column(
      key: const ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Verify your phone",
            style: TextStyle(color: white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.sp),
        Text("We’ve sent an OTP to ${widget.phoneNumber}",
            style: TextStyle(color: whitet150), textAlign: TextAlign.center),
        SizedBox(height: 25.sp),
        TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, letterSpacing: 6),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: whitet50,
            hintText: 'Enter 4-digit OTP',
            hintStyle: TextStyle(color: whitet150),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 20.sp),
        _adaptiveButton(label: "Verify OTP", onPressed: _verifyOtp),
        TextButton(
          onPressed: _sendOtp,
          child: Text("Resend OTP", style: TextStyle(color: green, fontWeight: FontWeight.bold)),
        ),
      ],
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
                duration: const Duration(milliseconds: 400),
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
        return _buildOtpStep();
      case 2:
        return _buildNameStep();
      case 3:
        return _buildEmailStep();
      case 4:
        return _buildProfileStep();
      default:
        return _buildOtpStep();
    }
  }

  Widget _buildNameStep() {
    return Column(
      key: const ValueKey(2),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Welcome!",
          style: TextStyle(
            color: white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.sp),
        Text(
          "What’s your full name?",
          style: TextStyle(color: whitet150),
        ),
        SizedBox(height: 25.sp),
        TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
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
        _adaptiveButton(label: "Next", onPressed: _nextStep),
        TextButton(
          onPressed: () => setState(() => _step--),
          child: Text("Back", style: TextStyle(color: whitet150)),
        ),
      ],
    );
  }

  // 🔹 STEP 3: EMAIL ENTRY
  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey(3),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Hi ${nameController.text.split(' ').first},",
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
        _adaptiveButton(label: "Next", onPressed: _nextStep),
        TextButton(
          onPressed: () => setState(() => _step--),
          child: Text("Back", style: TextStyle(color: whitet150)),
        ),
      ],
    );
  }

  // 🔹 STEP 4: PROFILE IMAGE
  Widget _buildProfileStep() {
    return Column(
      key: const ValueKey(4),
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
                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : const AssetImage('assets/images/istockphoto-1682296067-612x612') as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(5.sp),
                  decoration: BoxDecoration(color: green, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.black, size: 16),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 25.sp),
        _adaptiveButton(label: "Create Account", onPressed: _finishSignup),
        TextButton(
          onPressed: () => setState(() => _step--),
          child: Text("Back", style: TextStyle(color: whitet150)),
        ),
      ],
    );
  }

  // ✅ Adaptive Full-width Button
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
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
