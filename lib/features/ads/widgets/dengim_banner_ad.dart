import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';
import '../../../core/providers/subscription_provider.dart';
import '../../../core/services/feature_flag_service.dart';
import 'package:flutter/foundation.dart';

class DengimBannerAd extends StatefulWidget {
  const DengimBannerAd({super.key});

  @override
  State<DengimBannerAd> createState() => _DengimBannerAdState();
}

class _DengimBannerAdState extends State<DengimBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  void _loadAd() {
    if (kIsWeb) return;

    final tier = context.read<SubscriptionProvider>().currentTier;
    if (!FeatureFlagService().shouldShowAds(tier)) return;

    _bannerAd = BannerAd(
      adUnitId: AdService().bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('BannerAd failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
