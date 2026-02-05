import 'package:flutter/material.dart';

abstract class ScoreDisplayStrategy {
  Widget buildScoreWidget(int score);
  String formatScore(int score);
}

class NumericScoreDisplayStrategy implements ScoreDisplayStrategy {
  @override
  Widget buildScoreWidget(int score) {
    return Text(
      score.toString(),
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  @override
  String formatScore(int score) => score.toString();
}

class KyudoScoreDisplayStrategy implements ScoreDisplayStrategy {
  @override
  Widget buildScoreWidget(int score) {
    // In Kyudo, 1 is hit (◯), 0 is miss (✕)
    return Icon(
      score > 0 ? Icons.circle_outlined : Icons.close,
      color: score > 0 ? Colors.black : Colors.red,
      size: 16,
    );
  }

  @override
  String formatScore(int score) => score > 0 ? '◯' : '✕';
}
