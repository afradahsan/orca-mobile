import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orca/core/constants/api_constants.dart';
import 'package:orca/features/fitness/domain/workout_log.dart';

class WorkoutLogService {
  final String baseUrl = ApiConstants.workoutLogBase;

  Future<List<WorkoutLogModel>> getWorkoutLogs(String token) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("GET Workout Logs StatusCode: ${response.statusCode}");
      debugPrint("GET Workout Logs Body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => WorkoutLogModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching workout logs: $e");
      return [];
    }
  }

  Future<bool> createWorkoutLog({
    required String token,
    required String exerciseName,
    required String category,
    required double weight,
    required int sets,
    required int reps,
    required String mood,
    DateTime? date,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "exerciseName": exerciseName,
          "category": category,
          "weight": weight,
          "sets": sets,
          "reps": reps,
          "mood": mood,
          "date": (date ?? DateTime.now()).toIso8601String(),
        }),
      );

      debugPrint("CREATE Workout Log StatusCode: ${response.statusCode}");
      debugPrint("CREATE Workout Log Body: ${response.body}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("Error creating workout log: $e");
      return false;
    }
  }

  Future<bool> deleteWorkoutLog(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error deleting workout log: $e");
      return false;
    }
  }
}