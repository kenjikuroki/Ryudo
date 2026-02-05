import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'game_provider.dart';
import 'target_board_widget.dart';
import 'dashboard_provider.dart';
import 'stylish_confirm_dialog.dart';
import '../data/database_provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../monetization/presentation/ad_banner_widget.dart';
import '../../monetization/application/ad_manager.dart';
import '../../monetization/application/billing_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../app/responsive_layout.dart';
import 'package:archery/l10n/gen/app_localizations.dart';

class ResultPage extends ConsumerStatefulWidget {
  final GameState gameState;
  final bool isReadOnly;

  const ResultPage({
    super.key, 
    required this.gameState, 
    this.isReadOnly = false,
  });

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitial();
  }

  void _loadInterstitial() {
    // Don't load if user is premium
    final isPremium = ref.read(billingNotifierProvider).value ?? false;
    if (isPremium || widget.isReadOnly) return;

    AdManager.loadInterstitialAd(
      onAdLoaded: (ad) {
        _interstitialAd = ad;
      },
    );
  }

  void _showAdAndThen(VoidCallback onComplete) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          onComplete();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onComplete();
        },
      );
      _interstitialAd!.show();
    } else {
      onComplete();
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = widget.gameState;
    final isRound = gameState.mode == GameMode.round;
    final backgroundColor = isRound ? Colors.indigo.shade50 : Colors.grey.shade50;
    final primaryTextColor = isRound ? Colors.indigo.shade900 : Colors.black87;
    final secondaryTextColor = isRound ? Colors.indigo.shade700 : Colors.grey.shade700;

    final allShots = gameState.pastEnds.expand((e) => e).toList();
    final totalShots = allShots.length;
    final hitRate = totalShots > 0 ? (gameState.totalScore / totalShots) * 100 : 0.0;

    final distribution = <int, int>{
      1: allShots.where((s) => s.score == 1).length,
      0: allShots.where((s) => s.score == 0).length,
    };

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.resultAnalysis),
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
      ),
      body: ResponsiveLayout(
        backgroundColor: backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
            _buildSummary(context, totalShots, hitRate, isRound, primaryTextColor, secondaryTextColor),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                ),
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _generateAnalysisComment(allShots),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.shotMapping, 
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(
                    height: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TargetBoardWidget(
                        strategy: gameState.strategy,
                        shots: allShots,
                        onShotAdded: (_, __) {}, 
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            _buildDistribution(context, distribution, allShots.length),
            const SizedBox(height: 32),
            _buildActions(context, ref),
            const SizedBox(height: 48),
          ],
        ),
      ),
    ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildSummary(
    BuildContext context, 
    int totalShots, 
    double hitRate, 
    bool isRound,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy/MM/dd HH:mm').format(now);
    final modeLabel = isRound ? AppLocalizations.of(context)!.roundMode : AppLocalizations.of(context)!.freePractice;
    final targetLabel = (isRound && widget.gameState.targetEnds != null) ? AppLocalizations.of(context)!.goalEnds(widget.gameState.targetEnds!) : '';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$modeLabel ${targetLabel.isNotEmpty ? "($targetLabel)" : ""}',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(dateStr, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: secondaryColor)),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.totalScore, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: secondaryColor)),
          Text(
            '${widget.gameState.totalScore}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          if (widget.gameState.distance != null || widget.gameState.sightMark != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.gameState.distance != null)
                  _EnvChip(
                    icon: Icons.straighten,
                    label: widget.gameState.distance!,
                    color: primaryColor,
                  ),
                if (widget.gameState.distance != null && widget.gameState.sightMark != null)
                  const SizedBox(width: 8),
                if (widget.gameState.sightMark != null)
                  _EnvChip(
                    icon: Icons.remove_red_eye_outlined,
                    label: AppLocalizations.of(context)!.sightWithValue(widget.gameState.sightMark!),
                    color: primaryColor,
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: AppLocalizations.of(context)!.hitRate, value: '${hitRate.toStringAsFixed(1)}%', labelColor: secondaryColor, valueColor: primaryColor),
              _StatItem(label: AppLocalizations.of(context)!.shotsCount, value: totalShots.toString(), labelColor: secondaryColor, valueColor: primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistribution(BuildContext context, Map<int, int> distribution, int totalCount) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.scoreBreakdown, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...distribution.entries.where((e) => e.value > 0).map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  SizedBox(width: 40, child: Text(e.key == 1 ? AppLocalizations.of(context)!.hit : AppLocalizations.of(context)!.miss, style: const TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: totalCount == 0 ? 0 : e.value / totalCount,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${e.value}'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    if (widget.isReadOnly) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => context.go('/'),
                child: Text(AppLocalizations.of(context)!.closeHistory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _showDeleteConfirmation(context, ref),
              icon: const Icon(Icons.delete_outline, size: 20),
              label: Text(AppLocalizations.of(context)!.deleteRecord, style: const TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                _showAdAndThen(() async {
                  await ref.read(gameNotifierProvider.notifier).saveSpecificSession(widget.gameState);
                  ref.invalidate(recentSessionsProvider);
                  ref.invalidate(globalStatsProvider);
                  if (context.mounted) context.go('/');
                });
              },
              child: Text(AppLocalizations.of(context)!.saveAndFinish, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _showDiscardDialog(context, ref),
            child: Text(AppLocalizations.of(context)!.discardData, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showDiscardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => StylishConfirmDialog(
        title: AppLocalizations.of(context)!.discardSessionTitle,
        content: AppLocalizations.of(context)!.discardSessionContent,
        confirmLabel: AppLocalizations.of(context)!.discard,
        onConfirm: () {
          _showAdAndThen(() {
            ref.read(gameNotifierProvider.notifier).resetSession();
            context.go('/');
          });
        },
        isDestructive: true,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => StylishConfirmDialog(
        title: AppLocalizations.of(context)!.deleteRecordTitle,
        content: AppLocalizations.of(context)!.deleteRecordContent,
        confirmLabel: AppLocalizations.of(context)!.delete,
        onConfirm: () async {
          if (widget.gameState.sessionId != null) {
            final db = ref.read(appDatabaseProvider);
            await db.deleteSession(widget.gameState.sessionId!);
            ref.invalidate(recentSessionsProvider);
            ref.invalidate(globalStatsProvider);
          }
          if (context.mounted) {
            context.go('/');
          }
        },
        isDestructive: true,
      ),
    );
  }

  String _generateAnalysisComment(List<ShotPoint> shots) {
    if (shots.isEmpty) return AppLocalizations.of(context)!.noDataAvailable;
    double sumX = 0;
    double sumY = 0;
    for (final s in shots) {
      sumX += s.offset.dx;
      sumY += s.offset.dy;
    }
    final meanX = sumX / shots.length;
    final meanY = sumY / shots.length;
    final biasX = meanX - 0.5;
    final biasY = meanY - 0.5;
    String vertical = '';
    if (biasY < -0.05) vertical = AppLocalizations.of(context)!.highUwa;
    else if (biasY > 0.05) vertical = AppLocalizations.of(context)!.lowShita;
    String horizontal = '';
    if (biasX < -0.05) horizontal = AppLocalizations.of(context)!.leftMae;
    else if (biasX > 0.05) horizontal = AppLocalizations.of(context)!.rightUshiro;
    String biasComment = '';
    if (vertical.isNotEmpty || horizontal.isNotEmpty) {
      String trend = vertical.isNotEmpty && horizontal.isNotEmpty ? AppLocalizations.of(context)!.trendAnd(vertical, horizontal) : AppLocalizations.of(context)!.trendJust(vertical, horizontal);
      biasComment = AppLocalizations.of(context)!.arrowsTending(trend);
    } else {
      biasComment = AppLocalizations.of(context)!.greatTekichu;
    }
    double sumDistSq = 0;
    for (final s in shots) {
      final dx = s.offset.dx - meanX;
      final dy = s.offset.dy - meanY;
      sumDistSq += dx * dx + dy * dy;
    }
    final rmsd = sqrt(sumDistSq / shots.length);
    String concentrationComment = '';
    if (rmsd < 0.08) concentrationComment = AppLocalizations.of(context)!.excellentConsistency;
    else if (rmsd > 0.2) concentrationComment = AppLocalizations.of(context)!.scatteredHassetsu;
    return '$biasComment $concentrationComment';
  }
}

class _EnvChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _EnvChip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  const _StatItem({required this.label, required this.value, this.labelColor, this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: labelColor)),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
