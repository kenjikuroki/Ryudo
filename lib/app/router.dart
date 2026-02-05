import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/game_core/presentation/game_page.dart';
import '../features/game_core/presentation/result_page.dart';
import '../features/game_core/presentation/game_provider.dart';
import '../features/game_core/presentation/home_page.dart';
import '../features/monetization/presentation/legal_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const GamePage(),
    ),
    GoRoute(
      path: '/results',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final gameState = extra['gameState'] as GameState;
        final isReadOnly = extra['isReadOnly'] as bool? ?? false;
        return ResultPage(gameState: gameState, isReadOnly: isReadOnly);
      },
    ),
    GoRoute(
      path: '/legal',
      builder: (context, state) => const LegalPage(),
    ),
  ],
);


