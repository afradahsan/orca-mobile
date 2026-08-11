import 'dart:convert';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String category; // 'Competition', 'Fitness', 'General', 'Merch'
  final DateTime createdAt;
  bool isRead;
  final String? actionTarget; // e.g., 'competitions', 'fitness'

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.createdAt,
    this.isRead = false,
    this.actionTarget,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionTarget': actionTarget,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      category: json['category'] ?? 'General',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      actionTarget: json['actionTarget'],
    );
  }

  static List<NotificationItem> decodeList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => NotificationItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static String encodeList(List<NotificationItem> items) {
    return jsonEncode(items.map((e) => e.toJson()).toList());
  }
}
