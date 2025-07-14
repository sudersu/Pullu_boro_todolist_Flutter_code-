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
      print('AdMob not supported on this platform');
      return;
    }

    _bannerAd = AdsService.createBannerAd(
      size: AdsService.standardBannerSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✅ Banner ad loaded successfully');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner ad failed to load: ${error.message}');
          print('Error code: ${error.code}');
          print('Error domain: ${error.domain}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isAdLoaded = false;
            });
          }
          
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              _loadAd();
            }
          });
        },
        onAdOpened: (ad) {
          print('📱 Banner ad opened');
        },
        onAdClosed: (ad) {
          print('🔒 Banner ad closed');
        },
        onAdImpression: (ad) {
          print('👁️ Banner ad impression recorded');
        },
      ),
    );

    print('🔄 Loading banner ad with ID: ${AdsService.bannerAdUnitId}');
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the actual banner ad size for proper display
    final bannerHeight = _bannerAd?.size.height.toDouble() ?? 56.0;
    
    return Container(
      height: bannerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: _bannerAd != null && _isAdLoaded
          ? AdWidget(ad: _bannerAd!)
          : _bannerAd != null && !_isAdLoaded
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Loading ad...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ad Space',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
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