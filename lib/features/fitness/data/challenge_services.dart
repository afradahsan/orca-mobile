import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/challenge_model.dart';

class ChallengeService {
  final String baseUrl = "https://api.orcasportsclub.in/api/user/challenges";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("gym_token");
  }

  // ✔ Fetch all challenges
  Future<List<Challenge>> getChallenges(String token) async {

    final res = await http.get(
      Uri.parse("$baseUrl"),
      headers: {"Authorization": "Bearer $token"},
    );

    debugPrint("Challenges Response: ${res.statusCode} - ${res.body}");

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return (body as List).map((c) => Challenge.fromJson(c)).toList();
    } else {
      throw Exception("Failed to fetch challenges");
    }
  }

  // ✔ Create challenge
  Future<bool> createChallenge(Map<String, dynamic> data) async {
    final token = await _getToken();

    final res = await http.post(
      Uri.parse("$baseUrl"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(data),
    );

    return res.statusCode == 201;
  }
}
