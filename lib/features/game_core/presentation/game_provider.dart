import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:archery/features/game_core/presentation/target_board_widget.dart';
import 'package:archery/features/game_core/presentation/game_settings_provider.dart';
import 'package:archery/features/game_core/domain/base_game_strategy.dart';
import 'package:archery/features/game_core/domain/archery_strategy.dart';
import 'package:archery/features/game_core/data/database_provider.dart';

import 'package:archery/features/game_core/domain/kyudo_strategy.dart';

part 'game_provider.g.dart';
enum GameMode { unlimited, round }

class GameState {
  final BaseGameStrategy strategy;
  final List<List<ShotPoint>> pastEnds;
  final List<ShotPoint> currentEndShots;
  final GameMode mode;
  final int? targetEnds;
  final int shotsPerEnd;
  final int? sessionId;
  final String? distance;
  final String? sightMark;

  GameState({
    required this.strategy,
    required this.pastEnds,
    required this.currentEndShots,
    this.mode = GameMode.unlimited,
    this.targetEnds,
    this.shotsPerEnd = 4,
    this.sessionId,
    this.distance,
    this.sightMark,
  });

  int get totalScore {
    final pastScore = pastEnds.fold(0, (sum, end) => sum + end.fold(0, (s, shot) => s + shot.score));
    return pastScore + currentEndScore;
  }

  int get currentEndScore => currentEndShots.fold(0, (sum, shot) => sum + shot.score);
  int get currentEndIndex => pastEnds.length + 1;

  GameState copyWith({
    BaseGameStrategy? strategy,
    List<List<ShotPoint>>? pastEnds,
    List<ShotPoint>? currentEndShots,
    GameMode? mode,
    int? targetEnds,
    int? shotsPerEnd,
    String? distance,
    String? sightMark,
  }) {
    return GameState(
      strategy: strategy ?? this.strategy,
      pastEnds: pastEnds ?? this.pastEnds,
      currentEndShots: currentEndShots ?? this.currentEndShots,
      mode: mode ?? this.mode,
      targetEnds: targetEnds ?? this.targetEnds,
      shotsPerEnd: shotsPerEnd ?? this.shotsPerEnd,
      sessionId: sessionId ?? this.sessionId,
      distance: distance ?? this.distance,
      sightMark: sightMark ?? this.sightMark,
    );
  }
}

@riverpod
class GameNotifier extends _$GameNotifier {
  @override
  GameState build() {
    final settings = ref.read(gameSettingsNotifierProvider);
    
    // Listen for settings changes to sync initial values (e.g. after async load)
    // without resetting if a session is already in progress.
    ref.listen<GameSettings>(gameSettingsNotifierProvider, (prev, next) {
      // Only sync if the session hasn't started yet
      if (state.pastEnds.isEmpty && state.currentEndShots.isEmpty) {
        state = state.copyWith(
          mode: next.mode,
          targetEnds: next.mode == GameMode.round ? next.totalEnds : null,
          shotsPerEnd: next.shotsPerEnd,
          distance: next.distance,
          sightMark: next.sightMark,
        );
      }
    });

    return GameState(
      strategy: KyudoStrategy(),
      pastEnds: [],
      currentEndShots: [],
      mode: settings.mode,
      targetEnds: settings.mode == GameMode.round ? settings.totalEnds : null,
      shotsPerEnd: settings.shotsPerEnd,
      distance: settings.distance,
      sightMark: settings.sightMark,
    );
  }

  void startSession({
    required GameMode mode, 
    int? targetEnds, 
    int shotsPerEnd = 4,
    String? distance,
    String? sightMark,
  }) {
    state = GameState(
      strategy: KyudoStrategy(),
      pastEnds: [],
      currentEndShots: [],
      mode: mode,
      targetEnds: targetEnds,
      shotsPerEnd: shotsPerEnd,
      distance: distance,
      sightMark: sightMark,
    );
  }

  void updateMode(GameMode mode) {
    state = state.copyWith(mode: mode);
  }

  void updateTargetEnds(int? ends) {
    state = state.copyWith(targetEnds: ends);
    if (ends != null) {
      ref.read(gameSettingsNotifierProvider.notifier).updateTotalEnds(ends);
    }
  }

  void updateShotsPerEnd(int shots) {
    state = state.copyWith(shotsPerEnd: shots);
    ref.read(gameSettingsNotifierProvider.notifier).updateShotsPerEnd(shots);
  }

  void addShot(Offset relativeOffset, int score) {
    state = state.copyWith(
      currentEndShots: [...state.currentEndShots, ShotPoint(offset: relativeOffset, score: score)],
    );
  }

  void undoLastShot() {
    if (state.currentEndShots.isEmpty) return;
    
    final newShots = List<ShotPoint>.from(state.currentEndShots);
    newShots.removeLast();
    state = state.copyWith(currentEndShots: newShots);
  }

  void removeShot(ShotPoint shot) {
    state = state.copyWith(
      currentEndShots: state.currentEndShots.where((s) => s != shot).toList(),
    );
  }

  void updateDistance(String? distance) {
    state = state.copyWith(distance: distance);
    ref.read(gameSettingsNotifierProvider.notifier).updateDistance(distance);
  }

  void updateSightMark(String? sightMark) {
    state = state.copyWith(sightMark: sightMark);
    ref.read(gameSettingsNotifierProvider.notifier).updateSightMark(sightMark);
  }

  void nextEnd() {

    if (state.currentEndShots.isEmpty) return;
    
    state = state.copyWith(
      pastEnds: [...state.pastEnds, state.currentEndShots],
      currentEndShots: [],
    );
  }

  void resetSession() {
    state = state.copyWith(
      pastEnds: [],
      currentEndShots: [],
    );
  }

  Future<void> saveSessionToDatabase() async {
    await _save(state.strategy.id, state.mode, state.pastEnds, state.distance, state.sightMark);
    resetSession();
  }

  Future<void> saveSpecificSession(GameState sessionToSave) async {
    await _save(
      sessionToSave.strategy.id, 
      sessionToSave.mode, 
      sessionToSave.pastEnds,
      sessionToSave.distance,
      sessionToSave.sightMark,
    );
    resetSession();
  }

  Future<void> _save(String strategyId, GameMode mode, List<List<ShotPoint>> ends, String? distance, String? sightMark) async {
    final db = ref.read(appDatabaseProvider);
    await db.saveSession(
      strategyId: strategyId,
      mode: mode.name,
      ends: ends,
      distance: distance,
      sightMark: sightMark,
    );
  }
}


