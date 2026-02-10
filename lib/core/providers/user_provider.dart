import 'dart:async';
import 'package:flutter/material.dart';
import '../../features/auth/models/user_profile.dart';
import '../../features/auth/services/profile_service.dart';
import '../utils/log_service.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isLoading = false;
  StreamSubscription<UserProfile?>? _profileSubscription;

  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  final ProfileService _profileService = ProfileService();

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Önce tek seferlik çek
      _currentUser = await _profileService.getUserProfile();
      
      // Sonra stream'i başlat
      _profileSubscription?.cancel();
      _profileSubscription = _profileService.getProfileStream().listen((profile) {
        if (profile != null) {
          _currentUser = profile;
          notifyListeners();
        }
      });

      LogService.i("User profile monitoring started: ${_currentUser?.name}");
    } catch (e) {
      LogService.e("Error loading user profile", e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  void updateProfile(UserProfile profile) {
    _currentUser = profile;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
