import 'package:flutter/material.dart';
import 'package:orca/core/themes/text_theme.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/ecom/domain/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      appBar: AppBar(
        backgroundColor: darkgreen,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/back-chev-dotted.png',
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Your Cart", style: KTextTheme.dottedDark.titleLarge),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Text(
                "Your cart is empty",
                style: KTextTheme.dottedDark.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(14.sp),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.sp),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10.sp),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item.product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    item.product.title,
                    style: KTextTheme.dottedDark.bodyLarge,
                  ),
                  subtitle: Text(
                    "Rs ${item.product.price.replaceAll("₹", "")} x ${item.quantity}",
                    style: KTextTheme.dottedDark.bodySmall,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Text("-", style: KTextTheme.dottedDark.bodyLarge),
                        onPressed: () => cart.decreaseQuantity(index),
                      ),
                      Text(
                        '${item.quantity}',
                        style: KTextTheme.dottedDark.bodyLarge,
                      ),
                      IconButton(
                        icon: Text("+", style: KTextTheme.dottedDark.bodyLarge),
                        onPressed: () => cart.increaseQuantity(index),
                      ),
                      IconButton(
                        icon: Image.asset('assets/icons/bin-dotted.png', height: 24.sp, color: Colors.red),
                        onPressed: () => cart.removeItem(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) return const SizedBox();

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Total", style: KTextTheme.dottedDark.bodyMedium!.copyWith(color: Colors.white70)),
                    Text(
                      "₹${cart.totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18.sp, color: green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    padding: EdgeInsets.symmetric(horizontal: 22.sp, vertical: 10.sp),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // TODO: Implement checkout flow
                  },
                  child: Text(
                    "CHECKOUT",
                    style: KTextTheme.dottedDark.bodyLarge!.copyWith(color: Colors.black),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
