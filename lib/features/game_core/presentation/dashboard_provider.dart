import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archery/features/game_core/data/database_provider.dart';
import 'package:archery/features/game_core/presentation/game_provider.dart';
import 'package:archery/features/game_core/presentation/game_settings_provider.dart';

final homeModeProvider = Provider<GameMode>((ref) {
  return ref.watch(gameSettingsNotifierProvider).mode;
});

final recentSessionsProvider = StreamProvider((ref) {
  final mode = ref.watch(homeModeProvider);
  return ref.watch(appDatabaseProvider).watchRecentSessionsWithStats(mode: mode.name);
});

final globalStatsProvider = FutureProvider((ref) {
  final mode = ref.watch(homeModeProvider);
  return ref.watch(appDatabaseProvider).getGlobalStats(mode: mode.name);
});
