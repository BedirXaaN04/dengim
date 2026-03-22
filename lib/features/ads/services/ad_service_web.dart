// Stub file for web - AdService
// google_mobile_ads is not supported on web

import '../../../core/utils/log_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  Future<void> init() async {
    LogService.i("AdService: Web platform - ads disabled.");
  }

  void showRewardedAd({required String tier, required FunctionOnReward onReward}) {
    LogService.w("Ads are not supported on web.");
  }

  void showInterstitialAd({required String tier}) {
    LogService.w("Ads are not supported on web.");
  }

  String get bannerAdUnitId => "";
}

typedef FunctionOnReward = void Function(int amount);
