import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/log_service.dart';
import 'analytics_service.dart';

class ReferralService {
  static final ReferralService _instance = ReferralService._internal();
  factory ReferralService() => _instance;
  ReferralService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Yeni kullanıcı için benzersiz referral kodu üretir (DNG-12345)
  String generateCode() {
    final random = Random();
    final number = random.nextInt(900000) + 100000;
    return 'DNG-$number';
  }

  /// Profil oluşturulurken referral kodunu set eder
  Future<void> initializeUserReferral(String uid) async {
    final code = generateCode();
    await _firestore.collection('users').doc(uid).update({
      'referralCode': code,
    });
    LogService.i("Referral code initialized for $uid: $code");
  }

  /// Bir başkasının kodunu kullanarak ödül kazanma işlemi
  Future<bool> applyReferralCode(String code) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    try {
      // 1. Kodu kullanan kullanıcının profilini al
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.data()?['referredBy'] != null) {
        LogService.w("User already referred by someone");
        return false;
      }

      // 2. Kodun sahibi olan kullanıcıyı bul
      final query = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: code.trim().toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        LogService.w("Invalid referral code: $code");
        return false;
      }

      final referrerDoc = query.docs.first;
      final referrerUid = referrerDoc.id;

      if (referrerUid == currentUser.uid) {
        LogService.w("User cannot refer themselves");
        return false;
      }

      // 3. Ödülleri Dağıt (+50 Kredi her iki tarafa)
      final batch = _firestore.batch();
      
      // Davet eden (Referrer)
      batch.update(_firestore.collection('users').doc(referrerUid), {
        'credits': FieldValue.increment(50),
      });

      // Davet edilen (Current User)
      batch.update(_firestore.collection('users').doc(currentUser.uid), {
        'referredBy': referrerUid,
        'credits': FieldValue.increment(50),
      });

      await batch.commit();

      // 4. Log & Analytics
      LogService.i("Referral applied! $referrerUid referred ${currentUser.uid}");
      await AnalyticsService().logEvent(
        name: 'referral_applied',
        parameters: {
          'referrer_id': referrerUid,
          'code': code,
        },
      );

      return true;
    } catch (e) {
      LogService.e("Error applying referral code", e);
      return false;
    }
  }
}
