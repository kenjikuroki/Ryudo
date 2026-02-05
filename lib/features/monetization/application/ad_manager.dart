import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  // Ad Unit IDs
  static String get bannerAdUnitId {
    if (kDebugMode && Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android Test Banner
    } else if (kDebugMode && Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS Test Banner
    }
    // Production IDs
    return 'ca-app-pub-3331079517737737/7016815279'; 
  }

  static String get interstitialAdUnitId {
    if (kDebugMode && Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android Test Interstitial
    } else if (kDebugMode && Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS Test Interstitial
    }
    // Production IDs
    return 'ca-app-pub-3331079517737737/8377998409';
  }

  static Future<void> loadInterstitialAd({
    required Function(InterstitialAd ad) onAdLoaded,
  }) async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }
}
