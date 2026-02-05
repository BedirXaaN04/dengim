import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String imageUrl;
  final DateTime createdAt;
  final List<String> viewers;
  final bool isPremium;
  final bool isVerified;

  Story({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.imageUrl,
    required this.createdAt,
    this.viewers = const [],
    this.isPremium = false,
    this.isVerified = false,
  });

  bool get isExpired => DateTime.now().difference(createdAt).inHours >= 24;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'viewers': viewers,
      'isPremium': isPremium,
      'isVerified': isVerified,
    };
  }

  factory Story.fromMap(Map<String, dynamic> map, String id) {
    return Story(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      viewers: List<String>.from(map['viewers'] ?? []),
      isPremium: map['isPremium'] ?? false,
      isVerified: map['isVerified'] ?? false,
    );
  }

}

class UserStories {
  final String userId;
  final String userName;
  final String userAvatar;
  final List<Story> stories;

  UserStories({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.stories,
  });

  bool get allViewedByMe {
    // This logic relies on passing the current user ID or checking inside the viewer list
    return false; 
  }
}
