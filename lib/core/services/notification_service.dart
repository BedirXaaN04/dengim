import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/log_service.dart';
import '../../features/auth/services/profile_service.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription? _firestoreSubscription;

  Future<void> initialize() async {
    // 1. Android/iOS Local Notification Setup
    if (!kIsWeb) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await _localNotifications.initialize(initializationSettings);
    }

    // 2. Request Permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      LogService.i('User granted FCM permission');
      
      // 3. Get and Save FCM Token
      try {
        String? token = await _fcm.getToken();
        if (token != null) {
          await ProfileService().updateFcmToken(token);
        }
      } catch (e) {
        LogService.w("FCM Token fetch warning: $e");
      }
      
      _fcm.onTokenRefresh.listen((token) {
        ProfileService().updateFcmToken(token);
      });

      // 4. Foreground FCM Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        LogService.i('FCM Received: ${message.notification?.title}');
        if (!kIsWeb) {
          _showLocalNotification(
            id: message.hashCode,
            title: message.notification?.title ?? "Yeni Bildirim",
            body: message.notification?.body ?? "",
          );
        }
      });

      // 5. Firestore Push-like Listener (DEMO MODE)
      _startFirestoreListener();
      
    } else {
      LogService.w('User declined permission');
    }
  }

  void _startFirestoreListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _firestoreSubscription?.cancel();
    _firestoreSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _showLocalNotification(
              id: change.doc.id.hashCode,
              title: data['title'] ?? 'Yeni Bildirim',
              body: data['body'] ?? '',
            );
            // Mark as read after showing
            change.doc.reference.update({'isRead': true});
          }
        }
      }
    });
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'dengim_match_channel',
      'Dengim Eşleşmeler',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> updateToken() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await NotificationService().initialize();
    }
  }

  void dispose() {
    _firestoreSubscription?.cancel();
  }
}
