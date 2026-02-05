import 'dart:math';
import 'dart:ui';
import 'base_game_strategy.dart';

class ArcheryStrategy implements BaseGameStrategy {
  @override
  String get id => 'archery';

  @override
  String get name => 'Archery';

  @override
  String get targetImageAssets => 'assets/images/archery_target.png';

  @override
  ScoreInputType get inputType => ScoreInputType.tap;

  @override
  int calculateScore(Offset tapPosition, Size imageSize) {
    // Center of the image
    final center = Offset(imageSize.width / 2, imageSize.height / 2);
    
    // Distance from center
    final distance = (tapPosition - center).distance;
    
    // Max radius (assuming the target fills the smaller dimension)
    final maxRadius = min(imageSize.width, imageSize.height) / 2;
    
    if (distance > maxRadius) return 0;

    // Divide into 10 rings
    // 10 rings: 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
    final ringWidth = maxRadius / 10;
    final ringIndex = (distance / ringWidth).floor();
    
    // 10 points for the center (ringIndex 0), 1 point for the edge (ringIndex 9)
    final score = 10 - ringIndex;
    
    return max(0, score);
  }
}
