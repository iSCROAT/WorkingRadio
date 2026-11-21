import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/neumorphic_theme.dart';

/// Hexágono neumórfico do protótipo — sombra dupla (clara/escura)
/// para efeito elevado, com borda em destaque.
class NeumorphicHexagon extends StatelessWidget {
  final double size;
  final Widget child;

  const NeumorphicHexagon({
    super.key,
    this.size = 300,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexagonPainter(),
        child: Center(child: child),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  Path _hexagonPath(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * math.pi / 180;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _hexagonPath(size);

    // Sombra clara (canto superior esquerdo)
    canvas.drawShadow(
      path.shift(const Offset(-7, -7)),
      NeuColors.lightShadow,
      10,
      false,
    );
    // Sombra escura (canto inferior direito)
    canvas.drawShadow(
      path.shift(const Offset(7, 7)),
      NeuColors.darkShadow,
      10,
      false,
    );

    // Preenchimento com gradiente radial sutil
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          NeuColors.surface,
          NeuColors.surface.withOpacity(0.55),
        ],
        center: Alignment.center,
        radius: 0.9,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(path, fillPaint);

    // Borda fina em destaque
    final borderPaint = Paint()
      ..color = NeuColors.accent.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
