import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orca/features/fitness/domain/exercise_model.dart';
import 'package:orca/features/fitness/domain/member_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GymOwnerService {
  final String baseUrl = 'https://orcasportsclub.in/api/gym-owner';
  final String fitnessUrl = 'https://orcasportsclub.in/api/fitness/exercises';

  Future<Map<String, dynamic>> registerGymOwner({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gymName,
    required String gymAddress,
    required String licenseId,
  }) async {
    final uri = Uri.parse('$baseUrl/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
        "gymName": gymName,
        "gymAddress": gymAddress,
        "licenseId": licenseId,
      }),
    );

    debugPrint('Response status: ${response.statusCode}, body: ${response.body}');

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {"success": true, "message": body["message"]};
    } else {
      return {"success": false, "message": body["message"] ?? "Registration failed. Try again."};
    }
  }

  Future<Map<String, dynamic>> loginGymOwner(String email, String password) async {
    final uri = Uri.parse('$baseUrl/login');

    final bodyData = {
      "email": email,
      "password": password,
    };

    debugPrint("🟢 Sending login payload: ${jsonEncode(bodyData)}");

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      debugPrint("🟣 Response status: ${response.statusCode}");
      debugPrint("🟣 Response body: ${response.body}");

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": body["message"],
          "token": body["token"],
          "user": body["user"],
        };
      } else {
        return {
          "success": false,
          "message": body["message"] ?? "Login failed. Try again.",
        };
      }
    } catch (e) {
      debugPrint("❌ Error during login: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }

  Future<String?> _getToken() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("gym_token");
  }

  Future<bool> addExercise(Map<String, dynamic> data) async {
    final token = await _getToken();
    final uri = Uri.parse("$baseUrl/add");

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 201;
  }

  Future<List<dynamic>> getExercises() async {
    final token = await _getToken();
    final uri = Uri.parse(fitnessUrl);

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );

    debugPrint("GET all status: ${response.statusCode}");
    debugPrint("GET all body: ${response.body}");

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
       .map((e) => Exercise.fromJson(e))
       .toList();

    } else {
      throw Exception("Failed to load exercises");
    }
  }

  Future<bool> addMember(String email, String phone) async {
    final token = await _getToken();

    debugPrint('Add Member called. $token');

    final response = await http.post(
      Uri.parse("$baseUrl/members/add"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "email": email,
        "phone": phone,
      }),
    );

    debugPrint('returned: ${response.statusCode}, ${response.body}');

    return response.statusCode == 201;
  }

  Future<List<MemberModel>> getMembers() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/members"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      return (body as List).map((m) => MemberModel.fromJson(m)).toList();
    } else {
      throw Exception("Failed to get members");
    }
  }
}
