import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../models/app_language.dart';
import '../models/challenge.dart';
import '../models/train_mode.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/pressable.dart';
import '../widgets/zara_prompt.dart';
import 'find_explorer_screen.dart';
import 'memory_category_screen.dart';
import 'puzzle_screen.dart';
import 'train_sort_screen.dart';

/// Bandar Permainan — a playful "Game Town" map where every game is a lit-up
/// station on a winding trail through a starry carnival town.
class GamesHubScreen extends ConsumerWidget {
  const GamesHubScreen({super.key});
  static const routeName = '/games-hub';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressServiceProvider);
    final language = progress.language;
    final mystery = progress.mysteryGameToday;

    final games = <_GameInfo>[
      _GameInfo(
        icon: Icons.train_rounded,
        title: language.copy(ms: 'Tren Nombor', en: 'Number Train', zh: '数字火车', ta: 'எண் ரயில்'),
        color: AppTheme.moduleNumbers,
        route: TrainSortScreen.routeName,
        arguments: const TrainSortArgs(mode: TrainMode.numbers),
        count: progress.countFor(ChallengeMode.numberTrain),
        isMystery: mystery == ChallengeMode.numberTrain,
      ),
      _GameInfo(
        icon: Icons.directions_railway_rounded,
        title: language.copy(ms: 'Tren Huruf', en: 'Letter Train', zh: '字母火车', ta: 'எழுத்து ரயில்'),
        color: AppTheme.moduleLetters,
        route: TrainSortScreen.routeName,
        arguments: const TrainSortArgs(mode: TrainMode.letters),
        count: progress.countFor(ChallengeMode.letterTrain),
        isMystery: mystery == ChallengeMode.letterTrain,
      ),
      _GameInfo(
        icon: Icons.style_rounded,
        title: language.copy(ms: 'Permainan Memori', en: 'Memory Game', zh: '记忆游戏', ta: 'நினைவாற்றல் விளையாட்டு'),
        color: const Color(0xFF7E57C2),
        route: MemoryCategoryScreen.routeName,
        count: progress.countFor(ChallengeMode.memory),
        isMystery: mystery == ChallengeMode.memory,
      ),
      _GameInfo(
        icon: Icons.extension_rounded,
        title: language.copy(ms: 'Teka-Teki Gambar', en: 'Picture Puzzle', zh: '图片拼图', ta: 'படப் புதிர்'),
        color: const Color(0xFF00897B),
        route: PuzzleScreen.routeName,
        count: progress.countFor(ChallengeMode.puzzle),
        isMystery: mystery == ChallengeMode.puzzle,
      ),
      _GameInfo(
        icon: Icons.search_rounded,
        title: language.copy(ms: 'Penjelajah Cari', en: 'Find Explorer', zh: '探险家寻找', ta: 'தேடும் ஆய்வாளர்'),
        color: AppTheme.turquoise,
        route: FindExplorerScreen.routeName,
        count: progress.countFor(ChallengeMode.findExplorer),
        isMystery: mystery == ChallengeMode.findExplorer,
      ),
    ];

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
          language.copy(ms: 'Bandar Permainan 🎮', en: 'Game Town 🎮', zh: '游戏小镇 🎮', ta: 'விளையாட்டு நகரம் 🎮'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: BijakScene(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Zara welcomes the child to Game Town.
                  ZaraPrompt(
                    message: language.copy(ms: 'Selamat datang ke Bandar Permainan!', en: 'Welcome to Game Town!', zh: '欢迎来到游戏小镇！', ta: 'விளையாட்டு நகரத்திற்கு வரவேற்கிறோம்!'),
                    sub: language.copy(ms: 'Ketuk stesen untuk bermain & belajar.', en: 'Tap a station to play & learn.', zh: '点击一个车站，边玩边学。', ta: 'ஒரு நிலையத்தைத் தட்டி விளையாடி கற்றுக்கொள்.'),
                  ),
                  const SizedBox(height: 14),
                  _GameTownMap(games: games, language: language),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        language.copy(ms: 'Tips Ibu Bapa & Guru', en: 'Parent & Teacher Tips', zh: '家长与老师提示', ta: 'பெற்றோர் & ஆசிரியர் குறிப்புகள்'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.onNight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _TipCard(language: language),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Game Town map (interactive trail of game stations) ───────────────────────
class _GameTownMap extends StatelessWidget {
  const _GameTownMap({required this.games, required this.language});

  final List<_GameInfo> games;
  final AppLanguage language;

  static const _pos = <Offset>[
    Offset(0.24, 0.02),
    Offset(0.70, 0.155),
    Offset(0.30, 0.31),
    Offset(0.70, 0.465),
    Offset(0.40, 0.63),
  ];

  // Carnival-town decorations scattered around the trail.
  static const _decor = <(String, Offset)>[
    ('🎡', Offset(0.52, 0.05)),
    ('🎪', Offset(0.13, 0.22)),
    ('🎠', Offset(0.88, 0.33)),
    ('🎯', Offset(0.50, 0.40)),
    ('🎈', Offset(0.15, 0.52)),
    ('🎢', Offset(0.85, 0.58)),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = max(640.0, w * 1.55);
        final n = min(games.length, _pos.length);
        final centers = [
          for (var i = 0; i < n; i++)
            Offset(_pos[i].dx * w, _pos[i].dy * h + 36),
        ];

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _GameTrailPainter(centers)),
              ),
              for (final d in _decor)
                Positioned(
                  left: d.$2.dx * w - 15,
                  top: d.$2.dy * h,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(d.$1, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              for (var i = 0; i < n; i++)
                Positioned(
                  left: _pos[i].dx * w - 56,
                  top: _pos[i].dy * h,
                  child: _GameNode(game: games[i], language: language),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GameNode extends StatelessWidget {
  const _GameNode({required this.game, required this.language});

  final _GameInfo game;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final ringColor = game.isMystery ? AppTheme.gold : Colors.white;
    return Pressable(
      onTap: () => Navigator.of(
        context,
      ).pushNamed(game.route, arguments: game.arguments),
      pressedScale: 0.92,
      semanticLabel: game.title,
      child: SizedBox(
        width: 112,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (game.isMystery)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  language.copy(ms: '🎁 2× ⭐', en: '🎁 2× ⭐', zh: '🎁 2× ⭐', ta: '🎁 2× ⭐'),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.nightDeep,
                  ),
                ),
              ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [game.color, game.color.withValues(alpha: 0.72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: game.color.withValues(alpha: 0.55),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(game.icon, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 5),
            Text(
              game.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.onNight,
                fontSize: 11.5,
                height: 1.12,
                fontWeight: FontWeight.w800,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(
                color: game.count > 0
                    ? AppTheme.gold.withValues(alpha: 0.22)
                    : game.color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: (game.count > 0 ? AppTheme.gold : game.color)
                      .withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                game.count > 0 ? '⭐ ${game.count}' : (language.copy(ms: 'BARU', en: 'NEW', zh: '新', ta: 'புதிது')),
                style: const TextStyle(
                  color: AppTheme.onNight,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed trail connecting the game stations in order.
class _GameTrailPainter extends CustomPainter {
  const _GameTrailPainter(this.centers);
  final List<Offset> centers;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.gold.withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < centers.length - 1; i++) {
      _dashed(canvas, centers[i], centers[i + 1], paint);
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    final total = (b - a).distance;
    const dash = 9.0, gap = 8.0;
    double d = 0;
    while (d < total) {
      final f1 = d / total;
      final f2 = min(d + dash, total) / total;
      canvas.drawLine(Offset.lerp(a, b, f1)!, Offset.lerp(a, b, f2)!, paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _GameTrailPainter oldDelegate) =>
      oldDelegate.centers != centers;
}

class _GameInfo {
  const _GameInfo({
    required this.icon,
    required this.title,
    required this.color,
    required this.route,
    required this.count,
    required this.isMystery,
    this.arguments,
  });

  final IconData icon;
  final String title;
  final Color color;
  final String route;
  final Object? arguments;
  final int count;
  final bool isMystery;
}

// ── Tip card ───────────────────────────────────────────────────────────────────
class _TipCard extends ConsumerWidget {
  const _TipCard({required this.language});
  final AppLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = language.usesMalayCopy
        ? [
            '🎯 Main bersama anak 10–15 minit sehari',
            '🌟 Puji usaha, bukan hanya jawapan betul',
            '🔄 Ulangi permainan yang disukai anak',
            '📖 Hubungkan permainan dengan buku cerita',
            '💬 Tanya anak: "Apa yang kamu belajar hari ini?"',
          ]
        : [
            '🎯 Play with your child 10–15 minutes a day',
            '🌟 Praise effort, not just correct answers',
            '🔄 Repeat games your child enjoys most',
            '📖 Connect games to picture books',
            '💬 Ask your child: "What did you learn today?"',
          ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1EA7FF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                t,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF123A7A),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
