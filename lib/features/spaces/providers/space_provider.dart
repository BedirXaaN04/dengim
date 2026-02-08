import 'package:flutter/material.dart';
import '../models/space_model.dart';
import '../services/space_service.dart';
import '../../auth/models/user_profile.dart';

class SpaceProvider extends ChangeNotifier {
  final SpaceService _spaceService = SpaceService();
  
  List<SpaceRoom> _spaces = [];
  bool _isLoading = false;
  SpaceRoom? _currentSpace;

  List<SpaceRoom> get spaces => _spaces;
  bool get isLoading => _isLoading;
  SpaceRoom? get currentSpace => _currentSpace;

  SpaceProvider() {
    _init();
  }

  void _init() {
    _spaceService.getLiveSpaces().listen((updatedSpaces) {
      _spaces = updatedSpaces;
      notifyListeners();
    });
  }

  Future<String?> createSpace(String title, String? description, UserProfile hostProfile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final roomId = await _spaceService.createSpace(
        title: title,
        description: description,
        hostProfile: hostProfile,
      );
      _isLoading = false;
      notifyListeners();
      return roomId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> joinSpace(String spaceId, UserProfile userProfile) async {
    await _spaceService.joinSpace(spaceId, userProfile);
    // _currentSpace set logic later
  }

  Future<void> leaveSpace(String spaceId, String userId) async {
    await _spaceService.leaveSpace(spaceId, userId);
    if (_currentSpace?.id == spaceId) {
      _currentSpace = null;
    }
    notifyListeners();
  }

  Future<void> raiseHand(String spaceId, String userId) async {
    await _spaceService.raiseHand(spaceId, userId);
  }

  Future<void> lowerHand(String spaceId, String userId) async {
    await _spaceService.lowerHand(spaceId, userId);
  }

  // More methods as needed...
}
