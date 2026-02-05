import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/billing_provider.dart';
import 'package:archery/l10n/gen/app_localizations.dart';

class PremiumUpgradeDialog extends ConsumerStatefulWidget {
  const PremiumUpgradeDialog({super.key});

  @override
  ConsumerState<PremiumUpgradeDialog> createState() => _PremiumUpgradeDialogState();
}

class _PremiumUpgradeDialogState extends ConsumerState<PremiumUpgradeDialog> {
  bool _isProcessing = false;

  Future<void> _handlePurchase() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await ref.read(billingNotifierProvider.notifier).purchasePremium();
      
      if (mounted) {
        if (success) {
          // Success! (Or mock success)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.premiumUnlocked),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          // Failed or Store Unavailable
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(AppLocalizations.of(context)!.purchaseFailed),
              backgroundColor: Colors.orange.shade800,
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.ok,
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.orange.shade400, Colors.orange.shade700],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.premiumAccess,
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.premiumBenefitsDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16, 
                        color: Colors.black87, 
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: Column(
                        children: [
                          _buildBenefitItem(Icons.block, AppLocalizations.of(context)!.benefitRemoveAds),
                          _buildBenefitItem(Icons.bolt, AppLocalizations.of(context)!.benefitPerformance),
                          _buildBenefitItem(Icons.star_rounded, AppLocalizations.of(context)!.benefitFutureFeatures),
                          _buildBenefitItem(Icons.volunteer_activism, AppLocalizations.of(context)!.benefitSupport),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Main Purchase Button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _handlePurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 4,
                          shadowColor: Colors.orange.shade200,
                        ),
                        child: _isProcessing 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shopping_cart_checkout),
                                SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(context)!.unlockNow, 
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextButton(
                      onPressed: _isProcessing ? null : () => ref.read(billingNotifierProvider.notifier).restorePurchases(),
                      style: TextButton.styleFrom(foregroundColor: Colors.orange.shade900),
                      child: Text(
                        AppLocalizations.of(context)!.restorePurchase, 
                        style: TextStyle(fontWeight: FontWeight.w600, decoration: TextDecoration.underline, fontSize: 13),
                      ),
                    ),
                    
                    const Divider(height: 40, thickness: 1),
                    
                    Text(AppLocalizations.of(context)!.legalInfo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegalLink(label: AppLocalizations.of(context)!.terms, onTap: () => context.push('/legal')),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('•', style: TextStyle(color: Colors.black26)),
                        ),
                        _LegalLink(label: AppLocalizations.of(context)!.privacy, onTap: () => context.push('/legal')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.backToFree, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.green.shade800),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text, 
              style: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w600, 
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LegalLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            decoration: TextDecoration.underline,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
