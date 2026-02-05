import 'dart:ui';
import 'package:flutter/material.dart';
import '../domain/base_game_strategy.dart';

class HeatmapTargetWidget extends StatelessWidget {
  final BaseGameStrategy strategy;
  final List<Offset> shotPositions; // Relative (0.0 to 1.0)
  final double gridSize;

  const HeatmapTargetWidget({
    super.key,
    required this.strategy,
    required this.shotPositions,
    this.gridSize = 40, 
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          
          return Stack(
            children: [
              // 1. Target Image Base
              Center(
                child: Image.asset(
                  strategy.targetImageAssets,
                  fit: BoxFit.contain,
                ),
              ),
              
              // 2. Heatmap Layer
              ClipRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: CustomPaint(
                    size: size,
                    painter: HeatmapPainter(
                      shotPositions: shotPositions,
                      gridCount: 30, // Increased for better granularity
                    ),
                  ),
                ),
              ),

              // 3. Sharp Target Lines (Like soccer pitch lines)
              IgnorePointer(
                child: CustomPaint(
                  size: size,
                  painter: TargetLinesPainter(),
                ),
              ),
              
              // 4. Subtle indicators for individual shots
              ...shotPositions.map((pos) => Positioned(
                left: pos.dx * size.width - 1.0,
                top: pos.dy * size.height - 1.0,
                child: Container(
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

class TargetLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width / 2) * 0.7; // 70% padding built-in to new image

    // Draw Kyudo rings (Kasumi-mato ratios)
    // 3.6cm, 7.2cm, 10.2cm, 11.7cm, 14.7cm, 18.0cm
    // Ratios: 0.2, 0.4, 0.566, 0.65, 0.816, 1.0
    final ratios = [0.2, 0.4, 0.566, 0.65, 0.816, 1.0];
    
    for (final ratio in ratios) {
      canvas.drawCircle(center, maxRadius * ratio, paint);
    }
    
    // Crosshair (optional for Kyudo, but helpful for UI)
    // canvas.drawLine(Offset(center.dx - 10, center.dy), Offset(center.dx + 10, center.dy), paint);
    // canvas.drawLine(Offset(center.dx, center.dy - 10), Offset(center.dx, center.dy + 10), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



class HeatmapPainter extends CustomPainter {
  final List<Offset> shotPositions;
  final int gridCount;

  HeatmapPainter({required this.shotPositions, required this.gridCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (shotPositions.isEmpty) return;

    final cellWidth = size.width / gridCount;
    final cellHeight = size.height / gridCount;
    
    // Calculate density
    final density = List.generate(gridCount, (_) => List.filled(gridCount, 0));
    int maxDensity = 0;

    for (final pos in shotPositions) {
      final col = (pos.dx * gridCount).floor().clamp(0, gridCount - 1);
      final row = (pos.dy * gridCount).floor().clamp(0, gridCount - 1);
      density[row][col]++;
      if (density[row][col] > maxDensity) maxDensity = density[row][col];
    }

    if (maxDensity == 0) return;

    // Use a slightly larger radius for smooth blending between points
    final double radius = cellWidth * 4.0; 

    for (int r = 0; r < gridCount; r++) {
      for (int c = 0; c < gridCount; c++) {
        final count = density[r][c];
        if (count == 0) continue;

        final normalized = count / maxDensity;
        // Non-linear mapping to emphasize the "Red" areas more sharply
        final intensityValue = normalized * normalized; 
        
        final center = Offset(
          c * cellWidth + cellWidth / 2,
          r * cellHeight + cellHeight / 2,
        );

        final color = _getHeatColor(normalized);
        
        final paint = Paint()
          ..shader = RadialGradient(
            colors: [
              color,
              color.withOpacity(0),
            ],
            stops: const [0.1, 1.0], // Sharper core focus
          ).createShader(Rect.fromCircle(center: center, radius: radius));
        
        // Use BlendMode.plus or similar to accumulate heat naturally if needed
        // but for now simple draw is okay with well-tuned colors
        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  Color _getHeatColor(double value) {
    // Highly vivid palette to ensure visibility even through the target image
    // Blue/Cyan fringe -> Green -> Yellow -> Orange -> Deep Red
    if (value < 0.1) return const Color(0xFF00FFFF).withOpacity(0.1); // Cyan fringe
    if (value < 0.3) return Color.lerp(const Color(0xFF00FF00), const Color(0xFFADFF2F), (value - 0.1) / 0.2)!.withOpacity(0.3); // Green -> Lime
    if (value < 0.5) return Color.lerp(const Color(0xFFFFFF00), const Color(0xFFFFD700), (value - 0.3) / 0.2)!.withOpacity(0.6); // Yellow -> Golden
    if (value < 0.8) return Color.lerp(const Color(0xFFFFA500), const Color(0xFFFF4500), (value - 0.5) / 0.3)!.withOpacity(0.8); // Orange -> OrangeRed
    return Color.lerp(const Color(0xFFFF0000), const Color(0xFF8B0000), (value - 0.8) / 0.2)!.withOpacity(1.0); // Red -> DarkRed
  }





  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) => 
      oldDelegate.shotPositions != shotPositions;
}
