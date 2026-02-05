import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'billing_provider.g.dart';

@Riverpod(keepAlive: true)
class BillingNotifier extends _$BillingNotifier {
  static const _premiumKey = 'is_premium';
  static const _premiumProductId = 'unlock_kyudo';

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  FutureOr<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumKey) ?? false;

    // Start IAP stream subscription
    final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint('Purchase Error: $error');
    });

    return isPremium;
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending state if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase Error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          // Purchase successful or restored
          if (purchaseDetails.productID == _premiumProductId) {
            await setPremium(true);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> setPremium(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
    state = AsyncData(isPremium);
  }

  Future<bool> purchasePremium() async {
    try {
      // Check if store is available first
      final bool available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        debugPrint('Store not available');
        return false;
      }

      const Set<String> kIds = <String>{_premiumProductId};
      final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails(kIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Product not found in store: ${response.notFoundIDs}');
        return false;
      }

      if (response.productDetails.isEmpty) {
        debugPrint('No products found.');
        return false;
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: response.productDetails.first);
      return await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Purchase Exception: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
    // Some stores don't trigger anything if no previous purchases exist.
    // In Debug mode, we can use this as a way to "Reset" for testing if desired.
  }

  Future<void> resetPremiumForTesting() async {
    if (kDebugMode) {
      await setPremium(false);
    }
  }
}
