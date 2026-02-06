import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/log_service.dart';
import '../../features/auth/services/profile_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. İzin İste
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      LogService.i('User granted permission');
      
      // 2. Token Al ve Kaydet
      try {
        String? token = await _fcm.getToken();
        if (token != null) {
          await ProfileService().updateFcmToken(token);
        }
      } catch (e) {
        LogService.w("FCM Token fetch failed (Web might need VAPID key): $e");
      }
      
      // Token yenilenirse güncelle
      _fcm.onTokenRefresh.listen((token) {
        ProfileService().updateFcmToken(token);
      });

      // 3. Foreground Mesajları Dinle
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        LogService.i('Got a message whilst in the foreground!');
        
        if (message.notification != null) {
          _showLocalNotification(message);
        }
      });
      
    } else {
      LogService.w('User declined or has not accepted permission');
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
     LogService.i("Notification Received: ${message.notification?.title}");
     // Implementation for local notifications can be added here
  }
}
