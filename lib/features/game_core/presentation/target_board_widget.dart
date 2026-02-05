import 'package:flutter/material.dart';
import '../domain/base_game_strategy.dart';
import '../domain/kyudo_strategy.dart';
import 'kyudo_target_painter.dart';

class ShotPoint {
  final Offset offset; // Relative (0.0 to 1.0)
  final int score;

  ShotPoint({required this.offset, required this.score});
}

class TargetBoardWidget extends StatelessWidget {
  final BaseGameStrategy strategy;
  final List<ShotPoint> shots;
  final Function(Offset position, int score) onShotAdded;
  final Function(ShotPoint shot)? onShotLongPressed;

  const TargetBoardWidget({
    super.key,
    required this.strategy,
    required this.shots,
    required this.onShotAdded,
    this.onShotLongPressed,
  });


  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final localPosition = details.localPosition;
              final score = strategy.calculateScore(localPosition, size);
              
              // Convert to relative coordinates for storage
              final relativeOffset = Offset(
                localPosition.dx / size.width,
                localPosition.dy / size.height,
              );
              
              onShotAdded(relativeOffset, score);
            },
            child: Stack(
              children: [
                // Target Image (Scaled to 70% to allow space for misses)
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    heightFactor: 0.7,
                    child: strategy is KyudoStrategy
                        ? CustomPaint(
                            painter: KyudoTargetPainter(),
                          )
                        : Image.asset(
                            strategy.targetImageAssets,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
                
                // Overlay Shots (Pins)
                ...shots.map((shot) {
                  return Positioned(
                    left: shot.offset.dx * size.width - 20,
                    top: shot.offset.dy * size.height - 20,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () {
                        if (onShotLongPressed != null) {
                          onShotLongPressed!(shot);
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(10), // Increase hit area
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (shots.indexOf(shot) + 1).toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                             ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              ],
            ),
          );
        },
      ),
    );
  }
}
