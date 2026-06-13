import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/level.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class LevelUpDialog extends ConsumerStatefulWidget {
  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.isMalay,
  });

  final AppLevel newLevel;
  final bool isMalay;

  @override
  ConsumerState<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends ConsumerState<LevelUpDialog>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _bounce;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4))
      ..play();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _bounceAnim = CurvedAnimation(parent: _bounce, curve: Curves.elasticOut);

    // TTS congratulation on level-up
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakLevelUp());
  }

  Future<void> _speakLevelUp() async {
    final ps = ref.read(progressServiceProvider);
    if (!ps.voiceEnabled) return;
    final audio = ref.read(audioServiceProvider);
    final msg = widget.isMalay
        ? 'Tahniah! Kamu naik ke Tahap ${widget.newLevel.level}! ${widget.newLevel.titleMalay}!'
        : 'Congratulations! You reached Level ${widget.newLevel.level}! ${widget.newLevel.title}!';
    await audio.speakLocale(msg, enabled: true, locale: widget.isMalay ? 'ms-MY' : 'en-US');
  }

  @override
  void dispose() {
    _confetti.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.newLevel;
    final isMalay = widget.isMalay;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ScaleTransition(
          scale: _bounceAnim,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A1F6B),
                    level.color,
                    const Color(0xFF0A1F6B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: AppTheme.sunnyYellow, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: level.color.withValues(alpha: 0.6),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LEVEL UP badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.sunnyYellow,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        isMalay ? '⬆ NAIK TAHAP!' : '⬆ LEVEL UP!',
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Big emoji
                    Text(level.emoji,
                        style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 12),

                    // Level number
                    Text(
                      isMalay ? 'Tahap ${level.level}' : 'Level ${level.level}',
                      style: TextStyle(
                        color: level.color,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Level title
                    Text(
                      isMalay ? level.titleMalay : level.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Continue button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [level.color, level.color.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: level.color.withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          isMalay ? '🚀 Teruskan!' : '🚀 Keep Going!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Confetti
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 30,
          gravity: 0.15,
          colors: [
            AppTheme.sunnyYellow,
            Colors.white,
            level.color,
            AppTheme.appleRed,
            AppTheme.turquoise,
          ],
        ),
      ],
    );
  }
}
