import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Admin panelinden yönetilen sistem ayarlarını dinleyen provider
/// Firestore'daki system/config dokümanını gerçek zamanlı olarak dinler
class SystemConfigProvider extends ChangeNotifier {
  // Sistem Ayarları
  bool _isVipEnabled = false;
  bool _isAdsEnabled = true;
  bool _isCreditsEnabled = false;
  int _minimumAge = 18;
  int _maxDistance = 100;
  int _dailyLikeLimit = 25;
  bool _isMaintenanceMode = false;
  String _maintenanceMessage = '';
  
  // Algoritma Parametreleri
  int _locationWeight = 35;
  int _interestsWeight = 40;
  int _activityWeight = 25;
  
  StreamSubscription<DocumentSnapshot>? _configSubscription;
  bool _isLoading = true;
  String? _error;

  // Getters
  bool get isVipEnabled => _isVipEnabled;
  bool get isAdsEnabled => _isAdsEnabled;
  bool get isCreditsEnabled => _isCreditsEnabled;
  int get minimumAge => _minimumAge;
  int get maxDistance => _maxDistance;
  int get dailyLikeLimit => _dailyLikeLimit;
  bool get isMaintenanceMode => _isMaintenanceMode;
  String get maintenanceMessage => _maintenanceMessage;
  int get locationWeight => _locationWeight;
  int get interestsWeight => _interestsWeight;
  int get activityWeight => _activityWeight;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SystemConfigProvider() {
    _initConfigListener();
  }

  /// Firestore'daki system/config dokümanını dinlemeye başla
  void _initConfigListener() {
    _configSubscription = FirebaseFirestore.instance
        .collection('system')
        .doc('config')
        .snapshots()
        .listen(
          _onConfigUpdate,
          onError: _onConfigError,
        );
  }

  /// Config güncellendiğinde çağrılır
  void _onConfigUpdate(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      // Config dokümanı yoksa varsayılan değerlerle devam et
      _isLoading = false;
      notifyListeners();
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Ayarları güncelle
    _isVipEnabled = data['isVipEnabled'] ?? false;
    _isAdsEnabled = data['isAdsEnabled'] ?? true;
    _isCreditsEnabled = data['isCreditsEnabled'] ?? false;
    _minimumAge = data['minimumAge'] ?? 18;
    _maxDistance = data['maxDistance'] ?? 100;
    _dailyLikeLimit = data['dailyLikeLimit'] ?? 25;
    _isMaintenanceMode = data['isMaintenanceMode'] ?? false;
    _maintenanceMessage = data['maintenanceMessage'] ?? '';
    
    // Algoritma parametreleri
    _locationWeight = data['locationWeight'] ?? 35;
    _interestsWeight = data['interestsWeight'] ?? 40;
    _activityWeight = data['activityWeight'] ?? 25;

    _isLoading = false;
    _error = null;
    
    if (kDebugMode) {
      print('🔧 System config updated: VIP=$_isVipEnabled, Ads=$_isAdsEnabled, Credits=$_isCreditsEnabled');
    }
    
    notifyListeners();
  }

  /// Hata durumunda çağrılır
  void _onConfigError(dynamic error) {
    _error = error.toString();
    _isLoading = false;
    if (kDebugMode) {
      print('❌ System config error: $error');
    }
    notifyListeners();
  }

  /// Premium özellik kontrolü
  /// VIP sistemi aktifse ve kullanıcı premium değilse false döner
  bool canAccessPremiumFeature(bool isPremiumUser) {
    if (!_isVipEnabled) return true; // VIP kapalıysa herkes erişebilir
    return isPremiumUser;
  }

  /// Reklam gösterilmeli mi?
  bool shouldShowAds(bool isPremiumUser) {
    if (!_isAdsEnabled) return false; // Reklamlar kapalıysa gösterme
    if (isPremiumUser) return false; // Premium kullanıcılara gösterme
    return true;
  }

  /// Yaş kontrolü
  bool isAgeValid(int age) {
    return age >= _minimumAge;
  }

  /// Günlük beğeni limitine ulaşıldı mı?
  bool hasReachedDailyLimit(int todayLikes, bool isPremiumUser) {
    if (isPremiumUser) return false; // Premium sınırsız
    return todayLikes >= _dailyLikeLimit;
  }

  /// Kalan beğeni hakkı
  int getRemainingLikes(int todayLikes, bool isPremiumUser) {
    if (isPremiumUser) return 999; // Sınırsız göster
    final remaining = _dailyLikeLimit - todayLikes;
    return remaining < 0 ? 0 : remaining;
  }

  /// Config'i manuel yenile (pull-to-refresh gibi durumlar için)
  Future<void> refreshConfig() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('system')
          .doc('config')
          .get();
      _onConfigUpdate(snapshot);
    } catch (e) {
      _onConfigError(e);
    }
  }

  @override
  void dispose() {
    _configSubscription?.cancel();
    super.dispose();
  }
}
