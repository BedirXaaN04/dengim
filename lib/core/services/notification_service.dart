import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../utils/log_service.dart';

// Sadece mobil için gerekli olan paketleri koşullu içe aktarabiliriz veya 
// içerde kIsWeb ile kontrol edebiliriz.
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Web'de bu plugin'in bazı özellikleri hata verebilir, bu yüzden dikkatli kullanmalıyız.
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web için sadece temel FCM izni
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      return;
    }

    // --- MOBİL ÖZEL AYARLAR ---
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      LogService.i("Notification permission granted.");
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LogService.i("Handling a foreground message: ${message.messageId}");
      _showLocalNotification(message);
    });

    updateToken();
  }

  static Future<void> updateToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      String? token = await _messaging.getToken(
        // Web için VAPID anahtarı gerekebilir
        vapidKey: kIsWeb ? "BHX6SzRp1uGY9SvV63rwACM8wiuef3LPfV2ykGNB_SQUmKFD91aRwP23kTsoJ9O3xpS1fytE6Im6UVX4cwjdUkw" : null
      );
      
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'platform': kIsWeb ? 'web' : 'mobile'
        });
        LogService.i("FCM Token updated.");
      }
    } catch (e) {
      LogService.e("Error updating FCM token", e);
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return; // Web'de yerel bildirim farklı çalışır

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
