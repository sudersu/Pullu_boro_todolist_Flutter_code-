import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ads_service.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({Key? key}) : super(key: key);

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (!AdsService.isSupported) {
      return;
    }

    _bannerAd = AdsService.createBannerAd(
      size: AdsService.standardBannerSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          print('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
          setState(() {
            _bannerAd = null;
            _isAdLoaded = false;
          });
        },
        onAdOpened: (ad) {
          print('Banner ad opened');
        },
        onAdClosed: (ad) {
          print('Banner ad closed');
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If ads are not supported or failed to load, show a placeholder
    if (!AdsService.isSupported || _bannerAd == null) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ad Banner',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'This is a placeholder for ad content.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show the loaded ad
    return Container(
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: _isAdLoaded
          ? AdWidget(ad: _bannerAd!)
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

// Widget to provide safe bottom padding for the ad banner
class AdBannerSafeArea extends StatelessWidget {
  final Widget child;

  const AdBannerSafeArea({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 56), // Height of ad banner
      child: child,
    );
  }
}