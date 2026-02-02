class ChallengeTask {
  final String id;
  final String day; // e.g. "Monday"
  final String taskName;
  bool completed;

  ChallengeTask({
    required this.id,
    required this.day,
    required this.taskName,
    this.completed = false,
  });
  
  factory ChallengeTask.fromJson(Map<String, dynamic> json) {
    return ChallengeTask(
      id: json['id'],
      day: json['day'],
      taskName: json['taskName'],
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'taskName': taskName,
        'completed': completed,
      };
}
