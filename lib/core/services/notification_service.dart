import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/log_service.dart';
import '../../features/auth/services/profile_service.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

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
        String? token = await _fcm.getToken(
          vapidKey: kIsWeb ? "BMwS-s3k...EXAMPLE...KEY" : null 
        );
        
        if (token != null) {
          await ProfileService().updateFcmToken(token);
        }
      } catch (e) {
        // Web'de VAPID key yoksa veya service worker yoksa hata verebilir.
        LogService.w("FCM Token fetch warning: $e");
      }
      
      // Token yenilenirse güncelle
      _fcm.onTokenRefresh.listen((token) {
        ProfileService().updateFcmToken(token);
      });

      // 3. Foreground Mesajları Dinle
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        LogService.i('Notification Received: ${message.notification?.title}');
      });
      
    } else {
      LogService.w('User declined permission');
    }
  }
}
