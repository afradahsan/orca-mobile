import 'package:orca/features/ecom/data/product_model.dart';

class CartItem {
  final Product product;
  final String size;
  final String color;
  final int quantity;
  final double price;

  CartItem({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productData = json['productId'];

    return CartItem(
      product: productData is String
          ? Product(
              id: productData,
              name: '',
              description: '',
              price: '0',
              discount: 0,
              brand: '',
              material: '',
              images: [],
              category: {},
              rating: 0,
              status: '',
              sizes: [],
            )
          : Product.fromJson(productData),
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
