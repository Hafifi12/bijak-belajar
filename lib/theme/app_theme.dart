import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  // ── Palette ────────────────────────────────────────────────────
  static const skyBlue = Color(0xFF1EA7FF);
  static const deepBlue = Color(0xFF0648D9);
  static const turquoise = Color(0xFF00C9A7);
  static const sunnyYellow = Color(0xFFFFD21E);
  static const appleRed = Color(0xFFFF4D4F);
  static const leafGreen = Color(0xFF34C759);
  static const purple = Color(0xFF7A5CFF);
  static const cream = Color(0xFFFFF7E8);
  static const lightBlue = Color(0xFFE9F8FF);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF05358F);

  static const primary = deepBlue;
  static const secondary = appleRed;
  static const accent = sunnyYellow;
  static const teal = turquoise;
  static const bg = lightBlue;

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
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: deepBlue.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 56),
          backgroundColor: sunnyYellow,
          foregroundColor: ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: ink,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          height: 1.08,
        ),
        headlineMedium: TextStyle(
          color: ink,
          fontSize: 25,
          fontWeight: FontWeight.w900,
          height: 1.1,
        ),
        titleLarge: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        titleMedium: TextStyle(
          color: primary,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
        bodyLarge: TextStyle(
          color: ink,
          fontSize: 16,
          height: 1.36,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF5E6FA3),
          fontSize: 13,
          height: 1.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
