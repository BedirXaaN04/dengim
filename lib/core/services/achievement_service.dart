import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/log_service.dart';
import 'analytics_service.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String badgeQuickResponder = 'quick_responder';
  static const String badgeSuperSwiper = 'super_swiper';
  static const String badgeProfilePro = 'profile_pro';
  static const String badgeMatchingStar = 'matching_star';

  /// Kullanıcının bir eylemini (mesaj, swipe, match) işler ve gerekirse rozet verir
  Future<void> checkAndAwardBadge(String badgeKey) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final List<String> currentBadges = List<String>.from(userDoc.data()?['achievements'] ?? []);

      if (currentBadges.contains(badgeKey)) return; // Zaten kazanılmış

      bool shouldAward = false;

      switch (badgeKey) {
        case badgeQuickResponder:
          final msgCount = await _getMessageCount(uid);
          if (msgCount >= 10) shouldAward = true;
          break;
        case badgeSuperSwiper:
          final swipeCount = await _getDailySwipeCount(uid);
          if (swipeCount >= 100) shouldAward = true;
          break;
        case badgeMatchingStar:
          final matchCount = await _getMatchCount(uid);
          if (matchCount >= 10) shouldAward = true;
          break;
        case badgeProfilePro:
          if (_isProfileComplete(userDoc.data())) shouldAward = true;
          break;
      }

      if (shouldAward) {
        await _awardBadge(uid, badgeKey);
      }
    } catch (e) {
      LogService.e("Error checking achievements", e);
    }
  }

  Future<void> _awardBadge(String uid, String badgeKey) async {
    await _firestore.collection('users').doc(uid).update({
      'achievements': FieldValue.arrayUnion([badgeKey]),
    });

    LogService.i("New Badge Awarded: $badgeKey to user $uid");
    
    // Analytics
    await AnalyticsService().logEvent(
      name: 'achievement_unlocked',
      parameters: {'badge_id': badgeKey},
    );
  }

  // --- Stats Helpers ---

  Future<int> _getMessageCount(String uid) async {
    final snap = await _firestore.collectionGroup('messages')
        .where('senderId', isEqualTo: uid)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<int> _getDailySwipeCount(String uid) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final snap = await _firestore.collection('users').doc(uid).collection('swipes')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(startOfDay))
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<int> _getMatchCount(String uid) async {
    final snap = await _firestore.collection('matches')
        .where('userIds', arrayContains: uid)
        .count()
        .get();
    return snap.count ?? 0;
  }

  bool _isProfileComplete(Map<String, dynamic>? data) {
    if (data == null) return false;
    return (data['bio']?.toString().isNotEmpty ?? false) &&
           (data['interests'] as List?) != null &&
           (data['photoUrls'] as List?) != null &&
           (data['photoUrls'] as List).length >= 3;
  }
}
