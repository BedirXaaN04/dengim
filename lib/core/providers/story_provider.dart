import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/discover/models/story_model.dart';
import '../../features/discover/services/story_service.dart';
import '../utils/log_service.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();
  List<UserStories> _activeStories = [];
  bool _isUploading = false;

  List<UserStories> get activeStories => _activeStories;
  bool get isUploading => _isUploading;

  StoryProvider() {
    _initStories();
  }

  void _initStories() {
    _storyService.getActiveStories().listen((stories) {
      _activeStories = stories;
      notifyListeners();
    }, onError: (e) {
      LogService.e("Stories stream error", e);
    });
  }

  Future<void> uploadStory(XFile file, String userName, String userAvatar) async {
    _isUploading = true;
    notifyListeners();

    try {
      await _storyService.uploadStory(file, userName, userAvatar);
    } catch (e) {
      LogService.e("Provider story upload error", e);
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> viewStory(String storyId) async {
    await _storyService.viewStory(storyId);
  }
}
