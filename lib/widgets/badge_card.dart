import 'package:flutter/material.dart';

import '../models/badge.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({super.key, required this.badge, required this.earned});

  final FinderBadge badge;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final color = earned ? badge.color : const Color(0xFF8C96AA);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: earned ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                earned ? badge.icon : Icons.lock_rounded,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      color: earned ? const Color(0xFF24304F) : color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
