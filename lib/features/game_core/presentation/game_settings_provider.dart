import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_provider.dart';

part 'game_settings_provider.g.dart';

class GameSettings {
  final GameMode mode;
  final int totalEnds;
  final int shotsPerEnd;
  final String? distance;
  final String? sightMark;

  GameSettings({
    required this.mode,
    required this.totalEnds,
    required this.shotsPerEnd,
    this.distance,
    this.sightMark,
  });

  GameSettings copyWith({
    GameMode? mode,
    int? totalEnds,
    int? shotsPerEnd,
    String? distance,
    String? sightMark,
  }) {
    return GameSettings(
      mode: mode ?? this.mode,
      totalEnds: totalEnds ?? this.totalEnds,
      shotsPerEnd: shotsPerEnd ?? this.shotsPerEnd,
      distance: distance ?? this.distance,
      sightMark: sightMark ?? this.sightMark,
    );
  }
}

@riverpod
class GameSettingsNotifier extends _$GameSettingsNotifier {
  static const _keyMode = 'game_mode';
  static const _keyTotalEnds = 'total_ends';
  static const _keyShotsPerEnd = 'shots_per_end';
  static const _keyDistance = 'distance';
  static const _keySightMark = 'sight_mark';

  @override
  GameSettings build() {
    // Initial state is default, will be updated by loadSettings
    _loadSettings();
    return GameSettings(
      mode: GameMode.unlimited,
      totalEnds: 5,
      shotsPerEnd: 4,
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_keyMode) ?? GameMode.unlimited.index;
    final totalEnds = prefs.getInt(_keyTotalEnds) ?? 5;
    final shotsPerEnd = prefs.getInt(_keyShotsPerEnd) ?? 4;
    final distance = prefs.getString(_keyDistance);
    final sightMark = prefs.getString(_keySightMark);

    state = GameSettings(
      mode: GameMode.values[modeIndex],
      totalEnds: totalEnds,
      shotsPerEnd: shotsPerEnd,
      distance: distance,
      sightMark: sightMark,
    );
  }

  Future<void> updateMode(GameMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMode, mode.index);
  }

  Future<void> updateTotalEnds(int ends) async {
    state = state.copyWith(totalEnds: ends);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTotalEnds, ends);
  }

  Future<void> updateShotsPerEnd(int shots) async {
    state = state.copyWith(shotsPerEnd: shots);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyShotsPerEnd, shots);
  }

  Future<void> updateDistance(String? distance) async {
    state = state.copyWith(distance: distance);
    final prefs = await SharedPreferences.getInstance();
    if (distance == null) {
      await prefs.remove(_keyDistance);
    } else {
      await prefs.setString(_keyDistance, distance);
    }
  }

  Future<void> updateSightMark(String? mark) async {
    state = state.copyWith(sightMark: mark);
    final prefs = await SharedPreferences.getInstance();
    if (mark == null) {
      await prefs.remove(_keySightMark);
    } else {
      await prefs.setString(_keySightMark, mark);
    }
  }
}
