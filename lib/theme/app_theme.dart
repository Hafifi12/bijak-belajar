import 'package:flutter/material.dart';

/// Bijak Belajar design system.
///
/// Single source of truth for color, spacing, radius, type, and touch-target
/// tokens. Screens must consume these tokens instead of hardcoding values so
/// the app stays visually coherent — especially module identity colors, which
/// pre-readers (ages 3–7) rely on to navigate.
class AppTheme {
  const AppTheme._();

  // ── Core palette ───────────────────────────────────────────────
  static const skyBlue = Color(0xFF1EA7FF);
  static const deepBlue = Color(0xFF0648D9);
  static const turquoise = Color(0xFF00C9A7);
  static const sunnyYellow = Color(0xFFFFD21E);
  static const appleRed = Color(0xFFFF4D4F);
  static const leafGreen = Color(0xFF34C759);
  static const purple = Color(0xFF7A5CFF);
  static const orange = Color(0xFFFF9F43);
  static const pink = Color(0xFFE84393);
  static const cream = Color(0xFFFFF7E8);
  static const lightBlue = Color(0xFFE9F8FF);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF05358F);

  /// Secondary/body text on light surfaces.
  static const inkMuted = Color(0xFF5E6FA3);

  /// Tertiary text (hints, captions) on light surfaces.
  static const inkFaint = Color(0xFF7A7A9A);

  // ── Night-sky "Adventures" palette ─────────────────────────────
  // The app now lives inside a starry Malaysian adventure world. Content
  // sits on bright cards that float over a deep night gradient — so the
  // existing dark [ink] text on white cards stays fully legible, while the
  // world around it turns immersive and magical.
  static const nightTop = Color(0xFF1B1638);
  static const nightMid = Color(0xFF191A38);
  static const nightDeep = Color(0xFF12132B);
  static const nightBottom = Color(0xFF0F3460);

  /// Elevated dark surface (for panels that intentionally stay dark).
  static const nightSurface = Color(0xFF241F45);
  static const nightSurfaceHi = Color(0xFF2E2856);

  /// Signature violets + coral of the "Adventures" identity.
  static const violet = Color(0xFF6C5CE7);
  static const lilac = Color(0xFFA29BFE);
  static const coral = Color(0xFFFD79A8);
  static const gold = Color(0xFFFDCB6E);
  static const ember = Color(0xFFE17055);

  /// Text/foreground colors for content placed directly on the night sky.
  static const onNight = Color(0xFFF3F1FF);
  static const onNightMuted = Color(0xFFB9B4E0);
  static const onNightFaint = Color(0xFF8C86BC);

  static const primary = violet;
  static const secondary = coral;
  static const accent = sunnyYellow;
  static const teal = turquoise;
  static const bg = nightMid;

  // ── Signature gradients ────────────────────────────────────────
  static const auroraGradient = LinearGradient(
    colors: [violet, lilac, coral],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const nightGradient = LinearGradient(
    colors: [nightTop, nightMid, nightDeep],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Module identity colors (single source of truth) ────────────
  // The SAME color must represent a module on every screen — Home grid,
  // Learning Path, Continue banner, in-module app bars — because children
  // who can't read yet recognise modules by color + icon.
  static const moduleNumbers = Color(0xFFFF6B6B);
  static const moduleLetters = Color(0xFF1DD1A1);
  static const moduleJawi = Color(0xFF00B894);
  static const moduleBodyParts = Color(0xFFE84393);
  static const moduleMath = Color(0xFF6C5CE7);
  static const moduleColoring = Color(0xFFFF9F43);
  static const moduleGames = Color(0xFF7C4DFF);

  // ── Spacing scale ──────────────────────────────────────────────
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;

  // ── Radius scale ───────────────────────────────────────────────
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 28;

  // ── Touch targets ──────────────────────────────────────────────
  // 48dp is the adult Material minimum. Research on preschool motor
  // accuracy recommends notably larger targets, so anything a child is
  // expected to tap uses [kidTarget]+.
  static const double minTarget = 48;
  static const double kidTarget = 56;
  static const double kidTargetLarge = 64;

  // ── Type scale (kid-readable minimums) ─────────────────────────
  // Nothing interactive or instructional below 12. Captions only for
  // parent-facing metadata.
  static const double textCaption = 12;
  static const double textBody = 14;
  static const double textTitle = 16;
  static const double textHeading = 20;
  static const double textDisplay = 26;

  static ThemeData light() {
    // Kept as a light ColorScheme so the app's bright cards, dialogs, and
    // dark-on-white text render exactly as designed — the "night" is supplied
    // by the scene background + scaffold, not by inverting every surface.
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
      // App bars float over the night sky (or a saturated module color), so
      // their content is light.
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: onNight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: onNight),
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: onNight,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: deepBlue.withValues(alpha: 0.16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusXl)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, kidTarget),
          backgroundColor: sunnyYellow,
          foregroundColor: ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: const Size(88, kidTarget)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(minTarget, minTarget),
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
          color: inkMuted,
          fontSize: 14,
          height: 1.36,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
