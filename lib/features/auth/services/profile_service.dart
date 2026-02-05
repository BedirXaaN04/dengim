import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../../../../core/utils/log_service.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

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
    final user = _currentUser;
    if (user == null) return;

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
      'isOnline': true,
    };

    try {
      await _firestore.collection('users').doc(user.uid).set(userProfile);
      LogService.i("Profile created for: ${user.uid}");
    } catch (e) {
      LogService.e("Firestore error in createProfile", e);
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile([String? uid]) async {
    final targetUid = uid ?? _currentUser?.uid;
    if (targetUid == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(targetUid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      LogService.e("Error fetching profile: $targetUid", e);
      return null;
    }
  }

  Future<String> uploadProfilePhoto(XFile file, String userId) async {
    try {
      final ref = _storage.ref().child('user_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final data = await file.readAsBytes();
      
      final uploadTask = ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));
      
      if (kIsWeb) {
        await uploadTask.timeout(const Duration(seconds: 10));
      } else {
        await uploadTask;
      }
      
      return await ref.getDownloadURL();
    } catch (e) {
      LogService.e("Upload failed", e);
      return 'https://ui-avatars.com/api/?name=${userId.substring(0, 1)}&background=EAEAEA&color=000&size=500';
    }
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'latitude': latitude,
        'longitude': longitude,
        'lastActive': FieldValue.serverTimestamp(),
        'isOnline': true,
      });
    } catch (e) {
      LogService.e("Location update failed", e);
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
       // Silently fail for online status to avoid spamming
    }
  }

  Future<void> deleteAccount() async {
    final user = _currentUser;
    if (user == null) throw Exception("Kullanıcı bulunamadı");

    try {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
      LogService.i("Account deleted: ${user.uid}");
    } catch (e) {
      LogService.e("Delete Account Error", e);
      rethrow;
    }
  }

  Future<void> addCredits(int amount) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    
    try {
      await _firestore.collection('users').doc(uid).update({
        'credits': FieldValue.increment(amount),
      });
    } catch (e) {
      LogService.e("Add credits error", e);
    }
  }
}
