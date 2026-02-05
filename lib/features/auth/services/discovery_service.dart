import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/log_service.dart';
import '../models/user_profile.dart';

class DiscoveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  Future<List<UserProfile>> getUsersToMatch({
    int limit = 100,
    String? gender,
    int? minAge,
    int? maxAge,
  }) async {
    final user = _currentUser;
    if (user == null) return [];

    try {
      // 1. Get swipe history to exclude
      final swipedIdsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('swipes')
          .get();
      
      final Set<String> swipedIds = swipedIdsSnapshot.docs.map((doc) => doc.id).toSet();
      swipedIds.add(user.uid); 

      // 2. Fetch users with basic filters
      Query query = _firestore.collection('users');
      
      if (gender != null && gender != 'other') {
        query = query.where('gender', isEqualTo: gender == 'male' ? 'Erkek' : 'Kadın');
      }
      
      // Age filtering (Firestore can only handle one inequality per query if not carefully indexed)
      // We'll filter age and distance client-side for better flexibility in small user bases
      
      final snapshot = await query
          .orderBy('lastActive', descending: true)
          .limit(limit * 2) // Fetch more to allow for swiped/filter exclusion
          .get();

      final users = snapshot.docs
          .where((doc) => !swipedIds.contains(doc.id))
          .map((doc) => UserProfile.fromMap(doc.data()))
          .where((profile) {
            // Client-side age filtering
            if (minAge != null && profile.age < minAge) return false;
            if (maxAge != null && profile.age > maxAge) return false;
            return true;
          })
          .take(limit)
          .toList();

      LogService.i("Fetched ${users.length} potential matches after filters.");
      return users;
    } catch (e) {
      LogService.e("Error fetching users to match", e);
      return [];
    }
  }


  Future<bool> swipeUser(String targetUserId, bool isLike) async {
    final user = _currentUser;
    if (user == null) return false;

    try {
      // 1. Record Swipe
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('swipes')
          .doc(targetUserId)
          .set({
        'type': isLike ? 'like' : 'dislike',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!isLike) return false;

      // 2. Check for Match
      final matchDoc = await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('swipes')
          .doc(user.uid)
          .get();

      if (matchDoc.exists && matchDoc.data()?['type'] == 'like') {
        await _createMatch(user.uid, targetUserId);
        
        // Notifications
        await sendNotification(targetUserId, type: 'match', title: "Eşleşme! 🎉", body: "Tebrikler, yeni bir eşleşmen var.");
        await sendNotification(user.uid, type: 'match', title: "Eşleşme! 🎉", body: "Tebrikler, yeni bir eşleşmen var.");

        return true;
      } else {
        await sendNotification(targetUserId, type: 'like', title: "Biri seni beğendi 💖", body: "Seni beğenenleri görmek için hemen tıkla.");
      }

      return false;
    } catch (e) {
      LogService.e("Swipe Error", e);
      return false;
    }
  }

  Future<void> sendNotification(String targetUid, {required String type, required String title, required String body}) async {
    try {
      await _firestore.collection('users').doc(targetUid).collection('notifications').add({
        'type': type,
        'title': title,
        'body': body,
        'fromUid': _currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      LogService.e("Notification delivery failed", e);
    }
  }

  Future<void> _createMatch(String uid1, String uid2) async {
    final matchId = uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
    
    // 1. Create Match Record
    await _firestore.collection('matches').doc(matchId).set({
      'userIds': [uid1, uid2],
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Create Initial Conversation
    await _firestore.collection('conversations').doc(matchId).set({
      'userIds': [uid1, uid2],
      'lastMessage': 'Eşleştiniz! 🎉 İlk mesajı sen gönder.',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': 'system',
      'unreadCounts': {
        uid1: 0,
        uid2: 0,
      }
    });

    LogService.i("Match and Conversation created: $matchId");
  }


  Future<List<UserProfile>> getMatchedUsers() async {
    final user = _currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('userIds', arrayContains: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      final otherUserIds = snapshot.docs.map((doc) {
        List userIds = doc['userIds'];
        var otherId = userIds.firstWhere((id) => id != user.uid, orElse: () => null);
        return otherId;
      }).where((id) => id != null).cast<String>().toList();

      if (otherUserIds.isEmpty) return [];

      // chunking results for 'whereIn' limitation (max 10)
      final List<UserProfile> matches = [];
      for (var i = 0; i < otherUserIds.length; i += 10) {
        final chunk = otherUserIds.skip(i).take(10).toList();
        final usersSnapshot = await _firestore
            .collection('users')
            .where('uid', propertyName: 'uid', whereIn: chunk) // or using documentId
            .get();
        matches.addAll(usersSnapshot.docs.map((doc) => UserProfile.fromMap(doc.data())));
      }

      return matches;
    } catch (e) {
      LogService.e("Get Matched Users Error", e);
      return [];
    }
  }

  Future<List<UserProfile>> getActiveUsers({int limit = 15}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('lastActive', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data()))
          .toList();
    } catch (e) {
      LogService.e("Error fetching active users", e);
      return [];
    }
  }
}

