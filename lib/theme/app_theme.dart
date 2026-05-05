import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  // ── Palette ────────────────────────────────────────────────────
  static const primary   = Color(0xFF7C4DFF); // vibrant purple
  static const secondary = Color(0xFFFF6B6B); // coral red
  static const accent    = Color(0xFFFFD93D); // sunny yellow
  static const teal      = Color(0xFF1DD1A1); // fresh teal
  static const bg        = Color(0xFFF8F0FF); // soft lavender white
  static const ink       = Color(0xFF2D1B69); // deep purple ink

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: ink,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: ink, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1,
        ),
        headlineMedium: TextStyle(
          color: ink, fontSize: 26, fontWeight: FontWeight.w900, height: 1.1,
        ),
        titleLarge: TextStyle(
          color: ink, fontSize: 20, fontWeight: FontWeight.w900,
        ),
        titleMedium: TextStyle(
          color: primary, fontSize: 14, fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
        bodyLarge: TextStyle(
          color: ink, fontSize: 16, height: 1.4, fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: Color(0xFF7B7B9D), fontSize: 13, height: 1.4,
          fontWeight: FontWeight.w600),
      ),
    );
  }
}
