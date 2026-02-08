import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  user,
  moderator,
  admin,
}

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final DateTime? birthDate; // ← YENİ: Doğum tarihi
  final String gender;
  final String country;
  final List<String> interests;
  final String? bio;
  final String? job;
  final String? education;
  final String? relationshipGoal; // New field
  final List<String>? photoUrls;
  
  // Özellikler
  final bool isPremium;
  final int credits;
  final bool isVerified;
  final bool isOnline;
  final UserRole role; // YENİ: Rol (user, moderator, admin)
  
  // Konum
  final double distance;
  final double? latitude;
  final double? longitude;
  final List<String> blockedUsers;
  final String? fcmToken;

  // Zamanlar
  final DateTime createdAt;
  final DateTime lastActive;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    this.birthDate,
    required this.gender,
    required this.country,
    required this.interests,
    this.bio,
    this.job,
    this.education,
    this.relationshipGoal,
    this.photoUrls,
    this.isPremium = false,
    this.credits = 0,
    this.isVerified = false,
    this.isOnline = false,
    this.role = UserRole.user,
    this.distance = 0,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.lastActive,
    required this.blockedUsers,
    this.fcmToken,
  });

  // Calculated age from birthDate
  int get age {
    if (birthDate == null) return 25; // Default fallback
    final now = DateTime.now();
    int calculatedAge = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  // UI Yardımcıları
  String get imageUrl => (photoUrls != null && photoUrls!.isNotEmpty) 
      ? photoUrls!.first 
      : 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=500&auto=format&fit=crop&q=60'; // Placeholder
  
  String get location => country;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'gender': gender,
      'country': country,
      'interests': interests,
      'bio': bio,
      'job': job,
      'education': education,
      'relationshipGoal': relationshipGoal,
      'photoUrls': photoUrls,
      'isPremium': isPremium,
      'credits': credits,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'role': role.name,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'blockedUsers': blockedUsers,
      'fcmToken': fcmToken,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // If birthDate is missing but age is present (legacy or mismatch), 
    // we can guestimate a birth year, but it's better to just use null and fallback.
    DateTime? bDay;
    if (map['birthDate'] != null) {
      if (map['birthDate'] is Timestamp) {
        bDay = (map['birthDate'] as Timestamp).toDate();
      } else if (map['birthDate'] is String) {
        bDay = DateTime.tryParse(map['birthDate']);
      }
    }

    // Handle name default
    String nameVal = map['name'] ?? '';
    if (nameVal.isEmpty && map['email'] != null) {
      nameVal = map['email'].split('@')[0];
    }

    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: nameVal.isEmpty ? 'Kullanıcı' : nameVal,
      birthDate: bDay,
      gender: map['gender'] ?? 'Belirtilmedi',
      country: map['country'] ?? 'Dünya',
      interests: List<String>.from(map['interests'] ?? []),
      bio: map['bio'],
      job: map['job'],
      education: map['education'],
      relationshipGoal: map['relationshipGoal'],
      photoUrls: map['photoUrls'] != null ? List<String>.from(map['photoUrls']) : null,
      isPremium: map['isPremium'] ?? false,
      credits: map['credits']?.toInt() ?? 0,
      isVerified: map['isVerified'] ?? false,
      isOnline: map['isOnline'] ?? false,
      role: UserRole.values.firstWhere((e) => e.name == (map['role'] ?? 'user'), orElse: () => UserRole.user),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      distance: 0.0,
      createdAt: (map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now()),
      lastActive: (map['lastActive'] is Timestamp 
          ? (map['lastActive'] as Timestamp).toDate() 
          : DateTime.now()),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      fcmToken: map['fcmToken'],
    );
  }
}
