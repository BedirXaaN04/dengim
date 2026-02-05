import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/log_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. İzin İste
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      LogService.i("Notification permission granted.");
    }

    // 2. Yerel Bildirim Kurulumu (Foreground bildirimler için)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(initializationSettings);

    // 3. Foreground Mesajlarını Dinle
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LogService.i("Handling a foreground message: ${message.messageId}");
      _showLocalNotification(message);
    });

    // 4. Token Güncelleme
    updateToken();
  }

  static Future<void> updateToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        LogService.i("FCM Token updated.");
      }
    } catch (e) {
      LogService.e("Error updating FCM token", e);
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? "Yeni Bildirim",
      message.notification?.body ?? "",
      details,
    );
  }
}
