import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archery/features/game_core/presentation/game_provider.dart';
import 'package:archery/features/game_core/presentation/game_settings_provider.dart';

import 'package:archery/l10n/gen/app_localizations.dart';

class InteractiveEndCounter extends ConsumerWidget {
  final Color? labelColor;
  final Color? valueColor;

  const InteractiveEndCounter({
    this.labelColor,
    this.valueColor,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final notifier = ref.read(gameNotifierProvider.notifier);

    final isRound = gameState.mode == GameMode.round;
    final currentIndex = gameState.currentEndIndex;
    final targetEnds = gameState.targetEnds;

    return GestureDetector(
      onTap: null, // Removed unintended mode switching
      onLongPress: () => _showTargetEndsPicker(context, ref, targetEnds),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.transparent, 
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.roundStatus, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: labelColor)),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                isRound ? '$currentIndex / ${targetEnds ?? "--"}' : '$currentIndex',
                key: ValueKey('${gameState.mode}_$currentIndex'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTargetEndsPicker(BuildContext context, WidgetRef ref, int? currentTarget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.setTargetRounds),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [12, 24, 36, 72].map((ends) {
              return ListTile(
                title: Text('$ends ${AppLocalizations.of(context)!.rounds}'),
                selected: ends == currentTarget,
                trailing: ends == currentTarget ? const Icon(Icons.check) : null,
                onTap: () {
                  ref.read(gameNotifierProvider.notifier).updateTargetEnds(ends);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }
}
