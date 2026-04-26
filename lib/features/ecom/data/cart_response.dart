import 'package:orca/features/ecom/data/cart_model.dart';
import 'dart:convert';

class CartResponse {
  final List<CartItem> items;
  final double totalPrice;

  CartResponse({
    required this.items,
    required this.totalPrice,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    // Safeguard for 'items' field
    final itemsJson = json['items'];
    List<CartItem> parsedItems = [];

    if (itemsJson is List) {
      final validItems = itemsJson.where((element) => element is Map<String, dynamic>).cast<Map<String, dynamic>>();
      parsedItems = validItems.map((e) => CartItem.fromJson(e)).toList();
    } else {
      // If 'items' is missing or not a list, default to empty list
      parsedItems = [];
    }

    return CartResponse(
      items: parsedItems,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }
}