import 'package:flutter/material.dart';
import '../../features/auth/models/user_profile.dart';
import '../../features/auth/services/discovery_service.dart';
import '../utils/log_service.dart';

class LikesProvider extends ChangeNotifier {
  List<UserProfile> _matches = [];
  List<UserProfile> _likedMeUsers = [];
  bool _isLoading = false;
  final DiscoveryService _discoveryService = DiscoveryService();

  List<UserProfile> get matches => _matches;
  List<UserProfile> get likedMeUsers => _likedMeUsers;
  bool get isLoading => _isLoading;

  Future<void> loadMatches() async {
    _isLoading = true;
    notifyListeners();

    try {
      _matches = await _discoveryService.getMatchedUsers();
      LogService.i("Loaded ${_matches.length} matches.");
    } catch (e) {
      LogService.e("Error loading matches", e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLikedMeUsers() async {
    // This would ideally be a premium feature or restricted
    try {
      _likedMeUsers = await _discoveryService.getLikedMeUsers();
      LogService.i("Loaded ${_likedMeUsers.length} users who liked me.");
    } catch (e) {
      LogService.e("Error loading liked me users", e);
    }
    notifyListeners();
  }
}
