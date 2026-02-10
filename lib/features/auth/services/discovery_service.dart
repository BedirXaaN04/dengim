import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/log_service.dart';
import '../models/user_profile.dart';

class DiscoveryService {
  static final DiscoveryService _instance = DiscoveryService._internal();
  factory DiscoveryService() => _instance;
  DiscoveryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  Future<List<UserProfile>> getUsersToMatch({
    int limit = 100,
    String? gender,
    int? minAge,
    int? maxAge,
    List<String>? interests,
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
      
      // 1.5 Engellenen kullanıcıları elenenler listesine ekle
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final blockedUsers = List<String>.from(userDoc.data()?['blockedUsers'] ?? []);
        swipedIds.addAll(blockedUsers);
      }

      // 2. Fetch users with basic filters
      Query baseQuery = _firestore.collection('users');
      Query activeQuery = baseQuery;
      
      // Gender Filter
      if (gender != null && gender != 'all' && gender != 'other') {
        activeQuery = activeQuery.where('gender', isEqualTo: gender == 'male' ? 'Erkek' : 'Kadın');
      }

      // Interests Filter (Optimization: Use array-contains-any for server-side filtering)
      if (interests != null && interests.isNotEmpty) {
        // Firestore limits array-contains-any to 10 elements
        activeQuery = activeQuery.where('interests', arrayContainsAny: interests.take(10).toList());
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
            if (!profile.isComplete) return false;
            if (profile.name.toLowerCase().contains('test') || 
                profile.email.toLowerCase().contains('test')) {
              return false;
            }
            if (snapshot.docs.length > 5) {
              if (minAge != null && profile.age < minAge) return false;
              if (maxAge != null && profile.age > maxAge) return false;
            }
            return true;
          })
          .toList();

      // SMART RANKING v2.0
      final currentUserProfile = await _getProfileSync(user.uid);
      if (currentUserProfile != null) {
        users.sort((a, b) {
          final scoreA = _calculateCompatibilityScore(currentUserProfile, a);
          final scoreB = _calculateCompatibilityScore(currentUserProfile, b);
          return scoreB.compareTo(scoreA); // High score first
        });
      }

