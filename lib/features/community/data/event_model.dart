class EventModel {
  final EventType type;
  final String title;
  final String imagePath;
  final String location;
  final DateTime date;
  final String time;
  final Map<String, dynamic> extra;

  EventModel({
    required this.type,
    required this.title,
    required this.imagePath,
    required this.location,
    required this.date,
    required this.time,
    required this.extra,
  });
}

enum EventType { trek, competition, ride }