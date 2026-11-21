import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/neumorphic_theme.dart';
import 'land_mask.dart';

/// Ponto projetado do globo (visível ou não).
class GlobeProjection {
  final Offset position;
  final bool visible;
  final double depth; // 1 = centro do globo, 0 = borda

  const GlobeProjection(this.position, this.visible, this.depth);
}

/// Projeção ortográfica: converte lat/lon em coordenadas de tela,
/// dada a rotação atual (lat0, lon0) do globo.
class GlobeMath {
  /// Projeta (lat, lon) no plano do globo de raio [radius] centrado em [center].
  static GlobeProjection project(
    double lat,
    double lon,
    double lat0,
    double lon0,
    Offset center,
    double radius,
  ) {
    const deg = math.pi / 180.0;
    final phi = lat * deg;
    final lambda = (lon - lon0) * deg;
    final phi0 = lat0 * deg;

    final cosPhi = math.cos(phi);
    final sinPhi = math.sin(phi);
    final cosPhi0 = math.cos(phi0);
    final sinPhi0 = math.sin(phi0);

    final x = cosPhi * math.sin(lambda);
    final y = cosPhi0 * sinPhi - sinPhi0 * cosPhi * math.cos(lambda);
    final z = sinPhi0 * sinPhi + cosPhi0 * cosPhi * math.cos(lambda);

    final position = Offset(
      center.dx + radius * x,
      center.dy - radius * y,
    );
    return GlobeProjection(position, z > 0, z.clamp(0.0, 1.0));
  }

  /// Ordena estações por profundidade (frente primeiro no desenho).
  static List<T> sortByDepth<T>(
    Iterable<T> items,
    double Function(T) lat,
    double Function(T) lon,
    double lat0,
    double lon0,
  ) {
    final list = items.toList();
    list.sort((a, b) {
      final pa = project(lat(a), lon(a), lat0, lon0, Offset.zero, 1).depth;
      final pb = project(lat(b), lon(b), lat0, lon0, Offset.zero, 1).depth;
      return pa.compareTo(pb);
    });
    return list;
  }
}

/// Globo em meio-tom (dots) inspirado no protótipo:
/// - pontos no oceano, continentes vazios (máscara de terra real);
/// - pontos maiores perto do observador (efeito de volume);
/// - pontos de estações em destaque (clicáveis).
class GlobePainter extends CustomPainter {
  final double lat0;
  final double lon0;
  final Color dotColor;
  final Color oceanColor;
  final double dotStep; // passo em graus
  final double radius;

  GlobePainter({
    required this.lat0,
    required this.lon0,
    required this.radius,
    this.dotColor = const Color(0xFFB9BEC6),
    this.oceanColor = const Color(0xFF000000),
    this.dotStep = 2.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = radius;
    final circle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: r));

    // Disco do oceano (preto, como no protótipo)
    canvas.drawPath(
      circle,
      Paint()
        ..shader = RadialGradient(
          colors: [
            oceanColor.withOpacity(0.98),
            oceanColor.withOpacity(0.90),
            oceanColor,
          ],
          stops: const [0.0, 0.75, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    canvas.save();
    // Pontos de meio-tom: metade frontal apenas
    final paint = Paint()..style = PaintingStyle.fill;

    final latStep = dotStep;
    final lonStep = dotStep;

    for (double lat = -78; lat <= 78; lat += latStep) {
      // densidade maior perto do equador (evita aglomerar nos polos)
      final cosLat = math.cos(lat * math.pi / 180.0);
      final effectiveLonStep = lonStep / math.max(cosLat, 0.18);

      for (double lon = -180; lon < 180; lon += effectiveLonStep) {
        final p = GlobeMath.project(lat, lon, lat0, lon0, center, r);
        if (!p.visible) continue;

        final isLand = LandMask.isLand(lat, lon);
        // Oceanos recebem pontos; continentes ficam vazios (protótipo)
        if (isLand) continue;

        final depth = p.depth;
        final dotRadius = 0.355 + 0.72 * depth * depth;
        final alpha = 0.20 + 0.80 * math.pow(depth, 1.35).toDouble();
        paint.color = dotColor.withOpacity(alpha.clamp(0.0, 0.95));

        // micro-elipse (perspectiva): pontos "achatados" na borda
        final flatten = 0.55 + 0.45 * depth;
        canvas.save();
        canvas.translate(p.position.dx, p.position.dy);
        canvas.scale(1.0, flatten);
        canvas.drawCircle(Offset.zero, dotRadius, paint);
        canvas.restore();
      }
    }

    canvas.restore();

    // Borda sutil do globo
    canvas.drawPath(
      circle,
      Paint()
        ..color = const Color(0xFF2A2E35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant GlobePainter old) =>
      old.lat0 != lat0 ||
      old.lon0 != lon0 ||
      old.radius != radius ||
      old.dotStep != dotStep;
}

/// Anel externo de sombra (efeito de esfera flutuando no escuro).
class GlobeHaloPainter extends CustomPainter {
  final double radius;

  GlobeHaloPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius * 1.02);
    canvas.drawCircle(
      center,
      radius * 1.06,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            NeuColors.background.withOpacity(0.55),
            NeuColors.background.withOpacity(0.0),
          ],
          stops: const [0.72, 0.94, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant GlobeHaloPainter old) => old.radius != radius;
}