      LogService.i("Final discovery fetch: Found ${users.length} users ranked by score");
      return users.take(limit).toList();
    } catch (e) {
      LogService.e("Critical failure in discovery query", e);
      return [];
    }
  }


  Future<bool> swipeUser(String targetUserId, {String swipeType = 'like'}) async {
    final user = _currentUser;
    if (user == null) return false;

    final isLike = swipeType == 'like' || swipeType == 'super_like';

    try {
      // 1. Record Swipe in my swipes collection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('swipes')
          .doc(targetUserId)
          .set({
        'type': swipeType,
        'targetId': targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      LogService.i("Swipe recorded for $targetUserId: ${isLike ? 'like' : 'dislike'}");

      if (!isLike) return false;

      // 2. Add to target user's "likes" collection (who liked them)
      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('likes')
          .doc(user.uid)
          .set({
        'fromUserId': user.uid,
        'type': swipeType,
        'timestamp': FieldValue.serverTimestamp(),
        'viewed': false, // For badge counting
      });

      LogService.i("Like added to $targetUserId's likes collection");

      // 3. Check for Match (did they also like us?)
      LogService.i("Checking for match with $targetUserId...");
      final matchDoc = await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('swipes')
          .doc(user.uid)
          .get();

      if (matchDoc.exists && (matchDoc.data()?['type'] == 'like' || matchDoc.data()?['type'] == 'super_like')) {
        LogService.i("MATCH FOUND! Creating match...");
        await _createMatch(user.uid, targetUserId);
        
        // Mark the likes as viewed/matched to avoid double badges
        await _firestore.collection('users').doc(targetUserId).collection('likes').doc(user.uid).set({
          'fromUserId': user.uid,
          'type': swipeType,
          'timestamp': FieldValue.serverTimestamp(),
          'viewed': true, // Auto view since it's a match
          'matched': true,
        });

        await _firestore.collection('users').doc(user.uid).collection('likes').doc(targetUserId).get().then((doc) {
          if (doc.exists) {
            doc.reference.update({'viewed': true, 'matched': true});
          }
        });

        // Send match notifications to both users
        await sendNotification(targetUserId, type: 'match', title: "Eşleşme! 🎉", body: "Tebrikler, yeni bir eşleşmen var!");
        await sendNotification(user.uid, type: 'match', title: "Eşleşme! 🎉", body: "Tebrikler, yeni bir eşleşmen var!");

        return true;
      } else {
        // No match yet - send like notification
        await sendNotification(targetUserId, type: 'like', title: "Biri seni beğendi 💖", body: "Seni beğenenleri görmek için hemen tıkla!");
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
      'seenBy': [], // Tracking who viewed the match
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

  /// Beni beğenen kullanıcıları getir
  Future<List<UserProfile>> getLikedMeUsers() async {
    final user = _currentUser;
    if (user == null) return [];

    try {
      // Direkt kendi likes koleksiyonumdan beğenenleri çek
      final likesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('likes')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      if (likesSnapshot.docs.isEmpty) {
        LogService.i("No likes found for current user");
        return [];
      }

      // Beğenen kullanıcı ID'lerini çıkar
      final likerUids = likesSnapshot.docs
          .map((doc) => doc.data()['fromUserId'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toList();

      LogService.i("Found ${likerUids.length} users who liked me");

      if (likerUids.isEmpty) return [];

      // Profilleri getir (10'arlık chunk'lar halinde)
      final List<UserProfile> likers = [];
      for (var i = 0; i < likerUids.length; i += 10) {
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

  /// Beğeniyi kabul et (like back) - Eşleşme oluştur
  Future<bool> likeBack(String targetUserId) async {
    final user = _currentUser;
    if (user == null) return false;

    try {
      // Bu aslında normal bir beğeni, ama zaten bizi beğenmiş biri olduğu için eşleşme olacak
      final matched = await swipeUser(targetUserId, swipeType: 'like');
      
      if (matched) {
        // Eşleşme olduysa, likes koleksiyonundan kaldırılabilir (viewed olarak işaretle)
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('likes')
            .doc(targetUserId)
            .update({'viewed': true, 'matched': true});
      }
      
      return matched;
    } catch (e) {
      LogService.e("Like back error", e);
      return false;
    }
  }

  /// Beğeniyi reddet
  Future<void> rejectLike(String targetUserId) async {
    final user = _currentUser;
    if (user == null) return;

    try {
      // Kendi swipes koleksiyonuma 'dislike' olarak kaydet
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('swipes')
          .doc(targetUserId)
          .set({
        'type': 'dislike',
        'targetId': targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Likes koleksiyonundan kaldır veya işaretle
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('likes')
          .doc(targetUserId)
          .delete();

      LogService.i("Rejected like from $targetUserId");
    } catch (e) {
      LogService.e("Reject like error", e);
    }
  }

  // --- PRIVATE HELPERS ---

  Future<UserProfile?> _getProfileSync(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!);
  }

  int _calculateCompatibilityScore(UserProfile current, UserProfile other) {
    int score = 0;

    // 1. Common Interests (+10 each)
    final commonInterests = current.interests.where((i) => other.interests.contains(i)).length;
    score += commonInterests * 10;

    // 2. Profile Completeness (+5 bio, +5 many photos)
    if (other.bio != null && other.bio!.isNotEmpty) score += 5;
    if ((other.photoUrls?.length ?? 0) >= 3) score += 5;

    // 3. Activity (+5 if active in last 24h)
    final hoursSinceActive = DateTime.now().difference(other.lastActive).inHours;
    if (hoursSinceActive < 24) score += 5;

    // 4. Distance Penalty (-1 per 10km, max -30)
    if (current.latitude != null && current.longitude != null && 
        other.latitude != null && other.longitude != null) {
      // Very basic distance approximation for scoring (not for precision)
      final dLat = (current.latitude! - other.latitude!).abs();
      final dLon = (current.longitude! - other.longitude!).abs();
      final approxKm = (dLat + dLon) * 111; // 1 degree ~ 111km
      score -= (approxKm / 10).clamp(0, 30).toInt();
    }

    return score;
  }
}


