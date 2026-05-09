import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class StarCounter extends StatelessWidget {
  const StarCounter({super.key, this.large = false});

  final bool large;

  @override
  Widget build(BuildContext context) {
    final stars = context.select<ProgressService, int>((s) => s.stars);

    return Semantics(
      label: '$stars stars earned',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? 16 : 12,
          vertical: large ? 10 : 7,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.sunnyYellow, Color(0xFFFFA51F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white, width: large ? 3 : 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.sunnyYellow.withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⭐', style: TextStyle(fontSize: large ? 26 : 20)),
            const SizedBox(width: 6),
            Text(
              '$stars',
              style: TextStyle(
                fontSize: large ? 24 : 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.ink,
                shadows: [
                  Shadow(
                    color: Colors.white,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
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
