class Exercise {
  final String id;
  final String title;
  final String category;
  final String duration; // e.g. "12 min"
  final String difficulty; // e.g. Beginner, Intermediate, Advanced
  final List<String> steps; // step-by-step instructions
  final int calories;
  final String? videoUrl; // optional video/tutorial link
  final String? description;

  Exercise({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.steps,
    required this.calories,
    this.videoUrl,
    this.description
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      duration: json['duration'],
      difficulty: json['difficulty'],
      steps: List<String>.from(json['steps']),
      calories: json['calories'],
      videoUrl: json['videoUrl'],
      description: json['description']
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'duration': duration,
        'difficulty': difficulty,
        'steps': steps,
        'calories': calories,
        'videoUrl': videoUrl,
        'description': description
      };
}
