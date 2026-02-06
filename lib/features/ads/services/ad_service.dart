import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/config_service.dart';
import '../../../core/utils/log_service.dart';

class AdService {
  // Singleton Pattern
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  // ⚠️ ÖNEMLİ: Canlıya geçerken bu ID'leri gerçek AdMob ID'leri ile değiştirin!
  // Android: ca-app-pub-xxx/yyy
  // iOS: ca-app-pub-xxx/zzz
  static const String _androidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';

  String get _rewardedAdUnitId {
    if (Platform.isAndroid) return _androidRewardedAdUnitId;
    if (Platform.isIOS) return _iosRewardedAdUnitId;
    return 'ca-app-pub-3940256099942544/5224354917'; // Fallback to android test id
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

  void showRewardedAd({required FunctionOnReward onReward}) {
    if (!ConfigService().isAdsEnabled) {
      LogService.w("Ads are globally disabled via admin panel.");
      return;
    }

    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded before loaded.');
      _createRewardedAd(); // Yeniden yükle
      return;
    }
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) => debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd(); // Bir sonraki için yenisini yükle
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
      onReward(reward.amount.toInt());
    });
    _rewardedAd = null;
  }
}

typedef FunctionOnReward = void Function(int amount);
