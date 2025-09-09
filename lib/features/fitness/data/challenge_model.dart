import 'challenge_task_model.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final int target; // total tasks or sessions
  int progress; // how many completed
  final List<ChallengeTask> tasks;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    this.progress = 0,
    required this.tasks,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      target: json['target'],
      progress: json['progress'] ?? 0,
      tasks: (json['tasks'] as List)
          .map((e) => ChallengeTask.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'target': target,
        'progress': progress,
        'tasks': tasks.map((e) => e.toJson()).toList(),
      };
}
