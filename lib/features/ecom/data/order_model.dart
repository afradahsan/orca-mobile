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

  factory Order.fromJson(Map<String,dynamic> json) {
    return Order(
      id: json['_id'],
      status: json['status'],
      total: (json['totalPrice'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['items'] as List).map((i)=>OrderItem.fromJson(i)).toList(),
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

  factory OrderItem.fromJson(Map<String,dynamic> json) {
    return OrderItem(
      productName: json['productId']['name'],
      image: json['productId']['images'][0],
      price: (json['price']).toDouble(),
    );
  }
}