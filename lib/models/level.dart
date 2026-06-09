import 'package:flutter/material.dart';

class AppLevel {
  const AppLevel({
    required this.level,
    required this.title,
    required this.titleMalay,
    required this.emoji,
    required this.minStars,
    required this.maxStars,
    required this.color,
  });

  final int level;
  final String title;
  final String titleMalay;
  final String emoji;
  final int minStars;
  final int maxStars; // -1 = max level

  final Color color;

  double progressFraction(int stars) {
    if (maxStars < 0) return 1.0;
    final range = maxStars - minStars;
    if (range <= 0) return 1.0;
    return ((stars - minStars) / range).clamp(0.0, 1.0);
  }

  int starsToNext(int stars) {
    if (maxStars < 0) return 0;
    return (maxStars - stars).clamp(0, maxStars - minStars);
  }
}

const List<AppLevel> appLevels = [
  AppLevel(level: 1, title: 'Tiny Learner', titleMalay: 'Pelajar Cilik', emoji: '🌱', minStars: 0, maxStars: 9, color: Color(0xFF34C759)),
  AppLevel(level: 2, title: 'Little Explorer', titleMalay: 'Penjelajah Kecil', emoji: '🐣', minStars: 10, maxStars: 24, color: Color(0xFF48DBFB)),
  AppLevel(level: 3, title: 'Star Finder', titleMalay: 'Pencari Bintang', emoji: '⭐', minStars: 25, maxStars: 49, color: Color(0xFFFFD21E)),
  AppLevel(level: 4, title: 'Smart Scholar', titleMalay: 'Sarjana Bijak', emoji: '📚', minStars: 50, maxStars: 84, color: Color(0xFF1EA7FF)),
  AppLevel(level: 5, title: 'Bright Champion', titleMalay: 'Juara Cerah', emoji: '🏆', minStars: 85, maxStars: 129, color: Color(0xFFFF9F43)),
  AppLevel(level: 6, title: 'Wise Wizard', titleMalay: 'Ahli Sihir Bijak', emoji: '🧙', minStars: 130, maxStars: 184, color: Color(0xFF7C4DFF)),
  AppLevel(level: 7, title: 'Super Star', titleMalay: 'Bintang Super', emoji: '🌟', minStars: 185, maxStars: 249, color: Color(0xFFFF6B6B)),
  AppLevel(level: 8, title: 'Knowledge Hero', titleMalay: 'Wira Ilmu', emoji: '🦸', minStars: 250, maxStars: 324, color: Color(0xFF00C9A7)),
  AppLevel(level: 9, title: 'Learning Legend', titleMalay: 'Legenda Belajar', emoji: '🔮', minStars: 325, maxStars: 409, color: Color(0xFFE84393)),
  AppLevel(level: 10, title: 'Master Explorer', titleMalay: 'Penjelajah Master', emoji: '👑', minStars: 410, maxStars: -1, color: Color(0xFFFFD700)),
];

AppLevel levelForStars(int stars) {
  for (int i = appLevels.length - 1; i >= 0; i--) {
    if (stars >= appLevels[i].minStars) return appLevels[i];
  }
  return appLevels.first;
}