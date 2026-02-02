// import 'package:orca/features/fitness/domain/workout_log.dart';

// class MemberWorkoutService {
//   Future<List<MemberWorkoutLog>> getWorkoutHistory(String token) async {
//     final res = await http.get(
//       Uri.parse("$baseUrl/api/member/workouts"),
//       headers: {"Authorization": "Bearer $token"},
//     );
//     final List data = jsonDecode(res.body);
//     return data.map((e)=>MemberWorkoutLog.fromJson(e)).toList();
//   }
// }