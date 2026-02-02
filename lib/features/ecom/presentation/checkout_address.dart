import 'package:flutter/material.dart';
import 'package:orca/core/themes/text_theme.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/ecom/data/address_model.dart';
import 'package:orca/features/ecom/domain/address_service.dart';
import 'package:orca/features/ecom/domain/cart_provider.dart';
import 'package:orca/features/ecom/presentation/order_success.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class CheckoutAddressPage extends StatefulWidget {
  final double totalAmount;
  const CheckoutAddressPage({super.key, required this.totalAmount});

  @override
  State<CheckoutAddressPage> createState() => _CheckoutAddressPageState();
}

class _CheckoutAddressPageState extends State<CheckoutAddressPage> {
  late Future<List<Address>> _futureAddresses;
  Address? selectedAddress;
  String token = '';
  bool showAllAddresses = false;

  @override
  void initState() {
    super.initState();
    _futureAddresses = _loadAddresses();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Razorpay _razorpay = Razorpay();

  void _openCheckout(double amount) {
    var options = {
      'key': 'rzp_live_S0hH7TeOCFvuil',
      'amount': (1 * 100).toInt(), // Razorpay works in paise
      'name': 'Orca Sports Club',
      'description': 'Order Payment',
      'timeout': 120,
      'currency': 'INR',
      'prefill': {
        'contact': '9876543210',
        'email': 'customer@example.com',
      },
      'theme': {
        'color': '#B9F708', // matches your green
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("Payment Success: ${response.paymentId}");

    final cart = Provider.of<CartProvider>(context, listen: false);

    // 1. Send order to backend
    // final orderService = OrderService();
    // await orderService.createOrder(
    //   paymentId: response.paymentId ?? "",
    //   amount: cart.totalPrice,
    //   cartItems: cart.items,
    //   token: "USER_TOKEN_HERE", // later take from AuthProvider
    // );

    // 2. Clear cart
    cart.clear();

    // 3. Navigate to success page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessPage(
          orderId: response.paymentId ?? "N/A",
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Payment Failed: ${response.message}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet Selected: ${response.walletName}");
  }

  Future<List<Address>> _loadAddresses() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.loadAuthData();

    token = auth.token ?? "idk";
    debugPrint('token is $token');
    return AddressService().fetchAddresses(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      appBar: AppBar(
        title: Text(
          "Select Address",
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        backgroundColor: darkgreen,
        leadingWidth: 18.sp,
        leading: Padding(
            padding: EdgeInsets.only(left: 12.sp),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
      body: FutureBuilder<List<Address>>(
        future: _futureAddresses,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: green));
          }

          final addresses = snapshot.data!;

          if (addresses.isEmpty) {
            return _noAddressUI();
          }

          selectedAddress ??= addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// SELECTED ADDRESS (ALWAYS VISIBLE)
                      _selectedAddressCard(selectedAddress!),

                      SizedBox(height: 12.sp),

                      /// CHANGE BUTTON
                      GestureDetector(
                        onTap: () {
                          setState(() => showAllAddresses = !showAllAddresses);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              showAllAddresses ? "- Collapse" : "+ Add/Change address",
                              style: TextStyle(
                                color: green.withValues(alpha: 100),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              showAllAddresses ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: green.withValues(alpha: 100),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 12.sp),

                      /// ALL ADDRESSES (COLLAPSIBLE)
                      if (showAllAddresses)
                        Expanded(
                          child: ListView(
                            children: addresses.where((a) => a.id != selectedAddress!.id).map(_addressTile).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              /// CONTINUE
              Padding(
                  padding: EdgeInsets.all(14.sp),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      padding: EdgeInsets.symmetric(horizontal: 48.sp, vertical: 10.sp),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _openCheckout(widget.totalAmount);
                    },
                    child: Text(
                      "PROCEED",
                      style: KTextTheme.dottedDark.bodyLarge!.copyWith(color: Colors.black),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _selectedAddressCard(Address address) {
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: green, width: 1.5),
        color: Colors.black.withOpacity(0.25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                address.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (address.isDefault) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "DEFAULT",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            ],
          ),
          SizedBox(height: 6),
          Text(
            "${address.addressLine1}, ${address.addressLine2}\n${address.city}, ${address.state} - ${address.pincode}",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 4),
          Text("📞 ${address.phone}", style: TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _addressTile(Address address) {
    final isSelected = selectedAddress?.id == address.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAddress = address;
          showAllAddresses = false; // collapse after selection
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.sp),
        padding: EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? green : Colors.white24),
          color: Colors.black.withOpacity(0.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
              "${address.addressLine1}, ${address.addressLine2}\n${address.city}, ${address.state} - ${address.pincode}",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 4),
            Text("📞 ${address.phone}", style: TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  String _etaText() {
    final now = DateTime.now();
    final eta = now.add(const Duration(days: 3));
    return "${eta.day}/${eta.month}";
  }

  Widget _noAddressUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, size: 48, color: Colors.white54),
          SizedBox(height: 10),
          Text("No address found", style: TextStyle(color: Colors.white)),
          SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {},
            child: const Text("ADD ADDRESS"),
          ),
        ],
      ),
    );
  }
}
