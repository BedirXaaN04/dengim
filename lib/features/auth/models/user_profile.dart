import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final int age;
  final String gender;
  final String country;
  final List<String> interests;
  final String? bio;
  final String? job;
  final String? education;
  final List<String>? photoUrls;
  
  // Özellikler
  final bool isPremium;
  final int credits;
  final bool isVerified;
  final bool isOnline;
  
  // Konum
  final double distance;
  final double? latitude;
  final double? longitude;

  // Zamanlar
  final DateTime createdAt;
  final DateTime lastActive;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
    required this.gender,
    required this.country,
    required this.interests,
    this.bio,
    this.job,
    this.education,
    this.photoUrls,
    this.isPremium = false,
    this.credits = 0,
    this.isVerified = false,
    this.isOnline = false,
    this.distance = 0,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.lastActive,
  });

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
      'age': age,
      'gender': gender,
      'country': country,
      'interests': interests,
      'bio': bio,
      'job': job,
      'education': education,
      'photoUrls': photoUrls,
      'isPremium': isPremium,
      'credits': credits,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 18,
      gender: map['gender'] ?? '',
      country: map['country'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      bio: map['bio'],
      job: map['job'],
      education: map['education'],
      photoUrls: map['photoUrls'] != null ? List<String>.from(map['photoUrls']) : null,
      isPremium: map['isPremium'] ?? false,
      credits: map['credits']?.toInt() ?? 0,
      isVerified: map['isVerified'] ?? false,
      isOnline: map['isOnline'] ?? false,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      distance: 0.0, // Calculate later based on lat/long
      createdAt: (map['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      lastActive: (map['lastActive'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }
}
