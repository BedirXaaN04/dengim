import 'package:flutter/material.dart';
import '../../features/auth/models/user_profile.dart';
import '../../features/auth/services/discovery_service.dart';
import '../utils/log_service.dart';
import '../utils/demo_profile_service.dart';

class DiscoveryProvider extends ChangeNotifier {
  List<UserProfile> _users = [];
  List<UserProfile> _activeUsers = [];
  bool _isLoading = false;
  final DiscoveryService _discoveryService = DiscoveryService();

  List<UserProfile> get users => _users;
  List<UserProfile> get activeUsers => _activeUsers;
  bool get isLoading => _isLoading;

  /// Minimum kullanıcı sayısı (bu sayının altındaysa demo profiller eklenir)
  static const int _minUsersThreshold = 3;

  Future<void> loadDiscoveryUsers({
    String? gender,
    int? minAge,
    int? maxAge,
  }) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Firebase'den gerçek kullanıcıları çek
      List<UserProfile> realUsers = await _discoveryService.getUsersToMatch(
        gender: gender,
        minAge: minAge,
        maxAge: maxAge,
      );
      
      _users = realUsers;
      
      List<UserProfile> realActiveUsers = await _discoveryService.getActiveUsers();
      _activeUsers = realActiveUsers;
      
      LogService.i("Discovery loaded: ${_users.length} users, ${_activeUsers.length} active");
    } catch (e) {
      LogService.e("Error loading discovery users", e);
      

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void removeUserAt(int index) {
    if (index >= 0 && index < _users.length) {
      _users.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> swipeUser(String targetUserId, bool isLike) async {

    
    try {
      return await _discoveryService.swipeUser(targetUserId, isLike);
    } catch (e) {
      LogService.e("Error swiping user", e);
      return false;
    }
  }
}


