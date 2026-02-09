import 'package:flutter/material.dart';
import '../../features/auth/models/user_profile.dart';
import '../../features/auth/services/discovery_service.dart';
import '../../features/auth/services/profile_service.dart';
import '../utils/log_service.dart';


class DiscoveryProvider extends ChangeNotifier {
  List<UserProfile> _users = [];
  List<UserProfile> _activeUsers = [];
  bool _isLoading = false;
  final DiscoveryService _discoveryService = DiscoveryService();
  final ProfileService _profileService = ProfileService();

  List<UserProfile> get users => _users;
  List<UserProfile> get activeUsers => _activeUsers;
  bool get isLoading => _isLoading;

  /// Minimum kullanıcı sayısı (bu sayının altındaysa demo profiller eklenir)


  Future<void> loadDiscoveryUsers({
    String? gender,
    int? minAge,
    int? maxAge,
    List<String>? interests,
    bool forceRefresh = false,
  }) async {
    // forceRefresh değilse ve zaten yükleniyorsa çık
    if (_isLoading && !forceRefresh) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Firebase'den gerçek kullanıcıları çek
      List<UserProfile> realUsers = await _discoveryService.getUsersToMatch(
        gender: gender,
        minAge: minAge,
        maxAge: maxAge,
        interests: interests,
      );

      // Block Filter
      final currentUserProfile = await _profileService.getUserProfile();
      final blockedUsers = currentUserProfile?.blockedUsers ?? [];
      
      if (blockedUsers.isNotEmpty) {
        realUsers.removeWhere((u) => blockedUsers.contains(u.uid));
      }
      
      // Interest Filter
      if (interests != null && interests.isNotEmpty) {
        realUsers = realUsers.where((u) => u.interests.any((i) => interests.contains(i))).toList();
      }
      
      _users = realUsers;
      
      // 3. Aktif kullanıcılar için de aynı mantık
      List<UserProfile> realActiveUsers = await _discoveryService.getActiveUsers();
      if (blockedUsers.isNotEmpty) {
        realActiveUsers.removeWhere((u) => blockedUsers.contains(u.uid));
      }
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

  Future<bool> swipeUser(String targetUserId, String swipeType) async {    
    try {
      return await _discoveryService.swipeUser(targetUserId, swipeType: swipeType);
    } catch (e) {
      LogService.e("Error swiping user", e);
      return false;
    }
  }
}


