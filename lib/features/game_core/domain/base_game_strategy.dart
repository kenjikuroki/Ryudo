import 'dart:ui';

enum ScoreInputType {
  tap,
  button,
}

abstract class BaseGameStrategy {
  String get id;
  String get name;
  String get targetImageAssets;
  ScoreInputType get inputType;

  int calculateScore(Offset tapPosition, Size imageSize);
}
