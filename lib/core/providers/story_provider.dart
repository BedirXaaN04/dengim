import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/discover/models/story_model.dart';
import '../../features/discover/services/story_service.dart';
import '../utils/log_service.dart';
import '../../features/auth/services/discovery_service.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();
  final DiscoveryService _discoveryService = DiscoveryService();
  
  List<UserStories> _activeStories = [];
  List<String> _matchIds = [];
  bool _isUploading = false;
  StreamSubscription? _storySubscription;
  StreamSubscription? _matchSubscription;

  List<UserStories> get activeStories => _activeStories;
  List<String> get matchIds => _matchIds;
  bool get isUploading => _isUploading;

  StoryProvider() {
    _initStories();
  }

  void _initStories() {
    // 1. Listen to Matches
    _matchSubscription = _discoveryService.getMatchedUserIdsStream().listen((ids) {
      _matchIds = ids;
      
      // 2. Restart Stories Stream whenever matches change
      _storySubscription?.cancel();
      _storySubscription = _storyService.getActiveStories(_matchIds).listen((stories) {
        _activeStories = stories;
        notifyListeners();
      }, onError: (e) {
        LogService.e("Stories stream error", e);
      });
    });
  }

  Future<void> uploadStoryBytes(
    Uint8List bytes, 
    String userName, 
    String userAvatar, {
    bool isPremium = false, 
    bool isVerified = false
  }) async {
    _isUploading = true;
    notifyListeners();

    try {
      await _storyService.uploadStoryBytes(
        bytes, 
        userName, 
        userAvatar,
        isPremium: isPremium,
        isVerified: isVerified,
      );
    } catch (e) {
      LogService.e("Provider story byte upload error", e);
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> uploadStory(
    XFile file, 
    String userName, 
    String userAvatar, {
    bool isPremium = false, 
    bool isVerified = false
  }) async {
    _isUploading = true;
    notifyListeners();

    try {
      await _storyService.uploadStory(
        file, 
        userName, 
        userAvatar,
        isPremium: isPremium,
        isVerified: isVerified,
      );
    } catch (e) {
      LogService.e("Provider story upload error", e);
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _storySubscription?.cancel();
    _matchSubscription?.cancel();
    super.dispose();
  }


  Future<void> viewStory(String storyId) async {
    await _storyService.viewStory(storyId);
  }
}
