import 'package:flutter/material.dart';

class ExplorerItem {
  const ExplorerItem({
    required this.id,
    required this.fallbackLabel,
    required this.icon,
    required this.color,
  });

  final String id;
  final String fallbackLabel;
  final IconData icon;
  final Color color;
}
