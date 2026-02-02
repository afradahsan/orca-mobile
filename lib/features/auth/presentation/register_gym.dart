import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/data/gym_owner_service.dart';
import 'package:orca/features/auth/presentation/gym_owner_login.dart';
import 'package:orca/features/auth/presentation/gym_owner_payment.dart'; // ⬅️ NEW
import 'package:sizer/sizer.dart';

class RegisterGymOwnerPage extends StatefulWidget {
  const RegisterGymOwnerPage({super.key});

  @override
  State<RegisterGymOwnerPage> createState() => _RegisterGymOwnerPageState();
}

class _RegisterGymOwnerPageState extends State<RegisterGymOwnerPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController gymNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController licenseIdController = TextEditingController();

  bool _isLoading = false;

  final _gymService = GymOwnerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      appBar: AppBar(
        backgroundColor: darkgreen,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Register Gym Owner',
          style: TextStyle(
            color: white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
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
                    'Welcome! \nLet’s get your gym onboard!',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    "We will verify your details before approving listing.",
                    style: TextStyle(color: whitet150, fontSize: 14.sp),
                  ),
                  SizedBox(height: 25.sp),
                  _buildField("Gym Name", gymNameController),
                  _buildField("Owner Name", ownerNameController),
                  _buildField("Phone Number", phoneController,
                      keyboardType: TextInputType.phone),
                  _buildField("Email", emailController,
                      keyboardType: TextInputType.emailAddress),
                  _buildField("Password", passwordController, isPassword: true),
                  _buildField("Gym Address", addressController, maxLines: 3),
                  _buildField("License ID", licenseIdController),
                  SizedBox(height: 20.sp),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      padding: EdgeInsets.symmetric(vertical: 14.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                    ),
                    onPressed: _isLoading ? () {} : _submitForm,
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
                              'Submit',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 10.sp),
                  Center(
                    child: Text(
                      "We’ll contact you within 24–48 hours",
                      style: TextStyle(color: whitet150, fontSize: 14.sp),
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GymOwnerLoginPage()),
                        );
                      },
                      child: Text(
                        "Already a registered gym owner? Log in",
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _gymService.registerGymOwner(
      name: ownerNameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      gymName: gymNameController.text.trim(),
      gymAddress: addressController.text.trim(),
      licenseId: licenseIdController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      // 👉 Go to payment screen instead of just showing popup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GymOwnerPaymentPage(
            gymName: gymNameController.text.trim(),
            ownerName: ownerNameController.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Something went wrong")),
      );
    }
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.sp),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        maxLines: maxLines,
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