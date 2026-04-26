import 'package:flutter/material.dart';
import 'package:orca/features/ecom/data/product_model.dart';

class CartItem {
  final String id;
  final Product product;
  final String size;
  final String color;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(dynamic json) {
    final productData = json['productId'];
    late Product product;

    if (productData is Map<String, dynamic>) {
      // Full product object available
      product = Product.fromJson(productData);
    } else if (productData is String) {
      // Only product ID available, handle accordingly
      product = Product(id: productData, name: '', description: '', price: '', discount: 0, brand: '', material: '', images: [], category: {}, rating: 0, status: '', sizes: []);
      // Optionally, trigger a fetch to get full product details here
    } else {
      product = Product.empty();
    }

    return CartItem(
      id: json['_id'] ?? '',
      product: product,
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
