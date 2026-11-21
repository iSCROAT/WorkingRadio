import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/neumorphic_theme.dart';

/// Pílula de navegação inferior do protótipo.
/// Barra convexa com um hexágono central (embutido) e ações laterais.
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
      height: 76,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _PillAction(
            icon: Icons.tune,
            selected: index == 2,
            onTap: () => onChanged(2),
          ),
          _HexCore(
            selected: index == 0,
            onTap: () => onChanged(0),
          ),
          _PillAction(
            icon: Icons.graphic_eq,
            selected: index == 1,
            onTap: () => onChanged(1),
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
      padding: const EdgeInsets.symmetric(horizontal: 26),
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
        width: 52,
        height: 52,
        child: Icon(
          icon,
          size: 24,
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
        width: 52,
        height: 56,
        child: CustomPaint(
          painter: _HexCorePainter(active: selected),
          child: Center(
            child: Icon(
              Icons.headphones,
              size: 22,
              color: selected ? NeuColors.textPrimary : NeuColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _HexCorePainter extends CustomPainter {
  final bool active;

  _HexCorePainter({required this.active});

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
  bool shouldRepaint(covariant _HexCorePainter oldDelegate) =>
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
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: size * 0.08,
            crossAxisSpacing: size * 0.08,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              4,
              (_) => Container(
                decoration: BoxDecoration(
                  color: NeuColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
