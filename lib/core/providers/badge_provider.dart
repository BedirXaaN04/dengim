import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/log_service.dart';

class BadgeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _chatUnreadCount = 0;
  int _matchCount = 0;
  int _likeCount = 0;

  int get chatBadge => _chatUnreadCount;
  int get likesBadge => _matchCount + _likeCount;
  int get totalBadges => chatBadge + likesBadge;

  void initialize() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Listen to unread messages
    _firestore
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .snapshots()
        .listen((snapshot) {
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final lastMessage = data['lastMessage'] as String?;
        final lastSenderId = data['lastSenderId'] as String?;
        final readBy = List<String>.from(data['readBy'] ?? []);
        
        if (lastMessage != null && lastSenderId != uid && !readBy.contains(uid)) {
          unreadCount++;
        }
      }
      _chatUnreadCount = unreadCount;
      notifyListeners();
    }, onError: (e) {
      LogService.e("Badge Provider: Chat listener error", e);
    });

    // Listen to new matches (last 24h)
    _firestore
        .collection('matches')
        .where('users', arrayContains: uid)
        .where('matchedAt', isGreaterThan: Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 24))))
        .snapshots()
        .listen((snapshot) {
      _matchCount = snapshot.docs.length;
      notifyListeners();
    }, onError: (e) {
      LogService.e("Badge Provider: Match listener error", e);
    });

    // Listen to new likes
    _firestore
        .collection('users')
        .doc(uid)
        .collection('likes')
        .where('viewed', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      _likeCount = snapshot.docs.length;
      notifyListeners();
    }, onError: (e) {
      LogService.e("Badge Provider: Like listener error", e);
    });
  }

  void markChatAsRead(String conversationId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'readBy': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      LogService.e("Failed to mark chat as read", e);
    }
  }

  void markLikesAsViewed() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final likesSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('likes')
          .where('viewed', isEqualTo: false)
          .get();

      for (var doc in likesSnapshot.docs) {
        await doc.reference.update({'viewed': true});
      }
    } catch (e) {
      LogService.e("Failed to mark likes as viewed", e);
    }
  }
}
