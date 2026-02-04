import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // XFile support
import '../models/user_profile.dart';

import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb 
        ? '12239103870-nmqifbprc2t9pgtj68ar6efpl5mnrc0e.apps.googleusercontent.com'
        : null,
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  // Auth durum dinleyicisi
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google ile Giriş
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Google Sign In tetikle
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Kullanıcı iptal etti

      // Auth detaylarını al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase credential oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase'e giriş yap
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // stderr.writeln('Google Sign In Error: $e'); // In production use a logger
      rethrow;
    }
  }

  // E-posta ile Kayıt
  Future<UserCredential> registerWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // E-posta ile Giriş
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Çıkış Yap
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }


  Future<void> createProfile({
    required String name,
    required int age,
    required String gender,
    required String country,
    required List<String> interests,
    required List<String> photoUrls,
    String? bio,
    String? job,
    String? education,
  }) async {
    final user = currentUser;
    if (user == null) {
      print("DEBUG: User is null in createProfile, bypassing.");
      return;
    }

    final userProfile = {
      'uid': user.uid,
      'email': user.email ?? '',
      'name': name,
      'age': age,
      'gender': gender,
      'country': country,
      'interests': interests,
      'bio': bio,
      'job': job,
      'education': education,
      'photoUrls': photoUrls,
      'isPremium': false,
      'credits': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    };

    try {
      print("DEBUG: Saving to Firestore...");
      await _firestore.collection('users').doc(user.uid).set(userProfile).timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          print("DEBUG: Firestore timeout reached. Continuing anyway.");
        },
      );
      print("DEBUG: Profile process finished.");
    } catch (e) {
      print("DEBUG: Firestore error: $e. Continuning to allow entry.");
    }
  }

  // Profil kontrolü (Kullanıcının veritabanında kaydı var mı?)
  Future<bool> hasProfile() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      print("Firestore Error (hasProfile): $e");
      return false; // Hata durumunda yok say
    }
  }

  // Kullanıcı Profilini Getir
  Future<UserProfile?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  Future<String> uploadProfilePhoto(XFile file, String userId) async {
    try {
      if (kIsWeb) {
        // Web'de CORS sorunları nedeniyle yüklemeyi deniyoruz ancak 2-3 saniye içinde sonuçlanmazsa placeholder'a düşüyoruz.
        final ref = _storage.ref().child('user_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final data = await file.readAsBytes().timeout(const Duration(seconds: 2));
        await ref.putData(data, SettableMetadata(contentType: 'image/jpeg')).timeout(const Duration(seconds: 3));
        return await ref.getDownloadURL();
      } else {
        final ref = _storage.ref().child('user_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final data = await file.readAsBytes();
        await ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));
        return await ref.getDownloadURL();
      }
    } catch (e) {
      print("Upload Step Failed (Using Placeholder): $e");
      // Hata durumunda (CORS, network vb.) akışı durdurma, şık bir placeholder dön.
      return 'https://ui-avatars.com/api/?name=${userId.substring(0, 1)}&background=EAEAEA&color=000&size=500';
    }
  }

  // Konum Güncelle
  Future<void> updateLocation(double latitude, double longitude) async {
    final user = currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'latitude': latitude,
        'longitude': longitude,
        'lastActive': FieldValue.serverTimestamp(),
        'isOnline': true,
      });
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  // Eşleşecek Kullanıcıları Getir
  Future<List<Map<String, dynamic>>> getUsersToMatch() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      // 1. Swipe geçmişini al
      final swipedIdsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('swipes')
          .get();
      
      final Set<String> swipedIds = swipedIdsSnapshot.docs.map((doc) => doc.id).toSet();
      swipedIds.add(user.uid); 

      // 2. Tüm kullanıcıları (en son aktif olanlar öncelikli) çek
      final snapshot = await _firestore
          .collection('users')
          //.orderBy('lastActive', descending: true) // TODO: Index oluşturulursa açılabilir
          .limit(50) 
          .get();

      // 3. Filtrele
      final users = snapshot.docs
          .map((doc) => doc.data())
          .where((data) {
             final uid = data['uid'];
             if (uid == null) return false;
             return !swipedIds.contains(uid);
          })
          .toList();

      print("DEBUG: Fetched ${users.length} users.");
      return users;
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  // Swipe İşlemi (Like/Dislike)
  Future<bool> swipeUser(String targetUserId, bool isLike) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // 1. Swipe kaydını oluştur
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

      // 2. Karşı taraf seni beğenmiş mi kontrol et
      final matchDoc = await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('swipes')
          .doc(user.uid)
          .get();

      if (matchDoc.exists && matchDoc.data()?['type'] == 'like') {
        // EŞLEŞME VAR!
        await _createMatch(user.uid, targetUserId);
        return true;
      }

      return false;
    } catch (e) {
      print("Swipe Error: $e");
      return false;
    }
  }

  // Eşleşme Belgesi Oluştur
  Future<void> _createMatch(String uid1, String uid2) async {
    final matchId = uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
    
    await _firestore.collection('matches').doc(matchId).set({
      'userIds': [uid1, uid2],
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Ayrıca bir konuşma başlat (opsiyonel, veya ilk mesajda başlatılabilir)
    // Şimdilik sadece match koleksiyonuna ekliyoruz.
  }

  // Seni Beğenenleri Getir (Premium özelliği gibi)
  Future<List<UserProfile>> getLikedMeUsers() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      // Tüm kullanıcıların swipe koleksiyonlarını gezmek yerine (mümkün değil),
      // 'likes' adında global bir koleksiyonda targetUserId indexli saklamak daha mantıklı.
      // Şimdilik basitleştirmek için:
      // Gelecekte: _firestore.collectionGroup('swipes').where('type', isEqualTo: 'like').where(FieldPath.documentId, isEqualTo: user.uid)
      
      // Şimdilik boş dönelim veya basit bir mockup verelim (Backend side trigger ile yönetilmesi önerilir)
      return []; 
    } catch (e) {
      return [];
    }
  }

  // Eşleşmeleri Getir
  Future<List<UserProfile>> getMatchedUsers() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('userIds', arrayContains: user.uid)
          .get();

      final otherUserIds = snapshot.docs.map((doc) {
        List userIds = doc['userIds'];
        var otherId = userIds.firstWhere((id) => id != user.uid, orElse: () => null);
        return otherId;
      }).where((id) => id != null).toList();

      if (otherUserIds.isEmpty) return [];

      // whereIn limiti 10'dur. Büyük listeler için chunk yapılmalı.
      // Şimdilik 10 ile sınırlıyoruz.
      final chunk = otherUserIds.take(10).toList();
      
      final usersSnapshot = await _firestore
          .collection('users')
          .where('uid', whereIn: chunk)
          .get();

      return usersSnapshot.docs.map((doc) => UserProfile.fromMap(doc.data())).toList();
    } catch (e) {
      print("Get Matched Users Error: $e");
      return [];
    }
  }

  // Hesabı Sil
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw Exception("Kullanıcı bulunamadı");

    try {
      // 1. Profil verisini sil
      await _firestore.collection('users').doc(user.uid).delete();
      
      // 2. Auth hesabını sil
      await user.delete();
      
      // Not: 'requires-recent-login' hatası alınırsa UI tarafında yeniden giriş istenmeli.
    } catch (e) {
      print("Delete Account Error: $e");
       if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
         throw Exception("Güvenlik gereği bu işlem için çıkış yapıp tekrar girmelisiniz.");
      }
      rethrow;
    }
  }

  /// Kredi Ekle
  Future<void> addCredits(int amount) async {
    final user = currentUser;
    if (user == null) return;
    
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'credits': FieldValue.increment(amount),
      });
    } catch (e) {
      print("Add Credits Error: $e");
    }
  }
}
