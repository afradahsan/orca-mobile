import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orca/features/ecom/data/address_model.dart';
import 'package:http/http.dart' as http;

class AddressService {
  final String baseUrl = "https://api.orcasportsclub.in/api/user/addresses";

  Future<List<Address>> fetchAddresses(String token) async {
    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint("Address API status: ${res.statusCode}");
    debugPrint("Address API body: ${res.body}");

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Address.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load addresses");
    }
  }

  Future<void> addAddress(Map<String, dynamic> body, String token) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 201) {
      throw Exception("Failed to add address");
    }
  }
}
