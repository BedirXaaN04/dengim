import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/services/feature_flag_service.dart';
import '../../../core/utils/log_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  int _numRewardedLoadAttempts = 0;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  // Test Ad Unit IDs
  static const String _androidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerId = 'ca-app-pub-3940256099942544/2934735716';
  
  static const String _androidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _iosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  static const String _androidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosRewardedId = 'ca-app-pub-3940256099942544/1712485313';

  String get bannerAdUnitId => Platform.isAndroid ? _androidBannerId : _iosBannerId;
  String get _interstitialAdUnitId => Platform.isAndroid ? _androidInterstitialId : _iosInterstitialId;
  String get _rewardedAdUnitId => Platform.isAndroid ? _androidRewardedId : _iosRewardedId;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadRewardedAd();
    _loadInterstitialAd();
  }

  // --- REWARDED ADS ---

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _numRewardedLoadAttempts++;
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) _loadRewardedAd();
        },
      ),
    );
  }

  void showRewardedAd({required String tier, required Function(int) onReward}) {
    if (!FeatureFlagService().shouldShowAds(tier)) return;

    if (_rewardedAd == null) {
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) => onReward(reward.amount.toInt()));
    _rewardedAd = null;
  }

  // --- INTERSTITIAL ADS ---

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      interstitialLoadCallback: InterstitialLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _numInterstitialLoadAttempts++;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) _loadInterstitialAd();
        },
      ),
    );
  }

  void showInterstitialAd({required String tier}) {
    if (!FeatureFlagService().shouldShowAds(tier)) return;

    if (_interstitialAd == null) {
      _loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
