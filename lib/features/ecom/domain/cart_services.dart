import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/cart_response.dart';

class CartService {
  final String baseUrl = "https://api.orcasportsclub.in/api/user/cart";

  Future<CartResponse> getCart(String token) async {
    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("Cart response status: ${res.body}");

    if (res.statusCode == 200) {
      return CartResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to fetch cart");
    }
  }

  Future<void> addToCart({
    required String token,
    required String productId,
    required String size,
    required String color,
    required int quantity,
    required double price,
  }) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "productId": productId,
        "size": size,
        "color": color,
        "quantity": quantity,
        "price": price,
      }),
    );
  }

  Future<void> removeFromCart(String token, String productId) async {
    final res = await http.delete(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "productId": productId,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to remove item");
    }
  }

  Future<void> updateCart({
    required String token,
    required String productId,
    required int quantity,
  }) async {
    final res = await http.put(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "productId": productId,
        "quantity": quantity,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update cart");
    }
  }
}
