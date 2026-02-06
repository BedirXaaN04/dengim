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
      
      // 2. Yeterli kullanıcı yoksa demo profilleri ekle
      if (realUsers.length < _minUsersThreshold) {
        LogService.i("Few real users (${realUsers.length}), loading demo profiles...");
        
        List<UserProfile> demoUsers = await DemoProfileService.getDemoProfiles();
        
        // Gender ve yaş filtresi uygula
        if (gender != null && gender != 'other') {
          final targetGender = gender == 'male' ? 'Erkek' : 'Kadın';
          demoUsers = demoUsers.where((u) => u.gender == targetGender).toList();
        }
        if (minAge != null) {
          demoUsers = demoUsers.where((u) => u.age >= minAge).toList();
        }
        if (maxAge != null) {
          demoUsers = demoUsers.where((u) => u.age <= maxAge).toList();
        }
        
        // Gerçek kullanıcıları önce, sonra demo profilleri göster
        _users = [...realUsers, ...demoUsers];
        LogService.i("Combined: ${realUsers.length} real + ${demoUsers.length} demo = ${_users.length} total");
      } else {
        _users = realUsers;
      }
      
      // 3. Aktif kullanıcılar için de aynı mantık
      List<UserProfile> realActiveUsers = await _discoveryService.getActiveUsers();
      if (realActiveUsers.isEmpty) {
        final demoUsers = await DemoProfileService.getDemoProfiles();
        _activeUsers = demoUsers.where((u) => u.isOnline).toList();
      } else {
        _activeUsers = realActiveUsers;
      }
      
      LogService.i("Discovery loaded: ${_users.length} users, ${_activeUsers.length} active");
    } catch (e) {
      LogService.e("Error loading discovery users", e);
      
      // Hata durumunda bile demo profilleri göster
      try {
        _users = await DemoProfileService.getDemoProfiles();
        _activeUsers = _users.where((u) => u.isOnline).toList();
        LogService.i("Fallback to demo profiles: ${_users.length} loaded");
      } catch (_) {}
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
    // Demo profillere swipe yapıldığında
    if (DemoProfileService.isDemoProfile(targetUserId)) {
      LogService.i("Demo profile swiped: $targetUserId (${isLike ? 'LIKE' : 'NOPE'})");
      // Demo profiller için simüle edilmiş match şansı (%30)
      if (isLike && DateTime.now().millisecond % 3 == 0) {
        return true; // Match!
      }
      return false;
    }
    
    try {
      return await _discoveryService.swipeUser(targetUserId, isLike);
    } catch (e) {
      LogService.e("Error swiping user", e);
      return false;
    }
  }
}


