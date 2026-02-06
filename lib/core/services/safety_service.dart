import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/log_service.dart';

class SafetyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcıyı Şikayet Et
  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('reports').add({
        'reporterId': uid,
        'reportedId': reportedUserId,
        'reason': reason,
        'description': description,
        'status': 'pending', // pending, reviewed, resolved
        'timestamp': FieldValue.serverTimestamp(),
      });
      LogService.i("User $reportedUserId reported by $uid");
    } catch (e) {
      LogService.e("Report error", e);
      rethrow;
    }
  }

  // Kullanıcıyı Engelle
  Future<void> blockUser(String blockedUserId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // 1. Engellenenler listesine ekle
      await _firestore.collection('users').doc(uid).update({
        'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
      });

      LogService.i("User $blockedUserId blocked by $uid");
    } catch (e) {
      LogService.e("Block error", e);
      rethrow;
    }
  }
}
