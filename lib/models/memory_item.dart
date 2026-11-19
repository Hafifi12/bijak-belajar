import 'package:flutter/material.dart';

import 'challenge.dart';
import 'app_language.dart';

enum MemoryCategory { animals, shapes, colors, jawi }

enum MemoryStage { easy, normal, medium, high }

extension MemoryStageDetails on MemoryStage {
  int get gridSize {
    switch (this) {
      case MemoryStage.easy:
        return 3;
      case MemoryStage.normal:
        return 4;
      case MemoryStage.medium:
        return 5;
      case MemoryStage.high:
        return 6;
    }
  }

  int get totalCards => gridSize * gridSize;

  int get pairCount => totalCards ~/ 2;

  /// Star payout — bigger boards pay more so difficulty is worth choosing.
  int get starReward {
    switch (this) {
      case MemoryStage.easy:
        return 1;
      case MemoryStage.normal:
        return 1;
      case MemoryStage.medium:
        return 2;
      case MemoryStage.high:
        return 3;
    }
  }

  bool get hasBonusCard => totalCards.isOdd;

  Duration get previewDuration {
    switch (this) {
      case MemoryStage.easy:
        return const Duration(seconds: 4);
      case MemoryStage.normal:
        return const Duration(seconds: 5);
      case MemoryStage.medium:
        return const Duration(seconds: 7);
      case MemoryStage.high:
        return const Duration(seconds: 12);
    }
  }

  String label({required AppLanguage language}) {
    switch (this) {
      case MemoryStage.easy:
        return language.copy(ms: 'Mudah', en: 'Easy', zh: '简单', ta: 'எளிது');
      case MemoryStage.normal:
        return language.copy(ms: 'Biasa', en: 'Normal', zh: '普通', ta: 'சாதாரணம்');
      case MemoryStage.medium:
        return language.copy(ms: 'Sederhana', en: 'Medium', zh: '中等', ta: 'நடுத்தரம்');
      case MemoryStage.high:
        return language.copy(ms: 'Tinggi', en: 'High', zh: '高', ta: 'அதிகம்');
    }
  }

  String boardLabel({required AppLanguage language}) {
    return '${gridSize}x$gridSize ${label(language: language)}';
  }
}

extension MemoryCategoryDetails on MemoryCategory {
  String get title {
    switch (this) {
      case MemoryCategory.animals:
        return 'Animal Memory';
      case MemoryCategory.shapes:
        return 'Shape Memory';
      case MemoryCategory.colors:
        return 'Color Memory';
      case MemoryCategory.jawi:
        return 'Jawi Memory';
    }
  }

  String get shortTitle {
    switch (this) {
      case MemoryCategory.animals:
        return 'Animals';
      case MemoryCategory.shapes:
        return 'Shapes';
      case MemoryCategory.colors:
        return 'Colors';
      case MemoryCategory.jawi:
        return 'Jawi';
    }
  }

  String get subtitle {
    switch (this) {
      case MemoryCategory.animals:
        return 'Match animal pairs';
      case MemoryCategory.shapes:
        return 'Match shape pairs';
      case MemoryCategory.colors:
        return 'Match color pairs';
      case MemoryCategory.jawi:
        return 'Match Jawi letter pairs';
    }
  }

  IconData get icon {
    switch (this) {
      case MemoryCategory.animals:
        return Icons.pets_rounded;
      case MemoryCategory.shapes:
        return Icons.category_rounded;
      case MemoryCategory.colors:
        return Icons.palette_rounded;
      case MemoryCategory.jawi:
        return Icons.nightlight_round;
    }
  }

  Color get color {
    switch (this) {
      case MemoryCategory.animals:
        return const Color(0xFF7E57C2);
      case MemoryCategory.shapes:
        return const Color(0xFF00A896);
      case MemoryCategory.colors:
        return const Color(0xFFFF7058);
      case MemoryCategory.jawi:
        // Matches the Jawi module identity color (AppTheme.moduleJawi).
        return const Color(0xFF00B894);
    }
  }
}

class MemoryItem {
  const MemoryItem({
    required this.id,
    required this.label,
    this.icon,
    this.symbol,
    this.displayColor,
    this.shapeKind,
  });

  final String id;
  final String label;
  final IconData? icon;
  final String? symbol;
  final Color? displayColor;
  final ShapeKind? shapeKind;
}
