class Guide {
  final String id;
  final String title;
  final String category; // e.g. Workout, Nutrition, Mindfulness
  final String duration; // e.g. "5 min"
  final String? content; // text or summary
  final String? pdfUrl; // optional pdf guide

  Guide({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    this.content,
    this.pdfUrl,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      duration: json['duration'],
      content: json['content'],
      pdfUrl: json['pdfUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'duration': duration,
        'content': content,
        'pdfUrl': pdfUrl,
      };
}
