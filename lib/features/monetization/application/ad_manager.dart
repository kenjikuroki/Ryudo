import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static bool _initialized = false;

  // ============================================================
  // 🔧 本番切り替えフラグ
  //   テスト中  → true
  //   本番リリース → false に変更してください
  // ============================================================
  static const bool _useTestAds = true;

  static Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  // Ad Unit IDs
  static String get bannerAdUnitId {
    if (_useTestAds || kDebugMode) {
      // テスト用ID（Google公式）
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Test Banner
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Test Banner
    }
    // 本番ID
    if (Platform.isAndroid) {
      return 'ca-app-pub-3331079517737737/5727372618'; // Android Banner
    }
    return 'ca-app-pub-3331079517737737/7016815279'; // iOS Banner
  }

  static String get interstitialAdUnitId {
    if (_useTestAds || kDebugMode) {
      // テスト用ID（Google公式）
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android Test Interstitial
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test Interstitial
    }
    // 本番ID
    if (Platform.isAndroid) {
      return 'ca-app-pub-3331079517737737/1776189747'; // Android Interstitial
    }
    return 'ca-app-pub-3331079517737737/8377998409'; // iOS Interstitial
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
