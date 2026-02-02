import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/ecom/data/product_model.dart';
import 'package:orca/features/fitness/domain/role_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';


class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isLocked;
  final bool showPrice;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isLocked = false,
    this.showPrice = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMember = Provider.of<RoleProvider>(context, listen: false).isMember;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        height: 160,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                product.images[0],
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),

            Positioned(
              bottom: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                       style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Doto')),
                  if (showPrice) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          product.price,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isMember ? green : Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Member Price',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),

            // 🔒 LOCKED OVERLAY
            if (isLocked)
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.7),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.lock, color: Colors.white, size: 30),
                      SizedBox(height: 6),
                      Text(
                        'Unlock after 7-day streak',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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
}
