import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'game_provider.dart';
import 'game_settings_provider.dart';

class GameSetupSheet extends ConsumerStatefulWidget {
  const GameSetupSheet({super.key});

  @override
  ConsumerState<GameSetupSheet> createState() => _GameSetupSheetState();
}

class _GameSetupSheetState extends ConsumerState<GameSetupSheet> {
  late TextEditingController _distanceController;
  late TextEditingController _sightMarkController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(gameSettingsNotifierProvider);
    _distanceController = TextEditingController(text: settings.distance);
    _sightMarkController = TextEditingController(text: settings.sightMark);
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _sightMarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameSettingsNotifierProvider);
    final notifier = ref.read(gameSettingsNotifierProvider.notifier);

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Game Setup',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          const SizedBox(height: 24),
          
          // Mode Selection
          Text('Mode', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _CompactModeToggle(
                  isActive: settings.mode == GameMode.unlimited,
                  icon: Icons.all_inclusive,
                  label: 'Free',
                  onTap: () => notifier.updateMode(GameMode.unlimited),
                ),
                _CompactModeToggle(
                  isActive: settings.mode == GameMode.round,
                  icon: Icons.timer,
                  label: 'Round',
                  onTap: () => notifier.updateMode(GameMode.round),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Total Ends (visible only for Round Mode)
          if (settings.mode == GameMode.round) ...[
            _SettingCounter(
              label: 'Total Ends',
              value: settings.totalEnds,
              min: 1,
              max: 24,
              onChanged: notifier.updateTotalEnds,
            ),
            const SizedBox(height: 16),
          ],

          // Shots per End
          _SettingCounter(
            label: 'Shots per End',
            value: settings.shotsPerEnd,
            min: 1,
            max: 12,
            onChanged: notifier.updateShotsPerEnd,
          ),

          const SizedBox(height: 24),

          // distance & sightMark inputs
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Distance', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: notifier.updateDistance,
                      controller: _distanceController,
                      decoration: InputDecoration(
                        hintText: 'e.g. 70m',
                        prefixIcon: const Icon(Icons.straighten, size: 20),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sight Mark', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: notifier.updateSightMark,
                      controller: _sightMarkController,
                      decoration: InputDecoration(
                        hintText: 'e.g. 5.5',
                        prefixIcon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: () {
              ref.read(gameNotifierProvider.notifier).startSession(
                mode: settings.mode,
                targetEnds: settings.totalEnds,
                shotsPerEnd: settings.shotsPerEnd,
                distance: settings.distance,
                sightMark: settings.sightMark,
              );
              Navigator.pop(context);
              context.go('/game');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Practice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _CompactModeToggle extends StatelessWidget {
  final bool isActive;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CompactModeToggle({
    required this.isActive,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.black87 : Colors.black38,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.black87 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingCounter extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _SettingCounter({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              Text('Range: $min - $max', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$value',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton.filledTonal(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
