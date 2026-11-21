import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/neumorphic_theme.dart';

/// Pílula de navegação inferior do protótipo.
/// Barra convexa com um hexágono central (aba principal) e ações laterais.
class NeuNavPill extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const NeuNavPill({
    super.key,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicPill(
      height: 78,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _PillAction(
            icon: Icons.public,
            selected: index == 1,
            onTap: () => onChanged(1),
          ),
          _PillAction(
            icon: Icons.water_drop,
            selected: index == 2,
            onTap: () => onChanged(2),
          ),
          _HexCore(
            selected: index == 0,
            onTap: () => onChanged(0),
          ),
          _PillAction(
            icon: Icons.language,
            selected: index == 3,
            onTap: () => onChanged(3),
          ),
          _PillAction(
            icon: Icons.tune,
            selected: index == 4,
            onTap: () => onChanged(4),
          ),
        ],
      ),
    );
  }
}

/// Container em formato de pílula (convexo), usado pela navegação.
class NeumorphicPill extends StatelessWidget {
  final Widget child;
  final double height;

  const NeumorphicPill({
    super.key,
    required this.child,
    this.height = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: NeuColors.surface,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: neuShadows(convex: true, depth: 8),
      ),
      child: child,
    );
  }
}

class _PillAction extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PillAction({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 50,
        height: 52,
        child: Icon(
          icon,
          size: 23,
          color: selected ? NeuColors.accent : NeuColors.textMuted,
        ),
      ),
    );
  }
}

/// Hexágono central embutido na pílula (estado ativo em destaque).
class _HexCore extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _HexCore({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 54,
        height: 60,
        child: CustomPaint(
          painter: _HexCorePainterColor(active: selected),
          child: Center(
            child: Icon(
              Icons.headphones,
              size: 23,
              color: selected ? NeuColors.background : NeuColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _HexCorePainterColor extends CustomPainter {
  final bool active;

  _HexCorePainterColor({required this.active});

  Path _path(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final p = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path(size);
    canvas.drawShadow(path, NeuColors.darkShadow, 6, false);
    canvas.drawPath(
      path,
      Paint()
        ..color = active ? NeuColors.accent : NeuColors.surface
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = active ? NeuColors.accent : NeuColors.lightShadow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _HexCorePainterColor oldDelegate) =>
      oldDelegate.active != active;
}

/// Botão quadrado com ícone de grade (2x2) do topo do protótipo.
class NeuGridButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;

  const NeuGridButton({super.key, this.onTap, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: NeuColors.surface,
          borderRadius: BorderRadius.circular(size * 0.32),
          boxShadow: neuShadows(convex: true, depth: 5),
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var row = 0; row < 2; row++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var col = 0; col < 2; col++)
                      Container(
                        width: size * 0.17,
                        height: size * 0.17,
                        decoration: BoxDecoration(
                          color: NeuColors.textSecondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
