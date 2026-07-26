import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models/app_language.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class DailyRewardDialog extends StatefulWidget {
  const DailyRewardDialog({super.key, required this.progress});

  final ProgressService progress;

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _scale;
  late final Animation<double> _scaleAnim;
  bool _collected = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _scaleAnim = CurvedAnimation(parent: _scale, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _confetti.dispose();
    _scale.dispose();
    super.dispose();
  }

  Future<void> _collect() async {
    if (_collected) return;
    setState(() => _collected = true);
    _confetti.play();
    await widget.progress.collectDailyReward();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isMalay = widget.progress.language == AppLanguage.malay;
    final streak = widget.progress.currentStreak;
    final stars = widget.progress.dailyRewardStars;
    final level = widget.progress.currentLevel;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ScaleTransition(
          scale: _scaleAnim,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A1F6B),
                    level.color.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: level.color.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top icon
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.sunnyYellow,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          streak >= 7
                              ? '🔥'
                              : streak >= 3
                              ? '🌟'
                              : '🎁',
                          style: const TextStyle(fontSize: 46),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      isMalay ? 'Hadiah Harian! 🎉' : 'Daily Gift! 🎉',
                      style: const TextStyle(
                        color: AppTheme.sunnyYellow,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Streak info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isMalay
                                  ? '$streak hari berturut-turut!'
                                  : '$streak day streak!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stars reward
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.sunnyYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppTheme.sunnyYellow,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 36)),
                          const SizedBox(width: 10),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '+$stars',
                                style: const TextStyle(
                                  color: AppTheme.sunnyYellow,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              isMalay ? 'Bintang' : 'Stars',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Streak bonus note
                    if (streak >= 3)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          isMalay
                              ? '🎯 Bonus streak $streak hari!'
                              : '🎯 $streak-day streak bonus!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    // Streak rescued by a freeze token
                    if (widget.progress.streakFreezeJustUsed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          isMalay
                              ? '❄️ Streak kamu diselamatkan! Token beku digunakan.'
                              : '❄️ Your streak was saved! A freeze token was used.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFBDE6FF),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                    // Freeze tokens held
                    if (widget.progress.streakFreezes > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          isMalay
                              ? '❄️ ${widget.progress.streakFreezes} token beku — melindungi streak kamu jika terlepas sehari'
                              : '❄️ ${widget.progress.streakFreezes} freeze token${widget.progress.streakFreezes > 1 ? 's' : ''} — protects your streak if you miss a day',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    // Tomorrow's reward — make the escalating table work for us
                    Text(
                      isMalay
                          ? '⏰ Datang esok untuk +${widget.progress.tomorrowRewardStars} ⭐!'
                          : '⏰ Come back tomorrow for +${widget.progress.tomorrowRewardStars} ⭐!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.sunnyYellow,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Collect button
                    GestureDetector(
                      onTap: _collected ? null : _collect,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: _collected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF34C759),
                                    Color(0xFF2ECC71),
                                  ],
                                )
                              : const LinearGradient(
                                  colors: [
                                    AppTheme.sunnyYellow,
                                    Color(0xFFFFB300),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.sunnyYellow.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _collected
                                ? (isMalay ? '✅ Dikumpul!' : '✅ Collected!')
                                : (isMalay
                                      ? '🎁 Kumpul Hadiah!'
                                      : '🎁 Collect Gift!'),
                            style: const TextStyle(
                              color: AppTheme.ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
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
          numberOfParticles: 25,
          gravity: 0.2,
          colors: const [
            AppTheme.sunnyYellow,
            Colors.white,
            AppTheme.turquoise,
            AppTheme.appleRed,
            AppTheme.leafGreen,
          ],
        ),
      ],
    );
  }
}
