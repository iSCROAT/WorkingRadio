import 'package:flutter/material.dart';
import '../theme/neumorphic_theme.dart';

/// Container neumórfico — convexo (elevado) ou côncavo (pressionado).
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool convex;
  final EdgeInsetsGeometry padding;
  final double depth;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.convex = true,
    this.padding = const EdgeInsets.all(16),
    this.depth = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: NeuColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: neuShadows(convex: convex, depth: depth),
      ),
      child: child,
    );
  }
}

/// Botão neumórfico circular com ícone em relevo.
/// Pressionar alterna para o estado côncavo (efeito físico).
class NeumorphicButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? iconColor;
  final bool active;

  const NeumorphicButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 64,
    this.iconColor,
    this.active = false,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final convex = !_pressed;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: NeuColors.surface,
          shape: BoxShape.circle,
          boxShadow: neuShadows(convex: convex, depth: 6),
        ),
        child: Icon(
          widget.icon,
          size: widget.size * 0.42,
          color: widget.active
              ? NeuColors.accent
              : (widget.iconColor ?? NeuColors.textSecondary),
        ),
      ),
    );
  }
}

/// Card neumórfico elevado para exibição de conteúdo.
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: borderRadius,
      padding: padding,
      child: child,
    );
  }
}

/// Slider neumórfico — trilha côncava + polegar convexo.
class NeumorphicSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const NeumorphicSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final dx = details.localPosition.dx.clamp(0.0, width);
            onChanged(dx / width);
          },
          onHorizontalDragUpdate: (details) {
            final dx = details.localPosition.dx.clamp(0.0, width);
            onChanged(dx / width);
          },
          child: SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Trilha côncava
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: NeuColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: neuShadows(convex: false, depth: 4),
                  ),
                ),
                // Preenchimento
                FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0).toDouble(),
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: NeuColors.accent.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // Polegar convexo
                Positioned(
                  left: value.clamp(0.0, 1.0).toDouble() * (width - 28),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: NeuColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: neuShadows(convex: true, depth: 4),
                    ),
                    child: const Icon(Icons.volume_up,
                        size: 15, color: NeuColors.accent),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Interruptor neumórfico — trilha côncava + botão convexo.
class NeumorphicToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NeumorphicToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 64,
        height: 34,
        decoration: BoxDecoration(
          color: NeuColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: neuShadows(convex: false, depth: 5),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: value ? NeuColors.accent : NeuColors.surface,
              shape: BoxShape.circle,
              boxShadow: neuShadows(convex: true, depth: 3),
            ),
            child: Icon(
              value ? Icons.check : Icons.close,
              size: 15,
              color: NeuColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo de entrada com aparência física (côncavo).
class NeumorphicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const NeumorphicTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: NeuColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: neuShadows(convex: false, depth: 6),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: NeuColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: NeuColors.textMuted, fontSize: 13),
          prefixIcon: Icon(icon, color: NeuColors.accent, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
