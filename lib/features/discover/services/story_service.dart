import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/story_model.dart';
import '../../../core/utils/log_service.dart';


class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
      // 1. Upload Image to Storage
      final ref = _storage.ref().child('stories/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final data = await file.readAsBytes();
      
      final uploadTask = ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));
      await uploadTask;
      final imageUrl = await ref.getDownloadURL();

      // 2. Create Story Record in Firestore
      await _firestore.collection('stories').add({
        'userId': user.uid,
        'userName': userName,
        'userAvatar': userAvatar,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'viewers': [],
        'isPremium': isPremium,
        'isVerified': isVerified,
      });

      LogService.i("Story uploaded successfully.");
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
            // 1. My own stories
            // 2. Stories from matches (mutual followers)
            // 3. Showcase stories (Premium or Verified)
            final bool isVisible = story.userId == currentUserId || 
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
