import 'package:flutter/material.dart';
import 'package:orca/core/themes/text_theme.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/ecom/domain/cart_provider.dart';
import 'package:orca/features/ecom/presentation/cart_page.dart';
import 'package:orca/features/fitness/data/role_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:orca/core/utils/colors.dart';
import '../data/product_model.dart';
import 'package:provider/provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  final bool isLocked;

  const ProductDetailsPage({
    super.key,
    required this.product,
    this.isLocked = false,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isMember = Provider.of<RoleProvider>(context, listen: false).isMember;
    bool added = false;

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                      icon: Text(
                        '-',
                        style: KTextTheme.dottedDark.bodyLarge,
                      )),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.sp),
                    child: Text("$_quantity", style: KTextTheme.dottedDark.bodyLarge),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                      icon: Text(
                        '+',
                        style: KTextTheme.dottedDark.bodyLarge,
                      )),
                ],
              ),
            ),
            SizedBox(width: 14.sp),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: green),
                onPressed: () {
                  final cart = Provider.of<CartProvider>(context, listen: false);
                  cart.addToCart(widget.product, _quantity);

                  // Bounce animation
                  setState(() {
                    added = true;
                    _quantity = 1;
                  });
                  Future.delayed(const Duration(milliseconds: 300), () {
                    setState(() => added = false);
                  });

                  // Optional: feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${widget.product.name} added to cart", style: KTextTheme.dottedDark.bodyMedium,),
                      duration: const Duration(milliseconds: 800),
                    ),
                  );
                },
                child: Text('Add to Cart', style: KTextTheme.dottedDark.bodyLarge!.copyWith(color: Colors.black)),
              ),
            )
          ],
        ),
      ),
      backgroundColor: darkgreen,
      appBar: AppBar(
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: Image.asset('assets/icons/cart-dotted.png', height: 20.sp,),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage()))
                  ),
                  if (cart.totalItems > 0)
                    Positioned(
                      right: 12.sp,
                      top: 10.sp,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: green,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.totalItems}',
                          style: KTextTheme.dottedDark.bodySmall!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ],
        backgroundColor: darkgreen,
        leading: IconButton(
          icon: Image.asset('assets/icons/back-chev-dotted.png', color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.product.name, style: KTextTheme.dottedDark.titleMedium),
        titleSpacing: 2.sp,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(14.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.product.images[0],
                    width: double.infinity,
                    height: 35.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16.sp),
                Text(
                  widget.product.name,
                  style: KTextTheme.dottedDark.titleLarge,
                ),
                sizedfive(context),
                Row(
                  children: [
                    Text(
                      '₹${widget.product.price}',
                      style: TextStyle(fontSize: 16.sp, color: green)
                    ),
                    SizedBox(width: 13.sp),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Member Price - ₹${(double.parse(widget.product.price)-250).toInt()}', style: TextStyle(fontSize: 14.sp, color: Colors.black)),
                    ),
                  ],
                ),
                if (!isMember)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '(Become a member to unlock this price)',
                      style: KTextTheme.dottedDark.bodySmall,
                    ),
                  ),
                SizedBox(height: 14.sp),
                Divider(color: Colors.white24),
                Text('ABOUT THE PRODUCT', style: KTextTheme.dottedDark.titleMedium),
                SizedBox(height: 6.sp),
                Text(
                  "A high quality product that meets your needs and exceeds expectations. Crafted with precision and care, this product is designed to provide exceptional performance and durability.",
                  style: TextStyle(fontSize: 14.sp, color: white)
                ),
                SizedBox(height: 20.sp),
                SizedBox(height: 25.sp),
              ],
            ),
          ),
          if (widget.isLocked)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.lock, size: 36, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Unlock after 7-day streak',
                      style: TextStyle(color: Colors.white70),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
