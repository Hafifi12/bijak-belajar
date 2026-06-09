import 'package:flutter/material.dart';

enum BadgeCondition {
  completedChallenges,
  totalStars,
  streak,
  level,
  moduleComplete,
}

class FinderBadge {
  const FinderBadge({
    required this.id,
    required this.title,
    required this.titleMalay,
    required this.description,
    required this.descriptionMalay,
    required this.condition,
    required this.requiredCount,
    required this.icon,
    required this.color,
    this.moduleId,
  });

  final String id;
  final String title;
  final String titleMalay;
  final String description;
  final String descriptionMalay;
  final BadgeCondition condition;
  final int requiredCount;
  final String? moduleId;
  final IconData icon;
  final Color color;
}
