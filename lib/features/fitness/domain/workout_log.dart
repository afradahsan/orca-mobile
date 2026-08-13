class WorkoutLogModel {
  final String id;
  final String exerciseName;
  final String category;
  final double weight;
  final int sets;
  final int reps;
  final String mood;
  final DateTime date;

  WorkoutLogModel({
    required this.id,
    required this.exerciseName,
    required this.category,
    required this.weight,
    required this.sets,
    required this.reps,
    required this.mood,
    required this.date,
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogModel(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      exerciseName: (json["exerciseName"] ?? json["workoutName"] ?? "").toString(),
      category: (json["category"] ?? "General").toString(),
      weight: (json["weight"] == null) ? 0.0 : (double.tryParse(json["weight"].toString()) ?? 0.0),
      sets: (json["sets"] == null) ? 0 : (int.tryParse(json["sets"].toString()) ?? 0),
      reps: (json["reps"] == null) ? 0 : (int.tryParse(json["reps"].toString()) ?? 0),
      mood: (json["mood"] ?? "🙂").toString(),
      date: json["date"] != null
          ? DateTime.tryParse(json["date"].toString()) ?? DateTime.now()
          : (json["createdAt"] != null
              ? DateTime.tryParse(json["createdAt"].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "exerciseName": exerciseName,
      "category": category,
      "weight": weight,
      "sets": sets,
      "reps": reps,
      "mood": mood,
      "date": date.toIso8601String(),
    };
  }
}