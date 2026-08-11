import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orca/features/notifications/domain/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  static const String _storageKey = 'orca_user_notifications';

  List<NotificationItem> _notifications = [];
  bool _isLoaded = false;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get isLoaded => _isLoaded;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString(_storageKey);

    if (savedJson != null && savedJson.isNotEmpty) {
      _notifications = NotificationItem.decodeList(savedJson);
    } else {
      // Seed default initial notifications if none exist
      _notifications = _getDefaultNotifications();
      await _saveToStorage();
    }

    _isLoaded = true;
    notifyListeners();
  }

  List<NotificationItem> _getDefaultNotifications() {
    final now = DateTime.now();
    return [
      NotificationItem(
        id: 'default_1',
        title: '🏆 New Competition Announced!',
        message: 'The Summer Powerlifting Championship 2026 registration is now live. Register today to compete!',
        category: 'Competition',
        createdAt: now.subtract(const Duration(minutes: 45)),
        isRead: false,
        actionTarget: 'competitions',
      ),
      NotificationItem(
        id: 'default_2',
        title: '💪 Weekly Fitness Challenge Active',
        message: 'Push your limits with the new 7-Day Calisthenics Routine. Track your progress now!',
        category: 'Fitness',
        createdAt: now.subtract(const Duration(hours: 4)),
        isRead: false,
        actionTarget: 'fitness',
      ),
      NotificationItem(
        id: 'default_3',
        title: '🔥 ORCA Apparel Drop',
        message: 'Check out the new gym gear and merch collection in the ORCA Store.',
        category: 'Merch',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        actionTarget: 'ecom',
      ),
    ];
  }

  Future<void> addNotification({
    required String title,
    required String message,
    String category = 'General',
    String? actionTarget,
  }) async {
    final newItem = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      category: category,
      createdAt: DateTime.now(),
      isRead: false,
      actionTarget: actionTarget,
    );

    _notifications.insert(0, newItem);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    bool hasUnread = false;
    for (var notif in _notifications) {
      if (!notif.isRead) {
        notif.isRead = true;
        hasUnread = true;
      }
    }

    if (hasUnread) {
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = NotificationItem.encodeList(_notifications);
    await prefs.setString(_storageKey, encoded);
  }
}
