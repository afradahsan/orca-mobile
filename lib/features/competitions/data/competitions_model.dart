class Competition {
  final String id;
  final String name;
  final List<String> category;
  final List<String> image;
  final String time;
  final DateTime date;
  final String place;
  final List<String> state;
  final String district;
  final String town;
  final int duration;
  final List<String> type;
  final double cost;
  final int maxRegistrations;
  final String description;
  final String status;

  Competition({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.time,
    required this.date,
    required this.place,
    required this.state,
    required this.district,
    required this.town,
    required this.duration,
    required this.type,
    required this.cost,
    required this.maxRegistrations,
    required this.description,
    required this.status,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      category: List<String>.from(json['category'] ?? []),
      image: List<String>.from(json['image'] ?? []),
      time: json['time'] ?? "",
      date: DateTime.tryParse(json['date'] ?? "") ?? DateTime.now(),
      place: json['place'] ?? "",
      state: List<String>.from(json['state'] ?? []),
      district: json['district'] ?? "",
      town: json['town'] ?? "",
      duration: json['duration'] ?? 0,
      type: List<String>.from(json['type'] ?? []),
      cost: (json['cost'] ?? 0).toDouble(),
      maxRegistrations: json['maxRegistrations'] ?? 0,
      description: json['description'] ?? "",
      status: json['status'] ?? "inactive",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "category": category,
      "image": image,
      "time": time,
      "date": date.toIso8601String(),
      "place": place,
      "state": state,
      "district": district,
      "town": town,
      "duration": duration,
      "type": type,
      "cost": cost,
      "maxRegistrations": maxRegistrations,
      "description": description,
      "status": status,
    };
  }
}
  