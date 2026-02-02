import 'package:orca/features/ecom/data/cart_model.dart';

class CartResponse {
  final List<CartItem> items;
  final double totalPrice;

  CartResponse({
    required this.items,
    required this.totalPrice,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      items: (json['items'] as List)
          .map((e) => CartItem.fromJson(e))
          .toList(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }
}
