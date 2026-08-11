class Order {
  final String id;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      status: json['status'] ?? '',
      total: (json['grandTotal'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['products'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
    );
  }
}

class OrderItem {
  final String productName;
  final String image;
  final double price;

  OrderItem({
    required this.productName,
    required this.image,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};

    return OrderItem(
      productName: product['name'] ?? '',
      image: (product['images'] != null &&
              (product['images'] as List).isNotEmpty)
          ? product['images'][0]
          : '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}