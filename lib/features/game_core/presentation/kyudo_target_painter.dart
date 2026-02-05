import 'package:flutter/material.dart';

class KyudoTargetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Standard Kyudo Target (Kasumi-mato) Dimensions (Radius 36cm diameter)
    // 1. Outer Black (Soto-guro): 3.3cm width -> R range: 14.7cm to 18.0cm
    // 2. Third White (San-no-shiro): 3.0cm width -> R range: 11.7cm to 14.7cm
    // 3. Second Black (Ni-no-kuro): 1.5cm width -> R range: 10.2cm to 11.7cm
    // 4. Second White (Ni-no-shiro): 3.0cm width -> R range: 7.2cm to 10.2cm
    // 5. First Black (Ichi-no-kuro): 3.6cm width -> R range: 3.6cm to 7.2cm
    // 6. Center White (Naka-shiro): 3.6cm width -> R range: 0.0cm to 3.6cm
    
    // Ratios relative to max radius (18.0)
    const double rMax = 18.0;
    
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Draw Outer Black Base (covers everything, acts as the outer ring)
    paint.color = Colors.black;
    canvas.drawCircle(center, radius, paint);

    // 2. Third White
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * (14.7 / rMax), paint);

    // 3. Second Black
    paint.color = Colors.black;
    canvas.drawCircle(center, radius * (11.7 / rMax), paint);

    // 4. Second White
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * (10.2 / rMax), paint);

    // 5. First Black
    paint.color = Colors.black;
    canvas.drawCircle(center, radius * (7.2 / rMax), paint);

    // 6. Center White
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * (3.6 / rMax), paint);
    
    // Optional: Draw a thin outline for valid hit area if needed, 
    // but typically the target itself is the boundary.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
