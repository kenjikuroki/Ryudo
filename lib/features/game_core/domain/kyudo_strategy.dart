import 'dart:math';
import 'dart:ui';
import 'base_game_strategy.dart';

class KyudoStrategy implements BaseGameStrategy {
  @override
  String get id => 'kyudo';

  @override
  String get name => 'Kyudo';

  @override
  String get targetImageAssets => 'assets/images/kyudo_target.png';

  @override
  ScoreInputType get inputType => ScoreInputType.tap;

  @override
  int calculateScore(Offset tapPosition, Size imageSize) {
    // Center of the image
    final center = Offset(imageSize.width / 2, imageSize.height / 2);
    
    // Distance from center
    final distance = (tapPosition - center).distance;
    
    // Max radius (assuming the target fills the smaller dimension)
    // The target image is usually a perfect circle inside a square asset
    final maxRadius = (min(imageSize.width, imageSize.height) / 2) * 0.7;
    
    // In Kyudo, if it hits the target (Mato), it's a hit (Atari).
    // We count it as 1 point for a hit, 0 for a miss.
    // Strictly speaking, we should check if it hits the "Mato" visual area.
    // Assuming the image is the target and it fills the bounds:
    
    if (distance <= maxRadius) {
      return 1; // Hit
    } else {
      return 0; // Miss
    }
  }
}
