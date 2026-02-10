import 'package:flutter/foundation.dart';
import '../../../core/utils/log_service.dart';
import 'ad_service_mobile.dart' if (dart.library.html) 'ad_service_web.dart' as ads;

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final ads.AdService _platformService = ads.AdService();

  Future<void> init() async {
    await _platformService.init();
  }

  void showRewardedAd({required String tier, required Function(int) onReward}) {
    if (kIsWeb) return;
    _platformService.showRewardedAd(tier: tier, onReward: onReward);
  }

  void showInterstitialAd({required String tier}) {
    if (kIsWeb) return;
    _platformService.showInterstitialAd(tier: tier);
  }

  // Get current platform banner unit id
  String get bannerAdUnitId {
    if (kIsWeb) return "";
    return _platformService.bannerAdUnitId;
  }
}
