import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orca/core/constants/api_constants.dart';

class AuthServices {
  final String baseUrl = ApiConstants.userBase;

  Future<bool> checkUserByPhone(String phone) async {
    final uri = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": phone,
          "password": "dummyPassword123", // random password for existence check
        }),
      );

      final body = jsonDecode(response.body);
      debugPrint("checkUserByPhone: -- User exists status ${response.statusCode}, $body");

      // ✅ If backend says "Invalid credentials" — user exists
      if (response.statusCode == 401 && body['error']?.toString().contains("Invalid credentials") == true) {
        return true;
      }

      // ✅ If backend says "User not found" — double-check alternative format (+91 vs local 10-digit)
      if (response.statusCode == 401 && body['error']?.toString().contains("User not found") == true) {
        String altPhone;
        if (phone.startsWith('+91')) {
          altPhone = phone.replaceFirst('+91', '').trim();
        } else if (phone.length == 10) {
          altPhone = '+91$phone';
        } else {
          return false;
        }

        try {
          final altResponse = await http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "phone": altPhone,
              "password": "dummyPassword123",
            }),
          );
          final altBody = jsonDecode(altResponse.body);
          if (altResponse.statusCode == 401 && altBody['error']?.toString().contains("Invalid credentials") == true) {
            return true;
          }
        } catch (_) {}

        return false;
      }

      // Fallback (other cases)
      throw Exception("Unexpected response: ${body.toString()}");
    } catch (e) {
      debugPrint("Error checking user existence: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    final Uri uri = Uri.parse('$baseUrl/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['token'] != null) {
      return body;
    }

    // If failed, try alternative phone format (+91 vs local 10-digit)
    String? altPhone;
    if (phone.startsWith('+91')) {
      altPhone = phone.replaceFirst('+91', '').trim();
    } else if (phone.length == 10) {
      altPhone = '+91$phone';
    }

    if (altPhone != null) {
      try {
        final altResponse = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': altPhone, 'password': password}),
        );
        final altBody = jsonDecode(altResponse.body);
        if (altResponse.statusCode == 200 && altBody['token'] != null) {
          return altBody;
        }
      } catch (_) {}
    }

    return body;
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final uri = Uri.parse('$baseUrl/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyOtpAndRegister({
    required String phone,
    required String otp,
  }) async {
    final uri = Uri.parse('$baseUrl/verify-otp');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'otp': otp,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final uri = Uri.parse("$baseUrl/$userId");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Failed to fetch user: ${response.body}");
      return null;
    }
  }
}
