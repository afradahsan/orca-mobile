class Exercise {
  final String id;
  final String name;
  final String? description;
  final String type;
  final String category;
  final String difficulty;
  final int duration; // minutes
  final int sets;
  final int reps;
  final int restTime; // seconds
  final List<String> equipment;
  final List<String> targetMuscles;
  final String? videoUrl;
  final String? imageUrl;
  final int? caloriesBurned;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.sets,
    required this.reps,
    required this.restTime,
    required this.equipment,
    required this.targetMuscles,
    this.videoUrl,
    this.imageUrl,
    this.caloriesBurned,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      category: json['category'],
      difficulty: json['difficulty'],
      duration: json['duration'],
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 10,
      restTime: json['restTime'] ?? 30,
      equipment: List<String>.from(json['equipment'] ?? []),
      targetMuscles: List<String>.from(json['targetMuscles'] ?? []),
      videoUrl: json['videoUrl'],
      imageUrl: json['imageUrl'],
      caloriesBurned: json['caloriesBurned'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'type': type,
        'category': category,
        'difficulty': difficulty,
        'duration': duration,
        'sets': sets,
        'reps': reps,
        'restTime': restTime,
        'equipment': equipment,
        'targetMuscles': targetMuscles,
        'videoUrl': videoUrl,
        'imageUrl': imageUrl,
        'caloriesBurned': caloriesBurned,
      };
}
