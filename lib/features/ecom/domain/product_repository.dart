import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/product_model.dart';

class ProductService {
  final String baseUrl = 'https://orca-1-nie0.onrender.com/api/user/shop-products';

  Future<List<Product>> fetchAllProducts() async {
    final uri = Uri.parse(baseUrl);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      print('success: ${response.statusCode}');
      print('success: ${response.body}');
      final data = json.decode(response.body);

      if (data['products'] == null) {
        print('No products key found in response!');
        return [];
      }

      final List products = data['products'];
      print('✅ Parsed ${products.length} products');
      return products.map((e) => Product.fromJson(e)).toList();
    } else {
      print('Failed with status ${response.statusCode}');
      throw Exception('Failed to load products');
    }
  }
}
