import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../utils/log_service.dart';

class FeatureFlagService {
  static final FeatureFlagService _instance = FeatureFlagService._internal();
  factory FeatureFlagService() => _instance;
  FeatureFlagService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    try {
      await _remoteConfig.setDefaults({
        "free_daily_swipe_limit": 25,
        "gold_daily_swipe_limit": 999999,
        "platinum_daily_swipe_limit": 999999,
        
        "free_super_likes_per_day": 0,
        "gold_super_likes_per_day": 5,
        "platinum_super_likes_per_day": 10,
        
        "free_voice_message_enabled": false,
        "gold_voice_message_enabled": true,
        "platinum_voice_message_enabled": true,
        
        "free_video_call_enabled": false,
        "gold_video_call_enabled": false,
        "platinum_video_call_enabled": true,
        
        "free_read_receipts_enabled": false,
        "gold_read_receipts_enabled": true,
        "platinum_read_receipts_enabled": true,
        
        "show_ads": true,
        "stories_enabled": false,
      });

      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await _remoteConfig.fetchAndActivate();
      LogService.i("Remote Config initialized and activated");
    } catch (e) {
      LogService.e("Error initializing Remote Config", e);
    }
  }

  // Getters for specific features based on user tier
  int getDailySwipeLimit(String tier) {
    return _remoteConfig.getInt("${tier}_daily_swipe_limit");
  }

  int getSuperLikesLimit(String tier) {
    return _remoteConfig.getInt("${tier}_super_likes_per_day");
  }

  bool isVoiceMessageEnabled(String tier) {
    return _remoteConfig.getBool("${tier}_voice_message_enabled");
  }

  bool isVideoCallEnabled(String tier) {
    return _remoteConfig.getBool("${tier}_video_call_enabled");
  }

  bool isReadReceiptsEnabled(String tier) {
    return _remoteConfig.getBool("${tier}_read_receipts_enabled");
  }

  bool shouldShowAds(String tier) {
    if (tier == 'platinum' || tier == 'gold') return false;
    return _remoteConfig.getBool("show_ads");
  }

  bool isStoryEnabled() {
    return _remoteConfig.getBool("stories_enabled");
  }
}
