import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:archery/features/game_core/presentation/game_provider.dart';
import 'package:archery/features/game_core/presentation/game_settings_provider.dart';
import 'package:archery/features/game_core/presentation/target_board_widget.dart';
import 'package:archery/features/game_core/presentation/score_sheet_widget.dart';
import 'package:archery/features/game_core/presentation/interactive_end_counter.dart';
import 'package:archery/features/game_core/domain/score_display_strategy.dart';
import 'package:archery/features/game_core/presentation/stylish_confirm_dialog.dart';
import 'package:archery/features/monetization/presentation/ad_banner_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../app/responsive_layout.dart';
import 'dart:math';
import 'package:archery/l10n/gen/app_localizations.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final notifier = ref.read(gameNotifierProvider.notifier);

    final isRound = gameState.mode == GameMode.round;
    final backgroundColor = isRound ? Colors.indigo.shade50 : Colors.grey.shade50;
    final primaryTextColor = isRound ? Colors.indigo.shade900 : Colors.black87;
    final secondaryTextColor = isRound ? Colors.indigo.shade700 : Colors.grey.shade700;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: ResponsiveLayout(
          backgroundColor: backgroundColor,
          child: SafeArea(
            child: Stack(
            children: [
              Column(
                children: [
                  // Unified Animated Header
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    color: backgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        // Custom App Bar style row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _HeaderActionButton(
                              onPressed: () {
                                final isRound = gameState.mode == GameMode.round;
                                final isComplete = isRound && 
                                    (gameState.targetEnds != null && gameState.currentEndIndex >= gameState.targetEnds!) &&
                                    (gameState.currentEndShots.length >= gameState.shotsPerEnd);

                                final finishSession = () {
                                  notifier.nextEnd();
                                  final finalState = ref.read(gameNotifierProvider);
                                  context.push(
                                    '/results',
                                    extra: {
                                      'gameState': finalState,
                                      'isReadOnly': false,
                                    },
                                  );
                                };

                                if (isRound && !isComplete) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => StylishConfirmDialog(
                                      title: AppLocalizations.of(context)!.finishSessionTitle,
                                      content: AppLocalizations.of(context)!.finishSessionContent,
                                      confirmLabel: AppLocalizations.of(context)!.finishAndSave,
                                      onConfirm: finishSession,
                                    ),
                                  );
                                } else if (!isRound) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => StylishConfirmDialog(
                                      title: AppLocalizations.of(context)!.finishPracticeTitle,
                                      content: AppLocalizations.of(context)!.finishPracticeContent,
                                      confirmLabel: AppLocalizations.of(context)!.finishAndSave,
                                      onConfirm: finishSession,
                                    ),
                                  );
                                } else {
                                  // Round mode and already complete
                                  finishSession();
                                }
                              },
                              label: AppLocalizations.of(context)!.finish,
                              icon: Icons.check_circle_outline,
                              color: primaryTextColor,
                            ),
                            // Toggle Title Wrapper
                            Container(
                              decoration: BoxDecoration(
                                color: primaryTextColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ModeToggleButton(
                                    isActive: !isRound,
                                    icon: Icons.all_inclusive,
                                    label: AppLocalizations.of(context)!.practice,
                                    activeColor: primaryTextColor,
                                    onTap: () {
                                      if (isRound) {
                                        final hasData = gameState.pastEnds.isNotEmpty || gameState.currentEndShots.isNotEmpty;
                                        if (hasData) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => StylishConfirmDialog(
                                              title: AppLocalizations.of(context)!.switchModeTitle,
                                              content: AppLocalizations.of(context)!.switchModeContent,
                                              confirmLabel: AppLocalizations.of(context)!.resetAndSwitch,
                                              onConfirm: () {
                                                notifier.resetSession();
                                                notifier.updateMode(GameMode.unlimited);
                                              },
                                              isDestructive: true,
                                            ),
                                          );
                                        } else {
                                          notifier.updateMode(GameMode.unlimited);
                                        }
                                      }
                                    },
                                  ),
                                  _ModeToggleButton(
                                    isActive: isRound,
                                    icon: Icons.timer,
                                    label: AppLocalizations.of(context)!.competition,
                                    activeColor: primaryTextColor,
                                    onTap: () {
                                      if (!isRound) {
                                        final hasData = gameState.pastEnds.isNotEmpty || gameState.currentEndShots.isNotEmpty;
                                        
                                        final performSwitch = () {
                                          notifier.resetSession();
                                          notifier.updateMode(GameMode.round);
                                          if (gameState.targetEnds == null) {
                                            final settings = ref.read(gameSettingsNotifierProvider);
                                            notifier.updateTargetEnds(settings.totalEnds);
                                          }
                                        };

                                        if (hasData) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => StylishConfirmDialog(
                                              title: AppLocalizations.of(context)!.switchModeTitle,
                                              content: AppLocalizations.of(context)!.switchModeContent,
                                              confirmLabel: AppLocalizations.of(context)!.resetAndSwitch,
                                              onConfirm: performSwitch,
                                              isDestructive: true,
                                            ),
                                          );
                                        } else {
                                          performSwitch();
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                             IconButton(
                               icon: const Icon(Icons.refresh),
                               color: primaryTextColor,
                               onPressed: () {
                                 showDialog(
                                   context: context,
                                   builder: (context) => StylishConfirmDialog(
                                     title: AppLocalizations.of(context)!.resetSessionTitle,
                                     content: AppLocalizations.of(context)!.resetSessionContent,
                                     confirmLabel: AppLocalizations.of(context)!.reset,
                                     onConfirm: () => notifier.resetSession(),
                                     isDestructive: true,
                                    ),
                                 );
                               },
                             ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Environment Chips (Distance, Sight, Ends)
                        _buildEnvironmentControlBar(context, ref, gameState, notifier),
                        const SizedBox(height: 12),
                        // Stats Row with Slide Animation
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            final offsetAnimation = Tween<Offset>(
                              begin: isRound ? const Offset(0.3, 0.0) : const Offset(-0.3, 0.0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ));
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              key: ValueKey(gameState.mode),
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _ScoreStat(
                                    label: AppLocalizations.of(context)!.totalScore, 
                                    value: gameState.totalScore.toString(),
                                    labelColor: secondaryTextColor,
                                    valueColor: primaryTextColor,
                                  ),
                                  InteractiveEndCounter(
                                    labelColor: secondaryTextColor,
                                    valueColor: primaryTextColor,
                                  ),
                                  _ScoreStat(
                                    label: AppLocalizations.of(context)!.arrowStatus, 
                                    value: gameState.mode == GameMode.round
                                      ? '${gameState.currentEndShots.length} / ${gameState.shotsPerEnd}'
                                      : '${gameState.currentEndShots.length}',
                                    labelColor: secondaryTextColor,
                                    valueColor: (gameState.mode == GameMode.round && gameState.currentEndShots.length >= gameState.shotsPerEnd)
                                      ? Colors.orange.shade700 
                                      : primaryTextColor,
                                  ),
                                  Column(
                                    children: [
                                      Text(AppLocalizations.of(context)!.undo, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: secondaryTextColor)),
                                      const SizedBox(height: 4),
                                      IconButton(
                                        onPressed: gameState.currentEndShots.isEmpty ? null : () => notifier.undoLastShot(),
                                        icon: const Icon(Icons.undo, size: 28),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        visualDensity: VisualDensity.compact,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TargetBoardWidget(
                          strategy: gameState.strategy,
                          shots: gameState.currentEndShots,
                          onShotAdded: (offset, score) {
                            final isRound = gameState.mode == GameMode.round;
                            if (!isRound || gameState.currentEndShots.length < gameState.shotsPerEnd) {
                              notifier.addShot(offset, score);
                            } else {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.targetArrowsReached(gameState.shotsPerEnd)),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.orange.shade800,
                                ),
                              );
                            }
                          },
                          onShotLongPressed: (shot) {
                            notifier.removeShot(shot);
                          },
                        ),
                      ),
                    ),
                  ),
                  // Spacer for the DraggableSheet initial height
                  const SizedBox(height: 120),
                ],
              ),
               DraggableScrollableSheet(
                initialChildSize: 0.2,
                minChildSize: 0.15,
                maxChildSize: 0.7,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        // Handlebar
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.scoreSheet, style: const TextStyle(fontWeight: FontWeight.bold)),
                              _EndNextButton(
                                isActive: gameState.currentEndShots.isNotEmpty,
                                onPressed: () async {
                                  final performNextEnd = () {
                                    final mode = gameState.mode;
                                    final current = gameState.currentEndIndex;
                                    final target = gameState.targetEnds;
                                    
                                    notifier.nextEnd();
                                    
                                    if (mode == GameMode.round && target != null && current >= target) {
                                      final finalState = ref.read(gameNotifierProvider);
                                      if (context.mounted) {
                                        context.push('/results', extra: {
                                          'gameState': finalState,
                                          'isReadOnly': false,
                                        });
                                      }
                                    }
                                  };

                                  if (gameState.currentEndShots.length < gameState.shotsPerEnd) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => StylishConfirmDialog(
                                        title: AppLocalizations.of(context)!.endIncompleteTitle,
                                        content: AppLocalizations.of(context)!.endIncompleteContent(gameState.shotsPerEnd, gameState.currentEndShots.length),
                                        confirmLabel: AppLocalizations.of(context)!.proceed,
                                        onConfirm: performNextEnd,
                                      ),
                                    );
                                  } else {
                                    performNextEnd();
                                  }
                                },
                                color: isRound ? Colors.indigo : Colors.blueGrey,
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ScoreSheetWidget(
                            pastEnds: gameState.pastEnds,
                            currentEndShots: gameState.currentEndShots,
                            displayStrategy: KyudoScoreDisplayStrategy(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          ),
        ),
        bottomNavigationBar: const AdBannerWidget(),
      ),
    );
  }

  Widget _buildEnvironmentControlBar(
    BuildContext context, 
    WidgetRef ref, 
    GameState gameState, 
    GameNotifier notifier
  ) {
    final isRound = gameState.mode == GameMode.round;
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _LargeEnvironmentChip(
              icon: Icons.straighten,
              label: gameState.distance ?? '28m',
              onTap: () => _showDistanceDialog(context, notifier, gameState),
            ),
            if (isRound) ...[
              const SizedBox(width: 8),
              _LargeEnvironmentChip(
                icon: Icons.settings,
                label: '',
                onTap: () => _showSessionSettingsDialog(context, notifier, gameState),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSessionSettingsDialog(BuildContext context, GameNotifier notifier, GameState state) {
    final endsOptions = [1, 2, 4, 5, 8, 10, 12, 20];
    final shotsOptions = [2, 4, 8, 12, 20];
    
    showDialog(
      context: context,
      builder: (context) => Consumer(
          builder: (context, ref, child) {
            final currentState = ref.watch(gameNotifierProvider);
            final currentEnd = currentState.pastEnds.length + 1;
            final currentShotsInEnd = currentState.currentEndShots.length;

            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.settings_suggest, color: Colors.indigo.shade700, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(AppLocalizations.of(context)!.sessionFormat, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                ],
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(label: AppLocalizations.of(context)!.totalRounds),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.maxFinite,
                    child: Builder(
                      builder: (context) {
                        final dialogWidth = MediaQuery.of(context).size.width * 0.8;
                        final itemWidth = (dialogWidth - (3 * 8) - 48) / 4;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: endsOptions.map((e) {
                            final isSelected = currentState.targetEnds == e;
                            final isDisabled = e < currentEnd;
                            
                            return InkWell(
                              onTap: isDisabled ? null : () {
                                final isSessionActive = currentState.pastEnds.isNotEmpty || currentState.currentEndShots.isNotEmpty;
                                
                                final applyEnds = () {
                                  notifier.updateTargetEnds(e);
                                  if (isSessionActive) notifier.resetSession();
                                };

                                if (isSessionActive && !isSelected) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => StylishConfirmDialog(
                                      title: AppLocalizations.of(context)!.resetForNewFormatTitle,
                                      content: AppLocalizations.of(context)!.resetForNewFormatContent,
                                      confirmLabel: AppLocalizations.of(context)!.resetAndApply,
                                      onConfirm: applyEnds,
                                      isDestructive: true,
                                    ),
                                  );
                                } else {
                                  notifier.updateTargetEnds(e);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: itemWidth,
                                height: itemWidth * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected 
                                      ? Colors.indigo 
                                      : (isDisabled ? Colors.grey.shade100 : Colors.white),
                                  border: Border.all(
                                    color: isSelected 
                                        ? Colors.indigo 
                                        : (isDisabled ? Colors.grey.shade200 : Colors.grey.shade300),
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected ? [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$e',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected 
                                        ? Colors.white 
                                        : (isDisabled ? Colors.grey.shade400 : Colors.black87),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(label: AppLocalizations.of(context)!.arrowsPerRound),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.maxFinite,
                    child: Builder(
                      builder: (context) {
                        final dialogWidth = MediaQuery.of(context).size.width * 0.8;
                        final itemWidth = (dialogWidth - (3 * 8) - 48) / 4;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: shotsOptions.map((s) {
                            final isSelected = currentState.shotsPerEnd == s;
                            final isDisabled = s < currentShotsInEnd;

                            return InkWell(
                              onTap: isDisabled ? null : () {
                                final isSessionActive = currentState.pastEnds.isNotEmpty || currentState.currentEndShots.isNotEmpty;
                                
                                final applyShots = () {
                                  notifier.updateShotsPerEnd(s);
                                  if (isSessionActive) notifier.resetSession();
                                };

                                if (isSessionActive && !isSelected) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => StylishConfirmDialog(
                                      title: AppLocalizations.of(context)!.resetForNewFormatTitle,
                                      content: AppLocalizations.of(context)!.resetForNewFormatContent,
                                      confirmLabel: AppLocalizations.of(context)!.resetAndApply,
                                      onConfirm: applyShots,
                                      isDestructive: true,
                                    ),
                                  );
                                } else {
                                  notifier.updateShotsPerEnd(s);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: itemWidth,
                                height: itemWidth * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected 
                                      ? Colors.indigo 
                                      : (isDisabled ? Colors.grey.shade100 : Colors.white),
                                  border: Border.all(
                                    color: isSelected 
                                        ? Colors.indigo 
                                        : (isDisabled ? Colors.grey.shade200 : Colors.grey.shade300),
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected ? [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : null,
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$s',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected 
                                            ? Colors.white 
                                            : (isDisabled ? Colors.grey.shade400 : Colors.black87),
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.arr,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected 
                                            ? Colors.white.withOpacity(0.8) 
                                            : (isDisabled ? Colors.grey.shade400 : Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.applySettings, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo, fontSize: 16)),
                ),
              ],
            );
          },
        ),
    );
  }

  void _showDistanceDialog(BuildContext context, GameNotifier notifier, GameState state) {
    const distances = ['28m', '60m'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.straighten, color: Colors.indigo.shade700),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.selectDistance),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.chooseDistance,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final dialogWidth = MediaQuery.of(context).size.width * 0.8;
                  final itemWidth = (dialogWidth - (2 * 10) - 48) / 3;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ...distances.map((d) {
                        final isSelected = state.distance == d;
                        return InkWell(
                          onTap: () {
                            notifier.updateDistance(d);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: itemWidth,
                            height: itemWidth * 0.7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected ? Colors.indigo : Colors.indigo.withOpacity(0.08),
                              border: Border.all(
                                color: isSelected ? Colors.indigo : Colors.indigo.withOpacity(0.1),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              d, 
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                                color: isSelected ? Colors.white : Colors.indigo,
                              ),
                            ),
                          ),
                        );
                      }),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showCustomDistanceDialog(context, notifier);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: itemWidth,
                          height: itemWidth * 0.7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.orange.withOpacity(0.1),
                            border: Border.all(color: Colors.orange.withOpacity(0.2)),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, size: 14, color: Colors.orange),
                              Text(
                                AppLocalizations.of(context)!.custom, 
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomDistanceDialog(BuildContext context, GameNotifier notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.customDistance),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.exampleDistance,
            suffixText: 'm',
            filled: true,
            fillColor: Colors.black.withOpacity(0.04),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          autofocus: true,
          keyboardType: TextInputType.text,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () {
              var val = controller.text;
              if (val.isNotEmpty && !val.endsWith('m')) val += 'm';
              notifier.updateDistance(val);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showSightMarkDialog(BuildContext context, GameNotifier notifier, String? current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.tune, color: Colors.indigo.shade700),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.bowStrength),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your bow strength (e.g. 15kg).',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'ex: 15kg',
                filled: true,
                fillColor: Colors.black.withOpacity(0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.fitness_center, color: Colors.indigo),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              autofocus: true,
              keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.updateSightMark(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Save Mark', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _LargeEnvironmentChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LargeEnvironmentChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.5),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: label.isEmpty ? 12 : 20, 
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.indigo.withOpacity(0.3), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.indigo.shade700),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  final bool isActive;
  final IconData icon;
  final String label;
  final Color activeColor;
  final VoidCallback onTap;

  const _ModeToggleButton({
    required this.isActive,
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : activeColor.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : activeColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color color;

  const _HeaderActionButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndNextButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;
  final Color color;

  const _EndNextButton({
    required this.isActive,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isActive
              ? LinearGradient(
                  colors: [color, color.withBlue(min(255, color.blue + 30))],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.grey.shade200,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: ElevatedButton.icon(
          onPressed: isActive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
          label: const Text(
            'Next Set',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  const _ScoreStat({
    required this.label, 
    required this.value,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: labelColor)),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Colors.indigo.shade300,
        letterSpacing: 1.2,
      ),
    );
  }
}
