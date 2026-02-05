import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/log_service.dart';
import '../../../core/services/base_service.dart';
import '../models/user_profile.dart';

/// Kullanıcı engelleme servisi
/// Engelleme, engel kaldırma ve engellenen kullanıcı listesi yönetimi
class BlockService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final BlockService _instance = BlockService._internal();
  factory BlockService() => _instance;
  BlockService._internal();

  User? get _currentUser => _auth.currentUser;

  /// Kullanıcıyı engelle
  Future<bool> blockUser(String blockedUserId) async {
    final user = _currentUser;
    if (user == null) return false;

    return await safeAsync(() async {
      // İki yönlü engelleme kaydı
      await _firestore.collection('blocks').doc('${user.uid}_$blockedUserId').set({
        'blockerId': user.uid,
        'blockedId': blockedUserId,
        'blockedAt': FieldValue.serverTimestamp(),
      });

      // Kullanıcının blocked listesine ekle
      await _firestore.collection('users').doc(user.uid).update({
        'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
      });

      LogService.i('User $blockedUserId blocked successfully');
      return true;
    }, operationName: 'blockUser', defaultValue: false) ?? false;
  }

  /// Engeli kaldır
  Future<bool> unblockUser(String blockedUserId) async {
    final user = _currentUser;
    if (user == null) return false;

    return await safeAsync(() async {
      // Engel kaydını sil
      await _firestore.collection('blocks').doc('${user.uid}_$blockedUserId').delete();

      // Kullanıcının blocked listesinden çıkar
      await _firestore.collection('users').doc(user.uid).update({
        'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
      });

      LogService.i('User $blockedUserId unblocked successfully');
      return true;
    }, operationName: 'unblockUser', defaultValue: false) ?? false;
  }

  /// Kullanıcının engellenip engellenmediğini kontrol et
  Future<bool> isBlocked(String userId) async {
    final user = _currentUser;
    if (user == null) return false;

    return await safeAsync(() async {
      final doc = await _firestore.collection('blocks').doc('${user.uid}_$userId').get();
      return doc.exists;
    }, operationName: 'isBlocked', defaultValue: false) ?? false;
  }

  /// Karşılıklı engel kontrolü (ben engelledim mi VEYA o beni engelledi mi)
  Future<bool> hasBlockRelation(String userId) async {
    final user = _currentUser;
    if (user == null) return false;

    return await safeAsync(() async {
      // Ben onu engelledim mi?
      final iBlocked = await _firestore.collection('blocks').doc('${user.uid}_$userId').get();
      if (iBlocked.exists) return true;

      // O beni engelledi mi?
      final theyBlocked = await _firestore.collection('blocks').doc('${userId}_${user.uid}').get();
      return theyBlocked.exists;
    }, operationName: 'hasBlockRelation', defaultValue: false) ?? false;
  }

  /// Engellediğim kullanıcılar listesi
  Future<List<String>> getBlockedUserIds() async {
    final user = _currentUser;
    if (user == null) return [];

    return await safeAsync(() async {
      final snapshot = await _firestore
          .collection('blocks')
          .where('blockerId', isEqualTo: user.uid)
          .get();

      return snapshot.docs.map((doc) => doc['blockedId'] as String).toList();
    }, operationName: 'getBlockedUserIds', defaultValue: <String>[]) ?? [];
  }

  /// Engellediğim kullanıcıların profilleri
  Future<List<UserProfile>> getBlockedUsers() async {
    final blockedIds = await getBlockedUserIds();
    if (blockedIds.isEmpty) return [];

    return await safeAsync(() async {
      final List<UserProfile> blockedUsers = [];
      
      // Firestore whereIn max 10 limit
      for (var i = 0; i < blockedIds.length; i += 10) {
        final chunk = blockedIds.skip(i).take(10).toList();
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        
        blockedUsers.addAll(
          snapshot.docs.map((doc) => UserProfile.fromMap(doc.data()))
        );
      }
      
      return blockedUsers;
    }, operationName: 'getBlockedUsers', defaultValue: <UserProfile>[]) ?? [];
  }

  /// Beni engelleyen kullanıcı sayısı (Sadece admin kullanımı için)
  Future<int> getBlockedByCount() async {
    final user = _currentUser;
    if (user == null) return 0;

    return await safeAsync(() async {
      final snapshot = await _firestore
          .collection('blocks')
          .where('blockedId', isEqualTo: user.uid)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    }, operationName: 'getBlockedByCount', defaultValue: 0) ?? 0;
  }
}
