class Challenge {
  final String id;
  final String title;
  final String? description;
  final String difficulty;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> exerciseIds;
  final bool isActive;
  final int progress;
  final int target;

  Challenge(
      {required this.id,
      required this.title,
      this.description,
      required this.difficulty,
      required this.durationDays,
      required this.startDate,
      required this.endDate,
      required this.exerciseIds,
      required this.isActive,
      required this.progress,
      required this.target});

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      difficulty: json['difficulty'],
      durationDays: json['durationDays'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      exerciseIds: (json['exercises'] as List<dynamic>?)?.map((e) => e is Map ? e['_id'] as String : e.toString()).toList() ?? [],
      isActive: json['isActive'] ?? true,
      progress: json['progress'] ?? 0,
      target: json['target'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'difficulty': difficulty,
        'durationDays': durationDays,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'exercises': exerciseIds,
        'isActive': isActive,
      };
}
