import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Zara the owl — the app's companion tutor. A pulsing violet avatar beside a
/// glassy speech bubble that "asks" the child what to do, so a pre-reader hears
/// (and sees) the prompt before the answer. Drop this at the top of any lesson.
class ZaraPrompt extends StatefulWidget {
  const ZaraPrompt({super.key, required this.message, this.sub});

  /// Primary prompt, already localized (e.g. "Huruf apakah ini?").
  final String message;

  /// Optional secondary line (e.g. the English translation).
  final String? sub;

  @override
  State<ZaraPrompt> createState() => _ZaraPromptState();
}

class _ZaraPromptState extends State<ZaraPrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Pulsing owl avatar
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final t = _pulse.value;
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.violet.withValues(alpha: 0.35 + 0.25 * t),
                    blurRadius: 18 + 10 * t,
                    spreadRadius: 1 + 3 * t,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.lilac, AppTheme.violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lilac.withValues(alpha: 0.5),
                width: 3,
              ),
            ),
            alignment: Alignment.center,
            child: const Text('🦉', style: TextStyle(fontSize: 30)),
          ),
        ),
        const SizedBox(width: 10),
        // Glass speech bubble
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.message,
                  style: const TextStyle(
                    color: AppTheme.onNight,
                    fontSize: 13.5,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (widget.sub != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.sub!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      height: 1.25,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
