import 'dart:convert';

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

  String get categoryName {
    if (category.containsKey('name') && category['name'] != null && category['name'].toString().trim().isNotEmpty) {
      return category['name'].toString().trim();
    }
    if (category.containsKey('title') && category['title'] != null && category['title'].toString().trim().isNotEmpty) {
      return category['title'].toString().trim();
    }
    return 'General';
  }

  factory Product.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      // Log or handle the unexpected data type
      print('Expected Map but got ${json.runtimeType}: $json');
      return Product.empty(); // Assuming you have a static empty constructor
    }

    final categoryData = json['category'];

    Map<String, dynamic> categoryMap = {};

    if (categoryData is String) {
      try {
        final decodedCategory = jsonDecode(categoryData);
        if (decodedCategory is Map<String, dynamic>) {
          categoryMap = decodedCategory;
        } else {
          print('Decoded category is not a Map: ${decodedCategory.runtimeType}');
        }
      } catch (e) {
        print('Error decoding category string: $e');
      }
    } else if (categoryData is Map<String, dynamic>) {
      categoryMap = categoryData;
    } else {
      print('Unexpected type for category: ${categoryData.runtimeType}');
    }

    print('Parsing product: $json');
    print('Expected Map but got ${json.runtimeType}: $json');

    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toString(),
      discount: (json['discount'] ?? 0).toDouble(),
      brand: json['brand'] ?? '',
      material: json['material'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      category: categoryMap,
      rating: (json['rating'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      sizes: (json['sizes'] as List? ?? []).map((e) => ProductSize.fromJson(e)).toList(),
    );
  }

  factory Product.empty() {
    return Product(id: '', name: '', description: '', price: '', discount: 0, brand: '', material: '', images: [], category: {}, rating: 0, status: '', sizes: []);
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
      colors: (json['colors'] as List? ?? []).map((e) => ProductColor.fromJson(e)).toList(),
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
