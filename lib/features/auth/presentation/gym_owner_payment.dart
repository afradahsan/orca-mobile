import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/presentation/gym_owner_login.dart';
import 'package:sizer/sizer.dart';

class GymOwnerPaymentPage extends StatefulWidget {
  final String gymName;
  final String ownerName;
  final String email;
  final String phone;

  const GymOwnerPaymentPage({
    super.key,
    required this.gymName,
    required this.ownerName,
    required this.email,
    required this.phone,
  });

  @override
  State<GymOwnerPaymentPage> createState() => _GymOwnerPaymentPageState();
}

class _GymOwnerPaymentPageState extends State<GymOwnerPaymentPage> {
  bool _isPaying = false;

  /// simple plan model
  final List<_PlanOption> _plans = [
    _PlanOption(
      id: "monthly",
      title: "Monthly",
      subtitle: "Good to try things out",
      price: 499,
      badge: "Basic",
    ),
    _PlanOption(
      id: "six_months",
      title: "6 Months",
      subtitle: "Best value for growing gyms",
      price: 2499,
      badge: "Recommended",
      isRecommended: true,
    ),
    _PlanOption(
      id: "yearly",
      title: "12 Months",
      subtitle: "For committed long-term partners",
      price: 4499,
      badge: "Pro",
    ),
  ];

  late _PlanOption _selectedPlan;

  @override
  void initState() {
    super.initState();
    // default: 6-month recommended plan
    _selectedPlan = _plans.firstWhere((p) => p.isRecommended, orElse: () => _plans[0]);
  }

  double get _gst => _selectedPlan.price * 0.18;
  double get _total => _selectedPlan.price + _gst;

  Future<void> _startPayment() async {
    setState(() => _isPaying = true);

    /// TODO: integrate Razorpay / Stripe / etc here.
    await Future.delayed(const Duration(seconds: 2)); // fake delay

    setState(() => _isPaying = false);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: darkgreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.sp),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: green, size: 22.sp),
            SizedBox(width: 8.sp),
            Text(
              "Payment Successful",
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
            ),
          ],
        ),
        content: Text(
          "Your ${_selectedPlan.title} subscription is active. "
          "You can now log in to your gym owner dashboard.",
          style: TextStyle(color: whitet150, fontSize: 12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const GymOwnerLoginPage()),
                (route) => false,
              );
            },
            child: Text(
              "Go to Login",
              style: TextStyle(color: green, fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      appBar: AppBar(
        backgroundColor: darkgreen,
        elevation: 0,
        title: Text(
          "Choose a Plan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi ${widget.ownerName.split(' ').first},",
              style: TextStyle(color: whitet200, fontSize: 14.sp),
            ),
            SizedBox(height: 4.sp),
            Text(
              "Activate your ORCA Partner access",
              style: TextStyle(
                color: white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Select subscription plan",
                  style: TextStyle(
                    color: white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.sp),

            ..._plans.map((plan) => _planTile(plan)).toList(),

            const Spacer(),

            _priceFooter(),
          ],
        ),
      ),
    );
  }

  Widget _planTile(_PlanOption plan) {
    final bool selected = plan.id == _selectedPlan.id;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPlan = plan);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.only(bottom: 14.sp),
        padding: EdgeInsets.all(16.sp),
        width: double.infinity,
        decoration: BoxDecoration(
          color: selected ? Colors.green.withOpacity(0.12) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18.sp),
          border: Border.all(
            color: selected ? green : Colors.white24,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: green.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            if (plan.isRecommended)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
                decoration: BoxDecoration(
                  color: green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "⭐ RECOMMENDED",
                  style: TextStyle(
                    color: green,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (plan.isRecommended) SizedBox(height: 6.sp),

            // Title + Price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.title,
                  style: TextStyle(
                    color: white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "₹${plan.price.toInt()}",
                      style: TextStyle(
                        color: white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      " /plan",
                      style: TextStyle(
                        color: whitet150,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 6.sp),

            // Subtitle
            Text(
              plan.subtitle,
              style: TextStyle(
                color: whitet200,
                fontSize: 12.sp,
              ),
            ),

            SizedBox(height: 12.sp),

            // Selected indicator
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
                decoration: BoxDecoration(
                  color: selected ? green : Colors.white12,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                      color: selected ? Colors.black : Colors.white54,
                      size: 15.sp,
                    ),
                    SizedBox(width: 6.sp),
                    Text(
                      selected ? "Selected" : "Choose Plan",
                      style: TextStyle(
                        color: selected ? Colors.black : Colors.white70,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _priceFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16.sp),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedPlan.title,
                    style: TextStyle(color: white, fontSize: 13.sp),
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    "Base: ₹${_selectedPlan.price.toStringAsFixed(0)}",
                    style: TextStyle(color: whitet150, fontSize: 12.sp),
                  ),
                  Text(
                    "GST (18%): ₹${_gst.toStringAsFixed(0)}",
                    style: TextStyle(color: whitet150, fontSize: 12.sp),
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    "Total: ₹${_total.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: green,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.sp,
                    vertical: 11.sp,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                ),
                onPressed: _isPaying ? null : _startPayment,
                child: _isPaying
                    ? SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Proceed to Pay",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.sp),
      ],
    );
  }
}

/// simple internal model for plans
class _PlanOption {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String badge;
  final bool isRecommended;

  _PlanOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    this.badge = "",
    this.isRecommended = false,
  });
}
