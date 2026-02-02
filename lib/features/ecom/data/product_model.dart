class Product {
  final String id;
  final String name;
  final String description;
  final String price;
  final double discount;
  final String brand;
  final String material;
  final List<String> images;
final Map<String, dynamic> category;
  final double rating;
  final String status;
  final List<ProductSize> sizes;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discount,
    required this.brand,
    required this.material,
    required this.images,
    required this.category,
    required this.rating,
    required this.status,
    required this.sizes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] ?? 0).toString(),
      discount: (json['discount'] ?? 0).toDouble(),
      brand: json['brand'] ?? '',
      material: json['material'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? {},
      rating: (json['rating'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      sizes: (json['sizes'] as List? ?? [])
          .map((e) => ProductSize.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'description': description,
        'price': price,
        'discount': discount,
        'brand': brand,
        'material': material,
        'images': images,
        'category': category,
        'rating': rating,
        'status': status,
        'sizes': sizes.map((e) => e.toJson()).toList(),
      };
}

class ProductSize {
  final String size;
  final List<ProductColor> colors;

  ProductSize({
    required this.size,
    required this.colors,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      size: json['size'] ?? '',
      colors: (json['colors'] as List? ?? [])
          .map((e) => ProductColor.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'size': size,
        'colors': colors.map((e) => e.toJson()).toList(),
      };
}

class ProductColor {
  final String color;
  final int stock;

  ProductColor({
    required this.color,
    required this.stock,
  });

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
      color: json['color'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'color': color,
        'stock': stock,
      };
}
