import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orca/core/constants/api_constants.dart';
import '../data/cart_response.dart';

class CartService {
  final String baseUrl = ApiConstants.cartBase;

  Future<CartResponse> getCart(String token) async {
    debugPrint('statement reached cart service with token: $token');
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

  Future<void> removeFromCart({
    required String token,
    required String cartId,
  }) async {
    debugPrint("Removing cart item $cartId");

    final res = await http.put(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "cartId": cartId,
        "quantity": 0, // 👈 THIS triggers delete
      }),
    );

    debugPrint("Remove cart response: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to remove item");
    }
  }

  Future<void> updateCart({
    required String token,
    required String cartId,
    required int quantity,
  }) async {
    final res = await http.put(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "cartId": cartId,
        "quantity": quantity,
      }),
    );

    debugPrint("Update Cart Response: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to update cart");
    }
  }
}
