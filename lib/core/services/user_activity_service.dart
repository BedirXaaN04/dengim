import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/log_service.dart';

/// User Activity Service
/// Kullanıcının çevrimiçi/çevrimdışı durumunu ve son görülme zamanını yönetir
class UserActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final UserActivityService _instance = UserActivityService._internal();
  factory UserActivityService() => _instance;
  UserActivityService._internal();

  /// Kullanıcıyı çevrimiçi yap
  Future<void> setUserOnline() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });
      LogService.i('User set to online: $userId');
    } catch (e) {
      LogService.e('Error setting user online', e);
    }
  }

  /// Kullanıcıyı çevrimdışı yap
  Future<void> setUserOffline() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
      LogService.i('User set to offline: $userId');
    } catch (e) {
      LogService.e('Error setting user offline', e);
    }
  }

  /// Son görülme zamanını güncelle
  Future<void> updateLastSeen() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LogService.e('Error updating last seen', e);
    }
  }

  /// Kullanıcı aktivitesini kaydet (analytics için)
  Future<void> logActivity({
    required String activityType,
    Map<String, dynamic>? metadata,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('user_activity').add({
        'userId': userId,
        'activityType': activityType,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
      });
    } catch (e) {
      LogService.e('Error logging activity', e);
    }
  }

  /// Profil görüntülenme sayısını artır
  Future<void> incrementProfileView(String profileUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || currentUserId == profileUserId) return;

    try {
      // Profil görüntülenme sayısını artır
      await _firestore.collection('users').doc(profileUserId).update({
        'profileViews': FieldValue.increment(1),
      });

      // Görüntülenme kaydı tut
      await _firestore
          .collection('users')
          .doc(profileUserId)
          .collection('profile_viewers')
          .doc(currentUserId)
          .set({
        'viewedAt': FieldValue.serverTimestamp(),
        'viewerName': _auth.currentUser?.displayName ?? 'Unknown',
      }, SetOptions(merge: true));

      LogService.i('Profile view incremented for: $profileUserId');
    } catch (e) {
      LogService.e('Error incrementing profile view', e);
    }
  }

  /// Swipe aksiyonunu kaydet (analytics)
  Future<void> logSwipeAction({
    required String targetUserId,
    required bool isLike,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await logActivity(
        activityType: 'swipe',
        metadata: {
          'targetUserId': targetUserId,
          'action': isLike ? 'like' : 'pass',
        },
      );

      // Kullanıcının beğeni/geçme istatistiklerini güncelle
      final field = isLike ? 'totalLikes' : 'totalPasses';
      await _firestore.collection('users').doc(userId).update({
        field: FieldValue.increment(1),
      });
    } catch (e) {
      LogService.e('Error logging swipe action', e);
    }
  }

  /// Mesaj gönderilme sayısını artır
  Future<void> incrementMessageCount() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'totalMessages': FieldValue.increment(1),
      });
    } catch (e) {
      LogService.e('Error incrementing message count', e);
    }
  }

  /// Story görüntülenme sayısını artır
  Future<void> incrementStoryView(String storyUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || currentUserId == storyUserId) return;

    try {
      await _firestore
          .collection('users')
          .doc(storyUserId)
          .collection('stories')
          .doc('current')
          .update({
        'views': FieldValue.increment(1),
        'viewers': FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      LogService.e('Error incrementing story view', e);
    }
  }

  /// Aktif olmayan kullanıcıları tespit et (7 gün)
  Future<List<String>> getInactiveUsers({int daysInactive = 7}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysInactive));

      final snapshot = await _firestore
          .collection('users')
          .where('lastSeen', isLessThan: Timestamp.fromDate(cutoffDate))
          .limit(100)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      LogService.e('Error getting inactive users', e);
      return [];
    }
  }

  /// Kullanıcı engagement skoru hesapla
  Future<double> calculateEngagementScore(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData == null) return 0.0;

      // Engagement faktörleri
      final profileViews = (userData['profileViews'] ?? 0) as int;
      final totalLikes = (userData['totalLikes'] ?? 0) as int;
      final totalMessages = (userData['totalMessages'] ?? 0) as int;
      final matchCount = (userData['matchCount'] ?? 0) as int;
      
      final lastSeen = userData['lastSeen'] as Timestamp?;
      final daysSinceLastSeen = lastSeen != null
          ? DateTime.now().difference(lastSeen.toDate()).inDays
          : 999;

      // Skor hesaplama (0-100 arası)
      double score = 0;
      score += (profileViews * 0.1).clamp(0, 20); // Max 20 puan
      score += (totalLikes * 0.5).clamp(0, 25); // Max 25 puan
      score += (totalMessages * 0.2).clamp(0, 25); // Max 25 puan
      score += (matchCount * 2).clamp(0, 20); // Max 20 puan
      score -= (daysSinceLastSeen * 2).clamp(0, 30); // Aktiflik cezası

      return score.clamp(0, 100);
    } catch (e) {
      LogService.e('Error calculating engagement score', e);
      return 0.0;
    }
  }
}

/// Activity Tracker Widget
/// Uygulama lifecycle'ını takip eder ve kullanıcı durumunu günceller
class ActivityTracker extends StatefulWidget {
  final Widget child;

  const ActivityTracker({super.key, required this.child});

  @override
  State<ActivityTracker> createState() => _ActivityTrackerState();
}

class _ActivityTrackerState extends State<ActivityTracker>
    with WidgetsBindingObserver {
  final _activityService = UserActivityService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activityService.setUserOnline();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _activityService.setUserOffline();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _activityService.setUserOnline();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _activityService.setUserOffline();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Screen View Tracker
/// Ekran görüntülemelerini takip eder
class ScreenViewTracker extends StatefulWidget {
  final String screenName;
  final Widget child;
  final Map<String, dynamic>? metadata;

  const ScreenViewTracker({
    super.key,
    required this.screenName,
    required this.child,
    this.metadata,
  });

  @override
  State<ScreenViewTracker> createState() => _ScreenViewTrackerState();
}

class _ScreenViewTrackerState extends State<ScreenViewTracker> {
  final _activityService = UserActivityService();

  @override
  void initState() {
    super.initState();
    _logScreenView();
  }

  void _logScreenView() {
    _activityService.logActivity(
      activityType: 'screen_view',
      metadata: {
        'screenName': widget.screenName,
        ...?widget.metadata,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
