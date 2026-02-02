import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orca/features/ecom/data/order_model.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final String baseUrl =
      'https://api.orcasportsclub.in/api/orders';

  Future<List<Order>> fetchOrders(String token) async {
    debugPrint('fetch called');

    final res = await http.get(
      Uri.parse(baseUrl),   // ✅ correct
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint('STATUS: ${res.statusCode}');
    debugPrint('BODY: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data.map<Order>((o) => Order.fromJson(o)).toList();
    } else {
      throw Exception("Failed to load orders");
    }
  }
}
