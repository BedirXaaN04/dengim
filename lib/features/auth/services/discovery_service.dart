import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/log_service.dart';
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
      Query baseQuery = _firestore.collection('users');
      Query activeQuery = baseQuery;
      
      if (gender != null && gender != 'other') {
        activeQuery = activeQuery.where('gender', isEqualTo: gender == 'male' ? 'Erkek' : 'Kadın');
      }
      
      // Try fetching with orderBy first
      QuerySnapshot snapshot;
      try {
        snapshot = await activeQuery
            .orderBy('lastActive', descending: true)
            .limit(limit * 3)
            .get();
        
        // Strategy A: No results? Maybe missing lastActive field or restrictive gender.
        // Strategy A: No results? Maybe missing lastActive field or restrictive gender.
        // We will try without ordering by lastActive, but we MUST keep the gender filter.
        if (snapshot.docs.isEmpty) {
          LogService.w("No results with gender/lastActive. Trying without lastActive ordering.");
          snapshot = await activeQuery.limit(limit * 3).get();
        }
      } catch (e) {
        LogService.w("Query failed (possible index error), trying fallback queries: $e");
        // Fallback: Try without order, BUT KEEP FILTERS (activeQuery)
        snapshot = await activeQuery.limit(limit * 3).get();
      }


      final users = snapshot.docs
          .where((doc) => !swipedIds.contains(doc.id))
          .map((doc) {
            try {
              return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
            } catch (e) {
              LogService.e("Error parsing user profile for ${doc.id}", e);
              return null;
            }
          })
          .where((profile) => profile != null)
          .cast<UserProfile>()
          .where((profile) {
            // Filter out test accounts (name or email contains 'test')
            if (profile.name.toLowerCase().contains('test') || 
                profile.email.toLowerCase().contains('test')) {
              return false;
            }
            
            // Client-side age filtering - only apply if we have enough users
            if (snapshot.docs.length > 5) {
              if (minAge != null && profile.age < minAge) return false;
              if (maxAge != null && profile.age > maxAge) return false;
            }
            return true;
          })
          .take(limit)
          .toList();


      LogService.i("Final discovery fetch: Found ${users.length} users (Original raw docs: ${snapshot.docs.length})");
      return users;
    } catch (e) {
      LogService.e("Critical failure in discovery query", e);
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
        'targetId': targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      LogService.i("Swipe recorded for $targetUserId: ${isLike ? 'like' : 'dislike'}");

      if (!isLike) return false;

      // 2. Check for Match
      LogService.i("Checking for match with $targetUserId...");
      final matchDoc = await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('swipes')
          .doc(user.uid)
          .get();

      if (matchDoc.exists) {
         LogService.i("Match doc found. Type: ${matchDoc.data()?['type']}");
      } else {
         LogService.w("Match doc NOT found at users/$targetUserId/swipes/${user.uid}");
      }

      if (matchDoc.exists && matchDoc.data()?['type'] == 'like') {
        LogService.i("creating match...");
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
            .where(FieldPath.documentId, whereIn: chunk)
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
  Stream<List<String>> getMatchedUserIdsStream() {
    final user = _currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('matches')
        .where('userIds', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            List userIds = doc['userIds'];
            return userIds.firstWhere((id) => id != user.uid, orElse: () => '') as String;
          }).where((id) => id.isNotEmpty).toList();
        });
  }

  /// Beni beğenen kullanıcıları getir (Premium özellik)
  Future<List<UserProfile>> getLikedMeUsers() async {
    final user = _currentUser;
    if (user == null) return [];

    try {
      // swipes alt koleksiyonundaki bu kullanıcıyı beğenenleri bul
      final likedMeSnapshot = await _firestore
          .collectionGroup('swipes')
          .where(FieldPath.documentId, isEqualTo: user.uid)
          .get();

      // Bu swipe'ların ana kullanıcı uid'lerini çıkar
      final likerUids = <String>[];
      for (final doc in likedMeSnapshot.docs) {
        if (doc.data()['type'] == 'like') {
          // Parent path: users/{uid}/swipes/{targetUid}
          final pathSegments = doc.reference.path.split('/');
          if (pathSegments.length >= 2) {
            likerUids.add(pathSegments[1]); // uid at index 1
          }
        }
      }

      if (likerUids.isEmpty) return [];

      // Bu kullanıcıların profillerini getir (max 10 chunk)
      final List<UserProfile> likers = [];
      for (var i = 0; i < likerUids.length && i < 30; i += 10) {
        final chunk = likerUids.skip(i).take(10).toList();
        final usersSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        likers.addAll(usersSnapshot.docs.map((doc) => UserProfile.fromMap(doc.data())));
      }

      return likers;
    } catch (e) {
      LogService.e("Get Liked Me Users Error", e);
      return [];
    }
  }
}


