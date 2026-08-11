import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling background message: ${message.messageId}");
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'orca_notifications_channel';
  static const String channelName = 'ORCA Notifications';
  static const String channelDesc =
      'Notifications for fitness competitions, challenges & announcements';

  bool _initialized = false;

  Future<void> initialize({Function(String? payload)? onNotificationTap}) async {
    if (_initialized) return;

    // 1️⃣ Request Push Notification Permissions (Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('User notification permission status: ${settings.authorizationStatus}');

    // 2️⃣ Initialize Local Notifications for Heads-Up System Tray Alerts
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (onNotificationTap != null && response.payload != null) {
          onNotificationTap(response.payload);
        }
      },
    );

    // 3️⃣ Create High Importance Notification Channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
    }

    // 4️⃣ Configure Foreground FCM Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        showLocalNotification(
          title: notification.title ?? 'ORCA Update',
          body: notification.body ?? '',
          payload: message.data['actionTarget'],
        );
      }
    });

    // 5️⃣ Configure Background/Terminated Notification Open Listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (onNotificationTap != null) {
        onNotificationTap(message.data['actionTarget']);
      }
    });

    // 6️⃣ Register Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 7️⃣ Subscribe Device to Broadcast Topic
    try {
      await _fcm.subscribeToTopic('all_users');
      debugPrint('Successfully subscribed device to topic: all_users');
    } catch (e) {
      debugPrint('Topic subscription warning: $e');
    }

    // Print FCM Token for debug/backend push testing
    try {
      String? token = await _fcm.getToken();
      debugPrint('📲 FCM Device Token: $token');
    } catch (e) {
      debugPrint('FCM token fetch error: $e');
    }

    _initialized = true;
  }

  /// Displays an instant System Tray / Lock Screen Device Push Notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
