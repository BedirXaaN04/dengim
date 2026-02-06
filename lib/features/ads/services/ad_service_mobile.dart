// Mobile implementation for AdService
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/services/config_service.dart';
import '../../../core/utils/log_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  static const String _androidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';

  String get _rewardedAdUnitId {
    if (Platform.isAndroid) return _androidRewardedAdUnitId;
    if (Platform.isIOS) return _iosRewardedAdUnitId;
    return _androidRewardedAdUnitId;
  }

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _createRewardedAd();
  }

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
            _createRewardedAd();
          }
        },
      ),
    );
  }

  void showRewardedAd({required Function(int) onReward}) {
    if (!ConfigService().isAdsEnabled) {
      LogService.w("Ads are globally disabled via admin panel.");
      return;
    }

    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded before loaded.');
      _createRewardedAd();
      return;
    }
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) => debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint('$ad with reward ${reward.amount}, ${reward.type}');
      onReward(reward.amount.toInt());
    });
    _rewardedAd = null;
  }
}
