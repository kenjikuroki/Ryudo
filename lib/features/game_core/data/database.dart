import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart' show Offset;
import '../presentation/game_provider.dart' show GameState;
import '../presentation/target_board_widget.dart' show ShotPoint;
import '../domain/base_game_strategy.dart';
import '../domain/archery_strategy.dart';


part 'database.g.dart';

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get gameStrategyId => text()();
  TextColumn get mode => text().withDefault(const Constant('unlimited'))();
  TextColumn get notes => text().nullable()();
  TextColumn get distance => text().nullable()();
  TextColumn get sightMark => text().nullable()();
}

class Rounds extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id)();
  IntColumn get index => integer()(); // e.g., 1st round, 2nd round
}

class Shots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roundId => integer().references(Rounds, #id)();
  IntColumn get score => integer()();
  RealColumn get x => real()(); // Relative X (0.0 to 1.0)
  RealColumn get y => real()(); // Relative Y (0.0 to 1.0)
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Sessions, Rounds, Shots])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(sessions, (sessions as dynamic).mode);
      }
      if (from < 3) {
        await m.addColumn(sessions, (sessions as dynamic).distance);
        await m.addColumn(sessions, (sessions as dynamic).sightMark);
      }
    },
  );

  // Persistence Logic
  Future<int> saveSession({
    required String strategyId,
    required String mode,
    required List<List<ShotPoint>> ends,
    String? distance,
    String? sightMark,
  }) async {
    return transaction(() async {
      final sessionId = await into(sessions).insert(
        SessionsCompanion.insert(
          title: 'Practice Session',
          gameStrategyId: strategyId,
          mode: Value(mode),
          distance: Value(distance),
          sightMark: Value(sightMark),
        ),
      );

      for (var i = 0; i < ends.length; i++) {
        final roundId = await into(rounds).insert(
          RoundsCompanion.insert(
            sessionId: sessionId,
            index: i,
          ),
        );

        for (final shot in ends[i]) {
          await into(shots).insert(
            ShotsCompanion.insert(
              roundId: roundId,
              score: shot.score,
              x: shot.offset.dx,
              y: shot.offset.dy,
            ),
          );
        }
      }
      return sessionId;
    });
  }

  Future<void> deleteSession(int sessionId) async {
    return transaction(() async {
      // Drift usually handles cascading if configured, or we do it manually
      // First delete shots belonging to rounds of this session
      final roundIdsQuery = select(rounds)..where((t) => t.sessionId.equals(sessionId));
      final roundIds = await roundIdsQuery.get();
      
      for (final round in roundIds) {
        await (delete(shots)..where((t) => t.roundId.equals(round.id))).go();
      }
      
      // Then delete rounds
      await (delete(rounds)..where((t) => t.sessionId.equals(sessionId))).go();
      
      // Finally delete the session
      await (delete(sessions)..where((t) => t.id.equals(sessionId))).go();
    });
  }

  // Dashboard Queries
  Stream<List<SessionWithStats>> watchRecentSessionsWithStats({String? mode, int limit = 10}) {
    // Using outer join to make sure sessions without shots can still be detected/debugged
    // and ensuring sorting is applied to the final aggregated list.
    final query = select(sessions).join([
      leftOuterJoin(rounds, rounds.sessionId.equalsExp(sessions.id)),
      leftOuterJoin(shots, shots.roundId.equalsExp(rounds.id)),
    ]);
    
    if (mode != null) {
      query.where(sessions.mode.equals(mode));
    }

    query.orderBy([OrderingTerm.desc(sessions.createdAt)]);
    query.limit(100); // Fetch more rows to ensure we have enough once aggregated

    return query.watch().map((rows) {
      final sessionMap = <int, SessionWithStats>{};

      for (final row in rows) {
        final session = row.readTable(sessions);
        final shot = row.readTableOrNull(shots);

        final current = sessionMap.putIfAbsent(
          session.id,
          () => SessionWithStats(session: session, totalScore: 0, totalShots: 0),
        );

        if (shot != null) {
          sessionMap[session.id] = current.copyWith(
            totalScore: current.totalScore + shot.score,
            totalShots: current.totalShots + 1,
          );
        }
      }
      
      final results = sessionMap.values.toList()
        ..sort((a, b) => b.session.createdAt.compareTo(a.session.createdAt));
        
      return results.take(limit).toList();
    });
  }

  Future<GlobalStats> getGlobalStats({String? mode}) async {
    final scoreSum = shots.score.sum();
    final shotCount = shots.id.count();
    
    // Total Sessions is just session count
    // Base stats query
    final statsQuery = selectOnly(shots).join([
      innerJoin(rounds, rounds.id.equalsExp(shots.roundId)),
      innerJoin(sessions, sessions.id.equalsExp(rounds.sessionId)),
    ])..addColumns([scoreSum, shotCount]);

    if (mode != null) {
      statsQuery.where(sessions.mode.equals(mode));
    }

    final row = await statsQuery.getSingle();

    final totalScore = row.read(scoreSum) ?? 0;
    final totalShots = row.read(shotCount) ?? 0;

    // Best Score (Max session score)
    String bestSql = 'SELECT s.id, SUM(sh.score) as total FROM sessions s '
      'JOIN rounds r ON r.session_id = s.id '
      'JOIN shots sh ON sh.round_id = r.id ';
    
    if (mode != null) {
      bestSql += "WHERE s.mode = '$mode' ";
    }
    
    bestSql += 'GROUP BY s.id ORDER BY total DESC LIMIT 1';

    final sessionsWithScores = await customSelect(bestSql).getSingleOrNull();
    
    final bestScore = sessionsWithScores?.read<int>('total') ?? 0;

    // Count sessions
    final countExp = sessions.id.count();
    final sessionQuery = selectOnly(sessions)..addColumns([countExp]);
    if (mode != null) {
      sessionQuery.where(sessions.mode.equals(mode));
    }
    final sessionCount = await sessionQuery.getSingle().then((row) => row.read(countExp) ?? 0);

    return GlobalStats(
      bestScore: bestScore,
      totalArrows: totalShots,
      average: totalShots > 0 ? (totalScore / totalShots) : 0.0,
      sessionCount: sessionCount,
    );
  }

  Future<GameState?> getSessionAsGameState(int sessionId) async {
    final sessionRow = await (select(sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    if (sessionRow == null) return null;

    final roundsRows = await (select(rounds)
      ..where((t) => t.sessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm.asc(t.index)]))
      .get();

    final pastEnds = <List<ShotPoint>>[];

    for (final roundRow in roundsRows) {
      final shotsRows = await (select(shots)..where((t) => t.roundId.equals(roundRow.id))).get();
      pastEnds.add(
        shotsRows.map((s) => ShotPoint(offset: Offset(s.x, s.y), score: s.score)).toList(),
      );
    }

    // Resolve strategy
    BaseGameStrategy strategy = ArcheryStrategy(); // Default
    if (sessionRow.gameStrategyId == 'archery') {
      strategy = ArcheryStrategy();
    }

    return GameState(
      strategy: strategy,
      pastEnds: pastEnds,
      currentEndShots: [],
      sessionId: sessionId,
      distance: sessionRow.distance,
      sightMark: sessionRow.sightMark,
    );
  }
}


class SessionWithStats {
  final Session session;
  final int totalScore;
  final int totalShots;

  SessionWithStats({
    required this.session,
    required this.totalScore,
    required this.totalShots,
  });

  SessionWithStats copyWith({int? totalScore, int? totalShots}) {
    return SessionWithStats(
      session: session,
      totalScore: totalScore ?? this.totalScore,
      totalShots: totalShots ?? this.totalShots,
    );
  }
}

class GlobalStats {
  final int bestScore;
  final int totalArrows;
  final double average;
  final int sessionCount;

  GlobalStats({
    required this.bestScore,
    required this.totalArrows,
    required this.average,
    required this.sessionCount,
  });
}

LazyDatabase _openConnection() {

  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
