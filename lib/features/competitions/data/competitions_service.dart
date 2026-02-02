import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orca/features/competitions/data/competitions_model.dart';

class CompetitionService {
  final String baseUrl = "https://orcasportsclub.in/api/user";

  Future<List<Competition>> getCompetitions() async {
    final response = await http.get(Uri.parse("$baseUrl/competitions"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<dynamic> rawList = data["competitions"] ?? [];

      return rawList.map((e) => Competition.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load competitions");
    }
  }
}
