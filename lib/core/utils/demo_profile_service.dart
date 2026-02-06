import 'dart:convert';
import 'package:flutter/services.dart';
import '../../features/auth/models/user_profile.dart';
import 'log_service.dart';

/// Demo profil servisi - Firebase boş olduğunda lokal JSON'dan profil yükler
class DemoProfileService {
  static List<UserProfile>? _cachedProfiles;
  
  /// Demo profilleri yükle
  static Future<List<UserProfile>> getDemoProfiles() async {
    // Cache kontrolü
    if (_cachedProfiles != null) {
      return _cachedProfiles!;
    }
    
    try {
      final jsonString = await rootBundle.loadString('assets/demo_profiles/profiles.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      final profiles = (data['profiles'] as List).map((p) {
        return UserProfile(
          uid: p['uid'] ?? '',
          email: '${p['uid']}@demo.dengim.app',
          name: p['name'] ?? '',
          age: p['age'] ?? 18,
          gender: p['gender'] ?? '',
          country: p['country'] ?? '',
          interests: List<String>.from(p['interests'] ?? []),
          bio: p['bio'],
          job: p['job'],
          education: p['education'],
          photoUrls: List<String>.from(p['photoUrls'] ?? []),
          isPremium: p['isPremium'] ?? false,
          isVerified: p['isVerified'] ?? false,
          isOnline: p['isOnline'] ?? false,
          latitude: (p['latitude'] as num?)?.toDouble(),
          longitude: (p['longitude'] as num?)?.toDouble(),
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
      }).toList();
      
      _cachedProfiles = profiles;
      LogService.i("Loaded ${profiles.length} demo profiles from local JSON");
      return profiles;
    } catch (e) {
      LogService.e("Error loading demo profiles", e);
      return [];
    }
  }
  
  /// Demo profil mi kontrol et
  static bool isDemoProfile(String uid) {
    return uid.startsWith('demo_');
  }
  
  /// Cache'i temizle (gerekirse)
  static void clearCache() {
    _cachedProfiles = null;
  }
}
