class MemberWorkoutLog {
  final String id;
  final String workoutName;
  final int duration;
  final int calories;
  final int auraEarned;
  final DateTime date;

  MemberWorkoutLog({
    required this.id,
    required this.workoutName,
    required this.duration,
    required this.calories,
    required this.auraEarned,
    required this.date,
  });

  factory MemberWorkoutLog.fromJson(Map<String,dynamic> json){
    return MemberWorkoutLog(
      id: json["_id"],
      workoutName: json["workoutName"],
      duration: json["duration"],
      calories: json["caloriesBurned"],
      auraEarned: json["auraEarned"],
      date: DateTime.parse(json["createdAt"]),
    );
  }
}