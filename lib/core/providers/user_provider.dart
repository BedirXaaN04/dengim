import 'package:flutter/material.dart';
import '../../features/auth/models/user_profile.dart';
import '../../features/auth/services/profile_service.dart';
import '../utils/log_service.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isLoading = false;

  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  final ProfileService _profileService = ProfileService();

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _profileService.getUserProfile();
      LogService.i("User profile loaded: ${_currentUser?.name}");
    } catch (e) {
      LogService.e("Error loading user profile", e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
