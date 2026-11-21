import 'package:flutter/material.dart';

/// Tokens do Neumorfismo Dark — Working Radio v2.
/// A superfície e os elementos compartilham a mesma cor base;
/// a profundidade vem das sombras duplas (clara / escura).
class NeuColors {
  static const Color background = Color(0xFF14161A);
  static const Color surface = Color(0xFF14161A);
  static const Color lightShadow = Color(0xFF2B2E35);
  static const Color darkShadow = Color(0xFF0A0B0D);
  static const Color accent = Color(0xFFFF3B5C);
  static const Color accentSoft = Color(0xFFFF6B85);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8D93);
  static const Color textMuted = Color(0xFF5C5F66);
  static const Color success = Color(0xFF34C759);
}

/// Sombras neumórficas: convexa (elevada) ou côncava (pressionada).
List<BoxShadow> neuShadows({bool convex = true, double depth = 8}) {
  if (convex) {
    return [
      BoxShadow(
        color: NeuColors.lightShadow,
        offset: Offset(-depth, -depth),
        blurRadius: depth * 1.6,
      ),
      BoxShadow(
        color: NeuColors.darkShadow,
        offset: Offset(depth, depth),
        blurRadius: depth * 1.6,
      ),
    ];
  }
  return [
    BoxShadow(
      color: NeuColors.darkShadow,
      offset: Offset(depth * 0.6, depth * 0.6),
      blurRadius: depth,
      blurStyle: BlurStyle.inner,
    ),
    BoxShadow(
      color: NeuColors.lightShadow,
      offset: Offset(-depth * 0.6, -depth * 0.6),
      blurRadius: depth,
      blurStyle: BlurStyle.inner,
    ),
  ];
}

ThemeData buildNeuTheme() {
  return ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: NeuColors.background,
    colorScheme: const ColorScheme.dark(
      primary: NeuColors.accent,
      surface: NeuColors.surface,
      onSurface: NeuColors.textPrimary,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 64, fontWeight: FontWeight.w300),
      headlineMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
  );
}
