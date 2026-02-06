// Stub file for web - AdService
// google_mobile_ads is not supported on web

import 'package:flutter/foundation.dart';
import '../../../core/services/config_service.dart';
import '../../../core/utils/log_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  Future<void> init() async {
    if (kIsWeb) {
      LogService.i("AdService: Web platform - ads disabled.");
      return;
    }
  }

  void showRewardedAd({required FunctionOnReward onReward}) {
    if (kIsWeb) {
      LogService.w("Ads are not supported on web.");
      return;
    }
    if (!ConfigService().isAdsEnabled) {
      LogService.w("Ads are globally disabled via admin panel.");
      return;
    }
  }
}

typedef FunctionOnReward = void Function(int amount);
