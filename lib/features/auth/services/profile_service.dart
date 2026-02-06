import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../../../core/utils/log_service.dart';
import '../../../core/services/cloudinary_service.dart';
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
      // Firebase Storage yerine Cloudinary kullanıyoruz (Ücretsiz)
      final imageUrl = await CloudinaryService.uploadImage(file);
      
      if (imageUrl != null) {
        return imageUrl;
      }
      
      throw Exception("Upload failed");
    } catch (e) {
      LogService.e("Upload failed, reverting to placeholder", e);
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

  /// Kullanıcı profilini güncelle
  Future<void> updateProfile({
    String? name,
    String? bio,
    String? job,
    String? education,
    int? age,
    String? country,
    List<String>? interests,
    List<String>? photoUrls,
    bool? isPremium,
    bool? isVerified,
  }) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    final Map<String, dynamic> updates = {
      'lastActive': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name;
    if (bio != null) updates['bio'] = bio;
    if (job != null) updates['job'] = job;
    if (education != null) updates['education'] = education;
    if (age != null) updates['age'] = age;
    if (country != null) updates['country'] = country;
    if (interests != null) updates['interests'] = interests;
    if (photoUrls != null) updates['photoUrls'] = photoUrls;
    if (isPremium != null) updates['isPremium'] = isPremium;
    if (isVerified != null) updates['isVerified'] = isVerified;

    try {
      await _firestore.collection('users').doc(uid).update(updates);
      LogService.i("Profile updated for: $uid");
    } catch (e) {
      LogService.e("Profile update error", e);
      rethrow;
    }
  }
}
