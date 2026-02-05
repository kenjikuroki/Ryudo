import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../application/ad_manager.dart';
import '../application/billing_provider.dart';
import 'premium_upgrade_dialog.dart';
import 'package:archery/l10n/gen/app_localizations.dart';

class AdBannerWidget extends ConsumerStatefulWidget {
  const AdBannerWidget({super.key});

  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  late bool _showPremiumButton;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    // 10% chance to show premium button instead of ad
    _showPremiumButton = Random().nextDouble() < 0.10;
    
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_showPremiumButton) {
      _loadAd();
    }
  }

  void _loadAd() {
    final isPremium = ref.read(billingNotifierProvider).value ?? false;
    if (isPremium) return;

    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          debugPrint('BannerAd failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(billingNotifierProvider, (previous, next) {
      if (next.value == true && _bannerAd != null) {
        _bannerAd?.dispose();
        _bannerAd = null;
        setState(() {
          _isLoaded = false;
        });
      }
    });

    final billingState = ref.watch(billingNotifierProvider);
    final isPremium = billingState.value ?? false;

    if (isPremium) {
      return const SizedBox.shrink();
    }

    const adHeight = 50.0; // Standard banner height
    const containerHeight = adHeight + 16.0; // Including SafeArea and padding

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        height: containerHeight,
        alignment: Alignment.center,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_showPremiumButton) {
      return _buildPremiumPromo();
    }

    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Shimmering placeholder
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: 320, // Standard banner width
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: 1.0,
            alignment: Alignment(-1.0 + (2.0 * _shimmerController.value), 0.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.3, 0.5, 0.7],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumPromo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const PremiumUpgradeDialog(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.removeAdsAndSupport,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
