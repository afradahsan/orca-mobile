import 'package:orca/features/ecom/data/product_model.dart';

class ProductService {
  Future<List<Product>> fetchAllProducts() async {
    final List<Map<String, dynamic>> data = [
      {
        "id": "p1",
        "title": "Resistance Bands",
        "price": "699",
        "imageUrl": "assets/images/Puma-magmax.png",
        "category": "equipment"
      },
      {
        "id": "p2",
        "title": "Whey Protein",
        "price": "1999",
        "imageUrl": "assets/images/Puma-magmax.png",
        "category": "supplement"
      },
      {
        "id": "p3",
        "title": "Orca Tee",
        "price": "499",
        "imageUrl": "assets/images/Puma-magmax.png",
        "category": "merch"
      },
    ];

    return data.map((e) => Product.fromJson(e)).toList();
  }
}
