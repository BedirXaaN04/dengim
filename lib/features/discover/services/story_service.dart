import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/story_model.dart';
import '../../../core/utils/log_service.dart';
import '../../../core/services/config_service.dart';
import '../../../core/services/cloudinary_service.dart';


class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  Future<void> uploadStory(
    XFile file, 
    String userName, 
    String userAvatar, {
    bool isPremium = false,
    bool isVerified = false,
  }) async {
    final user = _currentUser;
    if (user == null) return;

    try {
      // 1. Upload Image to Cloudinary (Web compatible)
      final imageUrl = await CloudinaryService.uploadImage(file);
      
      if (imageUrl == null) {
        throw Exception('Görsel yüklenemedi');
      }

      // 2. Create Story Record in Firestore
      await _firestore.collection('stories').add({
        'userId': user.uid,
        'userName': userName,
        'userAvatar': userAvatar.isNotEmpty 
            ? userAvatar 
            : 'https://ui-avatars.com/api/?name=${userName.substring(0, 1)}&background=D4AF37&color=fff&size=200',
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'viewers': [],
        'isPremium': isPremium,
        'isVerified': isVerified,
      });

      LogService.i("Story uploaded successfully to Cloudinary.");
    } catch (e) {
      LogService.e("Story upload failed", e);
      rethrow;
    }
  }

  Stream<List<UserStories>> getActiveStories(List<String> matchIds) {
    final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));
    final currentUserId = _currentUser?.uid;
    
    return _firestore
        .collection('stories')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(twentyFourHoursAgo))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final Map<String, List<Story>> groupedStories = {};
          
          for (var doc in snapshot.docs) {
            final story = Story.fromMap(doc.data(), doc.id);
            
            // Visibility Filter:
            // Controlled by Admin Panel (ConfigService)
            final bool isVisible = !ConfigService().isVipEnabled || 
                                   story.userId == currentUserId || 
                                   matchIds.contains(story.userId) || 
                                   story.isPremium || 
                                   story.isVerified;

            if (isVisible) {
              if (!groupedStories.containsKey(story.userId)) {
                groupedStories[story.userId] = [];
              }
              groupedStories[story.userId]!.add(story);
            }
          }

          return groupedStories.entries.map((entry) {
            final firstStory = entry.value.first;
            return UserStories(
              userId: entry.key,
              userName: firstStory.userName,
              userAvatar: firstStory.userAvatar,
              stories: entry.value,
            );
          }).toList();
        });
  }


  Future<void> viewStory(String storyId) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('stories').doc(storyId).update({
        'viewers': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      LogService.e("Error marking story as viewed", e);
    }
  }
}
