import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';

class StarCounter extends StatelessWidget {
  const StarCounter({super.key, this.large = false});

  final bool large;

  @override
  Widget build(BuildContext context) {
    final stars = context.select<ProgressService, int>(
      (service) => service.stars,
    );

    return Semantics(
      label: '$stars stars earned',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? 18 : 14,
          vertical: large ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2B8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFC857), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              color: const Color(0xFFFFB000),
              size: large ? 36 : 28,
            ),
            const SizedBox(width: 6),
            Text(
              '$stars',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: large ? 28 : 20,
                color: const Color(0xFF24304F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
