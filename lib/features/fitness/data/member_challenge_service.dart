import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:orca/core/constants/api_constants.dart';
import 'package:orca/features/fitness/domain/member_challenge_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberChallengeService {
  final String baseUrl = ApiConstants.challengesBase;

  Future<MemberChallengeProgress> getProgress(String challengeId, String token) async {
    final prefs = await SharedPreferences.getInstance();

    // Try fetching from backend first if available
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/$challengeId/progress"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return MemberChallengeProgress.fromJson(body);
      }
    } catch (e) {
      debugPrint("MemberChallengeService getProgress remote error (falling back to local): $e");
    }

    // Fallback to local progress in SharedPreferences
    final completed = prefs.getInt("challenge_progress_$challengeId") ?? 0;
    final streak = prefs.getInt("challenge_streak_$challengeId") ?? 1;
    final lastLoggedStr = prefs.getString("challenge_last_log_$challengeId");
    final lastLogged = lastLoggedStr != null ? DateTime.tryParse(lastLoggedStr) : null;

    return MemberChallengeProgress(
      challengeId: challengeId,
      completedWorkouts: completed,
      weeklyTarget: 5,
      streak: streak,
      totalAura: completed * 50,
      auraEarnedToday: 50,
      lastLoggedDate: lastLogged,
    );
  }

  Future<MemberChallengeProgress> logWorkout(String challengeId, String token) async {
    final prefs = await SharedPreferences.getInstance();

    // Increment local progress
    int completed = (prefs.getInt("challenge_progress_$challengeId") ?? 0) + 1;
    int streak = prefs.getInt("challenge_streak_$challengeId") ?? 1;
    final now = DateTime.now();

    await prefs.setInt("challenge_progress_$challengeId", completed);
    await prefs.setString("challenge_last_log_$challengeId", now.toIso8601String());

    // Try syncing with backend
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/$challengeId/log"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "completedWorkouts": completed,
          "loggedAt": now.toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return MemberChallengeProgress.fromJson(body);
      }
    } catch (e) {
      debugPrint("MemberChallengeService logWorkout remote sync error: $e");
    }

    return MemberChallengeProgress(
      challengeId: challengeId,
      completedWorkouts: completed,
      weeklyTarget: 5,
      streak: streak,
      totalAura: completed * 50,
      auraEarnedToday: 50,
      lastLoggedDate: now,
    );
  }
}
