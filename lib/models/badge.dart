import 'package:flutter/material.dart';

class FinderBadge {
  const FinderBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredChallenges,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final int requiredChallenges;
  final IconData icon;
  final Color color;
}
