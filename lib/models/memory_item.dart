import 'package:flutter/material.dart';

import 'challenge.dart';

enum MemoryCategory { animals, shapes, colors }

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
        return 10;
    }
  }

  int get totalCards => gridSize * gridSize;

  int get pairCount => totalCards ~/ 2;

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

  String label({required bool isMalay}) {
    switch (this) {
      case MemoryStage.easy:
        return isMalay ? 'Mudah' : 'Easy';
      case MemoryStage.normal:
        return isMalay ? 'Biasa' : 'Normal';
      case MemoryStage.medium:
        return isMalay ? 'Sederhana' : 'Medium';
      case MemoryStage.high:
        return isMalay ? 'Tinggi' : 'High';
    }
  }

  String boardLabel({required bool isMalay}) {
    return '${gridSize}x$gridSize ${label(isMalay: isMalay)}';
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
