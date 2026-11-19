import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../data/badge_data.dart';
import '../models/app_language.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../utils/app_text.dart';
import '../widgets/badge_card.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  static const routeName = '/progress';

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressServiceProvider);
    final language = progress.language;

    return Scaffold(
      backgroundColor: AppTheme.nightMid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const NightBar(AppTheme.moduleGames),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: language.copy(ms: 'Kembali', en: 'Back', zh: '返回', ta: 'பின்செல்'),
        ),
        title: Text(
          language.copy(ms: '🏆 Kemajuan Saya', en: '🏆 My Progress', zh: '🏆 我的进度', ta: '🏆 என் முன்னேற்றம்'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _StarHeroBanner(progress: progress, language: language),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SectionHeader(
                  emoji: '🏅',
                  title: AppText.ui('badges', language),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: BadgeCard(
                      badge: badges[i],
                      earned: progress.hasBadge(badges[i].id),
                    ),
                  ),
                  childCount: badges.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Star Hero Banner ──────────────────────────────────────────────────────────
class _StarHeroBanner extends ConsumerStatefulWidget {
  const _StarHeroBanner({required this.progress, required this.language});
  final ProgressService progress;
  final AppLanguage language;

  @override
  ConsumerState<_StarHeroBanner> createState() => _StarHeroBannerState();
}

class _StarHeroBannerState extends ConsumerState<_StarHeroBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkCtrl;

  @override
  void initState() {
    super.initState();
    _sparkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkCtrl.dispose();
    super.dispose();
  }

  String _motivationalMessage(int stars, int done, AppLanguage language) {
    if (done == 0) {
      return language.copy(ms: 'Mulakan perjalanan belajar kamu hari ini! 🚀', en: 'Start your learning journey today! 🚀', zh: '今天就开始你的学习之旅吧！🚀', ta: 'இன்றே உன் கற்றல் பயணத்தைத் தொடங்கு! 🚀');
    }
    if (stars < 10) {
      return language.copy(ms: 'Bagus! Teruskan untuk dapat lebih bintang! 🌟', en: 'Good start! Keep learning for more stars! 🌟', zh: '好的开始！继续学习，获得更多星星！🌟', ta: 'நல்ல தொடக்கம்! மேலும் நட்சத்திரங்களுக்கு தொடர்ந்து கற்று! 🌟');
    }
    if (stars < 30) {
      return language.copy(ms: 'Hebat! Kamu dalam perjalanan yang betul! 🎉', en: 'Great job! You\'re on the right track! 🎉', zh: '干得好！你走在正确的道路上！🎉', ta: 'சிறப்பு! நீ சரியான பாதையில் இருக்கிறாய்! 🎉');
    }
    if (stars < 60) {
      return language.copy(ms: 'Luar biasa! Kamu pelajar yang handal! ⭐', en: 'Amazing! You\'re a super learner! ⭐', zh: '太棒了！你是超级学习者！⭐', ta: 'அற்புதம்! நீ ஒரு சிறந்த கற்றவன்! ⭐');
    }
    return language.copy(ms: 'WOW! Kamu seorang bintang belajar sejati! 🏆🌟', en: 'WOW! You\'re a true learning star! 🏆🌟', zh: '哇！你是真正的学习之星！🏆🌟', ta: 'வாவ்! நீ உண்மையான கற்றல் நட்சத்திரம்! 🏆🌟');
  }

  @override
  Widget build(BuildContext context) {
    final stars = widget.progress.stars;
    final done = widget.progress.completedChallenges;
    final language = widget.language;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1F6B), Color(0xFF1565C0), AppTheme.skyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.skyBlue.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _sparkCtrl,
        builder: (context, _) {
          return Stack(
            children: [
              Positioned(
                top: math.sin(_sparkCtrl.value * 2 * math.pi) * 8,
                right: 16,
                child: Opacity(
                  opacity:
                      (0.5 + 0.5 * math.cos(_sparkCtrl.value * 2 * math.pi))
                          .clamp(0, 1),
                  child: const Text('✨', style: TextStyle(fontSize: 22)),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.copy(ms: 'Bilik Trofi Kamu!', en: 'Your Trophy Room!', zh: '你的奖杯室！', ta: 'உன் கோப்பை அறை!'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              language.copy(ms: 'Teruskan belajar & kumpul bintang! ⭐', en: 'Keep learning & collect stars! ⭐', zh: '继续学习，收集星星！⭐', ta: 'தொடர்ந்து கற்று நட்சத்திரங்களைச் சேகரி! ⭐'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroBubble(
                          value: '$stars',
                          label: language.copy(ms: 'Bintang', en: 'Stars', zh: '星星', ta: 'நட்சத்திரங்கள்'),
                          icon: '⭐',
                          color: AppTheme.sunnyYellow,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeroBubble(
                          value: '$done',
                          label: language.copy(ms: 'Selesai', en: 'Completed', zh: '已完成', ta: 'முடிந்தவை'),
                          icon: '✅',
                          color: AppTheme.leafGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeroBubble(
                          value: '${widget.progress.coloringSessions}',
                          label: language.copy(ms: 'Mewarna', en: 'Coloured', zh: '已涂色', ta: 'வண்ணம் தீட்டப்பட்டது'),
                          icon: '🎨',
                          color: const Color(0xFFFF9F43),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _motivationalMessage(stars, done, language),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroBubble extends ConsumerWidget {
  const _HeroBubble({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value, label, icon;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────
class _SectionHeader extends ConsumerWidget {
  const _SectionHeader({required this.emoji, required this.title});
  final String emoji, title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppTheme.onNight,
          ),
        ),
      ],
    );
  }
}
