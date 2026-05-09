import 'package:flutter/material.dart';

class ExplorerItem {
  const ExplorerItem({
    required this.id,
    required this.fallbackLabel,
    required this.icon,
    required this.color,
    this.emoji,
  });

  final String id;
  final String fallbackLabel;
  final IconData icon;
  final Color color;
  /// If set, this emoji is shown instead of the Material icon.
  final String? emoji;
}
