import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';

class SpiritualBackground extends StatelessWidget {
  final Widget child;
  const SpiritualBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Deep Cosmic Purple/Maroon Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [
                 Color(0xFF2D0D22), // Rich Maroon
                 Color(0xFF1A0A2E), // Deep Cosmic Purple
                 Color(0xFF040412), // Deep Space Navy
              ],
            ),
          ),
        ),
        
        // 2. Large Etched Mandala Patterns (Corner focused)
        Positioned.fill(
          child: Opacity(
            opacity: 0.08,
            child: CustomPaint(
              painter: MandalaPatternPainter(),
            ),
          ),
        ),
        
        // 3. The Actual Content
        child,
      ],
    );
  }
}

class MandalaPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw large mandalas in corners
    _drawMandala(canvas, 0, 0, size.width * 0.6, paint);
    _drawMandala(canvas, size.width, 0, size.width * 0.4, paint);
    _drawMandala(canvas, 0, size.height, size.width * 0.5, paint);
    _drawMandala(canvas, size.width, size.height, size.width * 0.7, paint);
  }

  void _drawMandala(Canvas canvas, double x, double y, double radius, Paint paint) {
    final center = Offset(x, y);
    
    // Draw circles
    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * (i / 3), paint);
    }

    // Draw petals/lines
    const petals = 12;
    for (var i = 0; i < petals; i++) {
      final angle = (i * 2 * math.pi) / petals;
      final start = Offset(
        center.dx + math.cos(angle) * (radius * 0.2),
        center.dy + math.sin(angle) * (radius * 0.2),
      );
      final end = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawLine(start, end, paint);
      
      // Draw small arcs/loops
      final path = Path();
      final loopCenter = Offset(
        center.dx + math.cos(angle) * (radius * 0.6),
        center.dy + math.sin(angle) * (radius * 0.6),
      );
      path.addOval(Rect.fromCircle(center: loopCenter, radius: radius * 0.1));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
