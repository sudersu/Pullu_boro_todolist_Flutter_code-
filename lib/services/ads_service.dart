import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdsService {
  // Real production ad unit IDs for dailylist.pro
  static const String _androidBannerAdUnitId = 'ca-app-pub-7863737202117990/3859479609';
  static const String _iosBannerAdUnitId = 'ca-app-pub-7863737202117990/3859479609';
  
  // Test ad units for development (fallback only)
  static const String _testAndroidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';

  static bool _initialized = false;

  // Initialize the Mobile Ads SDK
  static Future<void> initialize() async {
    if (_initialized) {
      print('⚠️ AdMob SDK already initialized');
      return;
    }

    print('🔄 Initializing AdMob SDK...');
    final initializationStatus = await MobileAds.instance.initialize();
    _initialized = true;
    
    print('✅ AdMob SDK initialized successfully');
    print('📱 App ID: ca-app-pub-7863737202117990~1157047227');
    print('🎯 Banner Unit ID: ${bannerAdUnitId}');
    print('📊 Adapter status: ${initializationStatus.adapterStatuses}');
  }

  // Get the appropriate banner ad unit ID for the platform
  static String get bannerAdUnitId {
    // Production ad units:
    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _iosBannerAdUnitId;
    }
    
    return _androidBannerAdUnitId; // Fallback
  }

  // Create a banner ad
  static BannerAd createBannerAd({
    required AdSize size,
    required BannerAdListener listener,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: listener,
    );
  }

  // Standard banner ad sizes
  static AdSize get standardBannerSize => AdSize.banner;
  static AdSize get largeBannerSize => AdSize.largeBanner;
  static AdSize get mediumRectangleSize => AdSize.mediumRectangle;

  // Check if ads are supported on this platform
  static bool get isSupported {
    return Platform.isAndroid || Platform.isIOS;
  }

  // Configure request configuration (optional)
  static void configureRequestConfiguration() {
    RequestConfiguration configuration = RequestConfiguration(
      // Add test device IDs for development
      testDeviceIds: [
        // Add your test device IDs here for testing
      ],
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
    );
    
    MobileAds.instance.updateRequestConfiguration(configuration);
  }

  // Switch between test and production ads
  static void useProductionAds(bool useProduction) {
    // This could be used to switch between test and production ads
    // Currently configured to always use test ads for safety
    print('Ad mode: ${useProduction ? 'Production' : 'Test'}');
  }
}