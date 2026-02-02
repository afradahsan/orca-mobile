import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orca/features/fitness/domain/exercise_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseService {
  final String baseUrl = "https://api.orcasportsclub.in/api/fitness/exercises";

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("gym_token");
  }

  Future<List<Exercise>> fetchExercises(String token) async {
    debugPrint('token in exercise service: $token');
    final response = await http.get(
      Uri.parse("$baseUrl/members"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('response exercise body: ${response.body}');
      final List data = jsonDecode(response.body);
      return data.map((e) => Exercise.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load exercises: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> addExercise(Exercise exercise, String token) async {
    debugPrint('Adding exercise with token: $token');
    final response = await http.post(
      Uri.parse("$baseUrl/add"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(exercise.toJson()),
    );

    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("RESPONSE BODY: ${response.body}");

    final body = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {"success": true, "message": body["message"]};
    } else {
      return {"success": false, "message": body["message"] ?? "Failed to add exercise"};
    }
  }

  // ✅ Update exercise
  Future<bool> updateExercise(String id, Exercise exercise, String token) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(exercise.toJson()),
    );
    return response.statusCode == 200;
  }

  // ✅ Delete exercise
  Future<bool> deleteExercise(String id, String token) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
