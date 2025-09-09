class Product {
  final String id;
  final String title;
  final String price;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      category: json['category'],
    );
  }
}
