import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const _ink = Color(0xFF24304F);
  static const _cream = Color(0xFFFFFAF0);
  static const _sky = Color(0xFF36A9E1);
  static const _coral = Color(0xFFFF7058);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _sky,
      brightness: Brightness.light,
      primary: _sky,
      secondary: _coral,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _cream,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: _cream,
        foregroundColor: _ink,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(88, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: Color(0xFFB5C3DE), width: 2),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: _ink,
          fontSize: 36,
          fontWeight: FontWeight.w900,
          height: 1.04,
        ),
        headlineMedium: TextStyle(
          color: _ink,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          height: 1.08,
        ),
        titleLarge: TextStyle(
          color: _ink,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
        bodyLarge: TextStyle(
          color: _ink,
          fontSize: 18,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: _ink, fontSize: 15, height: 1.4),
      ),
    );
  }
}
