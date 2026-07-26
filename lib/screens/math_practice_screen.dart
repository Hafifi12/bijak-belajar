import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../models/app_language.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/pressable.dart';
import '../widgets/star_counter.dart';
import '../widgets/xp_popup.dart';
import '../widgets/zara_prompt.dart';

// ── Entry point (topic picker) ─────────────────────────────────────────────────
class MathPracticeScreen extends ConsumerWidget {
  const MathPracticeScreen({super.key});

  static const routeName = '/math-practice';

  static const _topics = [
    _MathTopic(
      labelMs: 'Kira Objek 🔢',
      labelEn: 'Counting 🔢',
      subtitleMs: 'Kira bintang, buah dan haiwan',
      subtitleEn: 'Count stars, fruits and animals',
      op: MathOp.count,
      color: Color(0xFF00C9A7),
      icon: Icons.format_list_numbered_rounded,
    ),
    _MathTopic(
      labelMs: 'Tambah ➕',
      labelEn: 'Addition ➕',
      subtitleMs: 'Latihan tambah nombor',
      subtitleEn: 'Practice adding numbers',
      op: MathOp.add,
      color: Color(0xFFFF6B6B),
      icon: Icons.add_circle_outline_rounded,
    ),
    _MathTopic(
      labelMs: 'Tolak ➖',
      labelEn: 'Subtraction ➖',
      subtitleMs: 'Latihan tolak nombor',
      subtitleEn: 'Practice subtracting numbers',
      op: MathOp.subtract,
      color: Color(0xFFFF9F43),
      icon: Icons.remove_circle_outline_rounded,
    ),
    _MathTopic(
      labelMs: 'Darab ✖️',
      labelEn: 'Multiplication ✖️',
      subtitleMs: 'Sifir mudah 2 hingga 5',
      subtitleEn: 'Simple tables 2 to 5',
      op: MathOp.multiply,
      color: Color(0xFF1DD1A1),
      icon: Icons.close_rounded,
    ),
    _MathTopic(
      labelMs: 'Bahagi ➗',
      labelEn: 'Division ➗',
      subtitleMs: 'Bahagi jawapan bersih',
      subtitleEn: 'Clean-answer division',
      op: MathOp.divide,
      color: Color(0xFF48DBFB),
      icon: Icons.more_horiz_rounded,
    ),
    _MathTopic(
      labelMs: 'Besar atau Kecil ⚖️',
      labelEn: 'Bigger or Smaller ⚖️',
      subtitleMs: 'Pilih nombor yang betul',
      subtitleEn: 'Pick the correct number',
      op: MathOp.compare,
      color: Color(0xFF7A5CFF),
      icon: Icons.compare_arrows_rounded,
    ),
    _MathTopic(
      labelMs: 'Nombor Hilang ❓',
      labelEn: 'Missing Number ❓',
      subtitleMs: 'Lengkapkan susunan nombor',
      subtitleEn: 'Complete the number pattern',
      op: MathOp.missing,
      color: Color(0xFF34C759),
      icon: Icons.help_outline_rounded,
    ),
    _MathTopic(
      labelMs: 'Pasangan Nombor 🔟',
      labelEn: 'Number Bonds 🔟',
      subtitleMs: 'Cari nombor yang melengkapkan',
      subtitleEn: 'Find the number that completes it',
      op: MathOp.bond,
      color: Color(0xFFFFD21E),
      icon: Icons.link_rounded,
    ),
    _MathTopic(
      labelMs: 'Campur Semua 🎲',
      labelEn: 'Mixed All 🎲',
      subtitleMs: 'Soalan pelbagai operasi',
      subtitleEn: 'Questions with all operations',
      op: MathOp.mixed,
      color: Color(0xFF6C5CE7),
      icon: Icons.shuffle_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(progressServiceProvider).language;
    final isMalay = language == AppLanguage.malay;

    return Scaffold(
      backgroundColor: AppTheme.nightMid,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: isMalay ? 'Kembali' : 'Back',
        ),
        // Hero continues the emoji "flight" from the Learning Path card.
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'module-emoji-${MathPracticeScreen.routeName}',
              child: const Text('🧮', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isMalay ? 'Latihan Matematik' : 'Maths Practice',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: const NightBar(AppTheme.moduleMath),
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: StarCounter()),
          ),
        ],
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
                  // Zara welcomes the child to the Math Forest.
                  ZaraPrompt(
                    message: isMalay
                        ? 'Selamat datang ke Hutan Matematik!'
                        : 'Welcome to the Math Forest!',
                    sub: isMalay
                        ? 'Ketuk stesen di jejak untuk berlatih.'
                        : 'Tap a station on the trail to practise.',
                  ),
                  const SizedBox(height: 12),
                  // Daily 5 — the module's daily comeback hook.
                  _Daily5Card(isMalay: isMalay),
                  const SizedBox(height: 4),
                  // Interactive trail of math-topic stations.
                  _MathForestMap(topics: _topics, isMalay: isMalay),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Daily 5 card ───────────────────────────────────────────────────────────────
class _Daily5Card extends ConsumerWidget {
  const _Daily5Card({required this.isMalay});
  final bool isMalay;

  /// Today's operation — rotates daily (same seed idea as the quest pool) so
  /// the Daily 5 feels fresh without any new content.
  MathOp get _todaysOp {
    final day = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    return MathOp.values[day % MathOp.values.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressServiceProvider);
    final done = progress.isDaily5DoneToday;
    const color = AppTheme.moduleMath;

    return Pressable(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MathQuizScreen(
            op: _todaysOp,
            color: color,
            level: 1,
            daily5: true,
          ),
        ),
      ),
      pressedScale: 0.97,
      semanticLabel: isMalay
          ? 'Lima soalan harian. ${done ? 'Selesai hari ini.' : 'Bonus lima bintang.'}'
          : 'Daily five questions. ${done ? 'Done today.' : 'Five star bonus.'}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: done
                ? [
                    AppTheme.leafGreen,
                    AppTheme.leafGreen.withValues(alpha: 0.8),
                  ]
                : [color, color.withValues(alpha: 0.78)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: (done ? AppTheme.leafGreen : color).withValues(
                alpha: 0.35,
              ),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(done ? '✅' : '⚡', style: const TextStyle(fontSize: 34)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMalay ? 'Misi 5 Soalan Harian' : 'Daily 5 Challenge',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    done
                        ? (isMalay
                              ? 'Selesai hari ini! Datang lagi esok ⭐'
                              : 'Done today! Come back tomorrow ⭐')
                        : (isMalay
                              ? '5 soalan pantas • Bonus +5 ⭐'
                              : '5 quick questions • +5 ⭐ bonus'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Math Forest map (interactive topic trail) ───────────────────────────────
class _MathForestMap extends StatelessWidget {
  const _MathForestMap({required this.topics, required this.isMalay});

  final List<_MathTopic> topics;
  final bool isMalay;

  // Serpentine station positions (fractions of the map's width/height).
  static const _pos = <Offset>[
    Offset(0.22, 0.015),
    Offset(0.72, 0.11),
    Offset(0.30, 0.22),
    Offset(0.72, 0.33),
    Offset(0.24, 0.44),
    Offset(0.68, 0.545),
    Offset(0.32, 0.655),
    Offset(0.70, 0.76),
    Offset(0.40, 0.87),
  ];

  // Decorative trees scattered through the forest.
  static const _trees = <Offset>[
    Offset(0.50, 0.05),
    Offset(0.12, 0.28),
    Offset(0.90, 0.20),
    Offset(0.48, 0.39),
    Offset(0.13, 0.58),
    Offset(0.88, 0.66),
    Offset(0.55, 0.80),
    Offset(0.86, 0.90),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = max(800.0, w * 2.2);
        final n = min(topics.length, _pos.length);
        final centers = [
          for (var i = 0; i < n; i++)
            Offset(_pos[i].dx * w, _pos[i].dy * h + 34),
        ];

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Winding forest trail behind the stations.
              Positioned.fill(
                child: CustomPaint(painter: _MathTrailPainter(centers)),
              ),
              // Trees.
              for (var i = 0; i < _trees.length; i++)
                Positioned(
                  left: _trees[i].dx * w - 14,
                  top: _trees[i].dy * h,
                  child: Opacity(
                    opacity: 0.55,
                    child: Text(
                      i.isEven ? '🌲' : '🌳',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              // Topic stations.
              for (var i = 0; i < n; i++)
                Positioned(
                  left: _pos[i].dx * w - 54,
                  top: _pos[i].dy * h,
                  child: _TopicNode(topic: topics[i], isMalay: isMalay),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TopicNode extends StatelessWidget {
  const _TopicNode({required this.topic, required this.isMalay});

  final _MathTopic topic;
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    final label = isMalay ? topic.labelMs : topic.labelEn;
    return Pressable(
      onTap: () => _showTopicLevels(context, topic, isMalay),
      pressedScale: 0.92,
      semanticLabel: label,
      child: SizedBox(
        width: 108,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [topic.color, topic.color.withValues(alpha: 0.72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: topic.color.withValues(alpha: 0.55),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(topic.icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.onNight,
                fontSize: 11,
                height: 1.12,
                fontWeight: FontWeight.w800,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: topic.color.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: topic.color.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: const Text(
                '1 · 2 · 3',
                style: TextStyle(
                  color: AppTheme.onNight,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed trail connecting the topic stations in order.
class _MathTrailPainter extends CustomPainter {
  const _MathTrailPainter(this.centers);
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
  bool shouldRepaint(covariant _MathTrailPainter oldDelegate) =>
      oldDelegate.centers != centers;
}

/// Bottom sheet to pick a difficulty level (Tahap 1–3) for a topic.
void _showTopicLevels(BuildContext context, _MathTopic topic, bool isMalay) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _LevelSheet(topic: topic, isMalay: isMalay),
  );
}

class _LevelSheet extends StatelessWidget {
  const _LevelSheet({required this.topic, required this.isMalay});

  final _MathTopic topic;
  final bool isMalay;

  static const _levels = [
    (level: 1, color: Color(0xFF1DD1A1), ms: 'Mudah', en: 'Easy'),
    (level: 2, color: Color(0xFFFF9F43), ms: 'Sederhana', en: 'Medium'),
    (level: 3, color: Color(0xFFFF6B6B), ms: 'Susah', en: 'Hard'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.nightSurfaceHi, AppTheme.nightDeep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: topic.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(topic.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMalay ? topic.labelMs : topic.labelEn,
                          style: const TextStyle(
                            color: AppTheme.onNight,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isMalay ? topic.subtitleMs : topic.subtitleEn,
                          style: const TextStyle(
                            color: AppTheme.onNightMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isMalay ? 'PILIH TAHAP' : 'PICK A LEVEL',
                  style: const TextStyle(
                    color: AppTheme.onNightFaint,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (final l in _levels)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Pressable(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MathQuizScreen(
                            op: topic.op,
                            color: topic.color,
                            level: l.level,
                          ),
                        ),
                      );
                    },
                    pressedScale: 0.98,
                    semanticLabel:
                        '${isMalay ? 'Tahap' : 'Level'} ${l.level} — ${isMalay ? l.ms : l.en}',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [l.color, l.color.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: l.color.withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${l.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${isMalay ? 'Tahap' : 'Level'} ${l.level} · ${isMalay ? l.ms : l.en}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quiz Screen ───────────────────────────────────────────────────────────────
class MathQuizScreen extends ConsumerStatefulWidget {
  const MathQuizScreen({
    super.key,
    required this.op,
    required this.color,
    this.level = 1,
    this.daily5 = false,
  });

  final MathOp op;
  final Color color;
  final int level; // 1=easy, 2=medium, 3=hard

  /// Daily 5 mode: 5 questions, once-per-day +5 ⭐ bonus on completion.
  final bool daily5;

  @override
  ConsumerState<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends ConsumerState<MathQuizScreen>
    with TickerProviderStateMixin {
  int get _totalQuestions => widget.daily5 ? 5 : 10;

  final _rng = Random();
  final _answers = <bool>[];
  late _Question _q;

  // tracking
  int _score = 0;
  int _questionIndex = 0;
  bool _answered = false;
  int? _selectedOption;

  // ── Adaptive difficulty ───────────────────────────────────────
  // The quiz silently steps the level up after 3 correct in a row and down
  // after 2 wrong in a row, keeping the child in the zone where questions
  // feel winnable but not boring. No UI — frustration management, not a
  // feature the child should see.
  late int _level = widget.level;
  int _correctStreak = 0;
  int _wrongStreak = 0;

  void _adaptDifficulty({required bool correct}) {
    if (correct) {
      _correctStreak++;
      _wrongStreak = 0;
      if (_correctStreak >= 3 && _level < 3) {
        _level++;
        _correctStreak = 0;
      }
    } else {
      _wrongStreak++;
      _correctStreak = 0;
      if (_wrongStreak >= 2 && _level > 1) {
        _level--;
        _wrongStreak = 0;
      }
    }
  }

  // animations
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  late AnimationController _popCtrl;
  late Animation<double> _popAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _popAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _popCtrl, curve: Curves.elasticOut));

    _generateQuestion();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _popCtrl.dispose();
    super.dispose();
  }

  /// Question texts already asked this quiz — no child should see the same
  /// question twice in one session.
  final Set<String> _askedQuestions = {};

  void _generateQuestion() {
    final isMalay =
        ref.read(progressServiceProvider).language == AppLanguage.malay;
    // Re-roll duplicates. Bounded attempts: easy levels have small pools
    // (e.g. counting 1–10), so after 15 tries we accept a repeat rather
    // than loop forever.
    var candidate = _Question.generate(
      op: widget.op,
      level: _level,
      rng: _rng,
      isMalay: isMalay,
    );
    for (
      var attempt = 0;
      attempt < 15 && _askedQuestions.contains(candidate.questionText);
      attempt++
    ) {
      candidate = _Question.generate(
        op: widget.op,
        level: _level,
        rng: _rng,
        isMalay: isMalay,
      );
    }
    _askedQuestions.add(candidate.questionText);
    setState(() {
      _q = candidate;
      _answered = false;
      _selectedOption = null;
    });
    _popCtrl.forward(from: 0);
  }

  void _pick(int idx, bool correct) async {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedOption = idx;
      if (correct) {
        _score++;
        _answers.add(true);
      } else {
        _answers.add(false);
        _shakeCtrl.forward(from: 0);
      }
      _adaptDifficulty(correct: correct);
    });

    // Sound feedback — clap/chime for correct, soft buzz for wrong (no voice)
    final progress = ref.read(progressServiceProvider);
    final audio = ref.read(audioServiceProvider);
    if (correct) {
      await progress.addStars(1);
    }
    await audio.playEffect(
      correct ? 'correct' : 'wrong',
      enabled: progress.soundEnabled,
    );

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return; // user may have backed out during the pause

    if (_questionIndex < _totalQuestions - 1) {
      setState(() => _questionIndex++);
      _generateQuestion();
    } else {
      await progress.markModuleLesson(
        'math',
        _opLabel(
          widget.op,
          progress.language == AppLanguage.malay,
          widget.level,
        ),
      );
      // Daily 5 completion bonus — once per day, regardless of score (effort
      // is what brings a 4–7 year old back; mastery gates come later).
      if (widget.daily5) {
        final bonus = await progress.claimDaily5Bonus();
        if (bonus > 0 && mounted) {
          XpPopup.show(context, amount: bonus);
        }
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MathResultScreen(
            score: _score,
            total: _totalQuestions,
            color: widget.color,
            op: widget.op,
            level: widget.level,
            answers: _answers,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(progressServiceProvider).language;
    final isMalay = language == AppLanguage.malay;
    final color = widget.color;

    return Scaffold(
      backgroundColor: AppTheme.nightMid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const NightBar(AppTheme.moduleMath),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _opLabel(widget.op, isMalay, widget.level),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            Text(
              '${isMalay ? 'Soalan' : 'Question'} ${_questionIndex + 1} / $_totalQuestions  •  $_score ⭐',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: StarCounter()),
          ),
        ],
      ),
      body: BijakScene(
        topColor: AppTheme.nightTop,
        bottomColor: AppTheme.nightBottom,
        showHills: false,
        child: SafeArea(
          // NOTE: a plain scroll + Column (no IntrinsicHeight) is required
          // because the answer GridView and the counting-objects scroll view
          // are lazy viewports — IntrinsicHeight cannot measure a viewport and
          // would throw, leaving the whole body blank.
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Yellow progress bar + counter pill
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: (_questionIndex + 1) / _totalQuestions,
                            minHeight: 13,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.sunnyYellow,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.deepBlue,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          '${_questionIndex + 1}/$_totalQuestions',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Answer history dots
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: List.generate(_totalQuestions, (i) {
                      Color dotColor;
                      if (i < _answers.length) {
                        dotColor = _answers[i]
                            ? AppTheme.leafGreen
                            : AppTheme.appleRed;
                      } else if (i == _questionIndex) {
                        dotColor = color;
                      } else {
                        dotColor = Colors.white.withValues(alpha: 0.5);
                      }
                      return Expanded(
                        child: Container(
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: dotColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Zara asks the question ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ZaraPrompt(
                    message: isMalay
                        ? 'Berapakah jawapannya? Kira & pilih!'
                        : "What's the answer? Count & choose!",
                    sub: isMalay ? "What's the answer?" : 'Kira dengan teliti',
                  ),
                ),
                const SizedBox(height: 14),

                // Question card (white container)
                AnimatedBuilder(
                  animation: _popAnim,
                  builder: (_, child) =>
                      Transform.scale(scale: _popAnim.value, child: child),
                  child: AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(
                        sin(_shakeAnim.value * pi * 5) *
                            10 *
                            (1 - _shakeAnim.value),
                        0,
                      ),
                      child: child,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.deepBlue.withValues(alpha: 0.14),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _q.emoji,
                              style: const TextStyle(fontSize: 46),
                            ),
                            if (_q.visualCount != null) ...[
                              const SizedBox(height: 10),
                              _CountingObjectGrid(
                                emoji: _q.emoji,
                                count: _q.visualCount!,
                                color: color,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Text(
                              _q.questionText,
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: color,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_q.hint != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _q.hint!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            if (_answered) ...[
                              const SizedBox(height: 12),
                              _AnswerFeedback(
                                correct:
                                    _selectedOption != null &&
                                    _q.options[_selectedOption!] == _q.answer,
                                isMalay: isMalay,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Answer options grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.6,
                    children: _q.options.asMap().entries.map((e) {
                      final idx = e.key;
                      final opt = e.value;
                      final isCorrect = opt == _q.answer;
                      Color btnColor = Colors.white;
                      Color textColor = color;
                      Color borderColor = color.withValues(alpha: 0.4);

                      if (_answered && _selectedOption == idx) {
                        btnColor = isCorrect
                            ? AppTheme.leafGreen
                            : AppTheme.appleRed;
                        textColor = Colors.white;
                        borderColor = btnColor;
                      } else if (_answered && isCorrect) {
                        btnColor = AppTheme.leafGreen.withValues(alpha: 0.15);
                        textColor = AppTheme.leafGreen;
                        borderColor = AppTheme.leafGreen;
                      }

                      return _AnswerOption(
                        btnColor: btnColor,
                        textColor: textColor,
                        borderColor: borderColor,
                        elevation: _answered ? 0 : 3,
                        glowColor: color,
                        label: '$opt',
                        enabled: !_answered,
                        onTap: () => _pick(idx, isCorrect),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _opLabel(MathOp op, bool isMalay, int level) {
    final levelStr = isMalay ? 'Tahap $level' : 'Level $level';
    switch (op) {
      case MathOp.count:
        return '${isMalay ? 'Kira Objek' : 'Counting'} — $levelStr';
      case MathOp.add:
        return '${isMalay ? 'Tambah' : 'Addition'} — $levelStr';
      case MathOp.subtract:
        return '${isMalay ? 'Tolak' : 'Subtraction'} — $levelStr';
      case MathOp.multiply:
        return '${isMalay ? 'Darab' : 'Multiply'} — $levelStr';
      case MathOp.divide:
        return '${isMalay ? 'Bahagi' : 'Divide'} — $levelStr';
      case MathOp.compare:
        return '${isMalay ? 'Besar atau Kecil' : 'Bigger or Smaller'} — $levelStr';
      case MathOp.missing:
        return '${isMalay ? 'Nombor Hilang' : 'Missing Number'} — $levelStr';
      case MathOp.bond:
        return '${isMalay ? 'Pasangan Nombor' : 'Number Bonds'} — $levelStr';
      case MathOp.mixed:
        return '${isMalay ? 'Campur Semua' : 'Mixed'} — $levelStr';
    }
  }
}

class _CountingObjectGrid extends ConsumerWidget {
  const _CountingObjectGrid({
    required this.emoji,
    required this.count,
    required this.color,
  });

  final String emoji;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 120),
      child: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: List.generate(
            count,
            (index) => Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.22)),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Answer choice tile with press feedback plus a fun long-press "nudge":
// holding a tile gives it a friendly wiggle + glow, a tactile cue that it's
// tappable — without revealing whether it's the right answer.
class _AnswerOption extends StatefulWidget {
  const _AnswerOption({
    required this.btnColor,
    required this.textColor,
    required this.borderColor,
    required this.elevation,
    required this.glowColor,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final Color btnColor;
  final Color textColor;
  final Color borderColor;
  final double elevation;
  final Color glowColor;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<_AnswerOption>
    with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;
  late final AnimationController _hintCtrl;
  late final Animation<double> _hintWiggle;
  late final Animation<double> _hintGlow;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _pressScale = Tween<double>(
      begin: 1,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

    _hintCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _hintWiggle = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.04), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.04, end: 0.04), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.04, end: -0.03), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _hintCtrl, curve: Curves.easeInOut));
    _hintGlow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _hintCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _hintCtrl.dispose();
    super.dispose();
  }

  void _onLongPress() {
    if (!widget.enabled) return;
    _hintCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _pressCtrl.forward() : null,
      onTapUp: widget.enabled ? (_) => _pressCtrl.reverse() : null,
      onTapCancel: widget.enabled ? () => _pressCtrl.reverse() : null,
      onLongPress: widget.enabled ? _onLongPress : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressCtrl, _hintCtrl]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pressScale.value,
            child: Transform.rotate(angle: _hintWiggle.value, child: child),
          );
        },
        child: AnimatedBuilder(
          animation: _hintGlow,
          builder: (context, child) => Material(
            color: widget.btnColor,
            borderRadius: BorderRadius.circular(16),
            elevation: widget.elevation,
            shadowColor: Color.lerp(
              widget.glowColor.withValues(alpha: 0.2),
              widget.glowColor.withValues(alpha: 0.7),
              _hintGlow.value,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.enabled ? widget.onTap : null,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Color.lerp(
                          widget.borderColor,
                          widget.glowColor,
                          _hintGlow.value,
                        ) ??
                        widget.borderColor,
                    width: 2 + _hintGlow.value * 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: widget.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerFeedback extends ConsumerWidget {
  const _AnswerFeedback({required this.correct, required this.isMalay});

  final bool correct;
  final bool isMalay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = correct
        ? (isMalay ? 'Hebat! Jawapan betul!' : 'Great job! Correct!')
        : (isMalay ? 'Hampir betul! Cuba lagi.' : 'Almost there! Try again.');
    final feedbackColor = correct ? AppTheme.leafGreen : AppTheme.appleRed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: feedbackColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: feedbackColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: feedbackColor,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Result Screen ─────────────────────────────────────────────────────────────
class MathResultScreen extends ConsumerWidget {
  const MathResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.color,
    required this.op,
    required this.level,
    required this.answers,
  });

  final int score;
  final int total;
  final Color color;
  final MathOp op;
  final int level;
  final List<bool> answers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(progressServiceProvider).language;
    final isMalay = language == AppLanguage.malay;
    final pct = score / total;
    final emoji = pct == 1.0
        ? '🏆'
        : pct >= 0.8
        ? '🌟'
        : pct >= 0.5
        ? '👍'
        : '💪';
    final msg = isMalay
        ? (pct == 1.0
              ? 'Sempurna! Kamu Terbaik!'
              : pct >= 0.8
              ? 'Sangat Bagus!'
              : pct >= 0.5
              ? 'Bagus! Cuba lagi!'
              : 'Teruskan Berlatih!')
        : (pct == 1.0
              ? 'Perfect! Amazing!'
              : pct >= 0.8
              ? 'Great Job!'
              : pct >= 0.5
              ? 'Good Try!'
              : 'Keep Practising!');

    return Scaffold(
      backgroundColor: AppTheme.nightMid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const NightBar(AppTheme.moduleMath),
        foregroundColor: Colors.white,
        title: Text(
          isMalay ? 'Keputusan 🏆' : 'Results 🏆',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BijakScene(
        topColor: AppTheme.nightTop,
        bottomColor: AppTheme.nightBottom,
        showHills: false,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(
                    msg,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.deepBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Score circle
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.skyBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.skyBlue.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$score/$total',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        Text(
                          isMalay ? 'Betul' : 'Correct',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Answer review (white container)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepBlue.withValues(alpha: 0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: answers.asMap().entries.map((e) {
                        return Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: e.value
                                ? AppTheme.leafGreen
                                : AppTheme.appleRed,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => MathQuizScreen(
                                    op: op,
                                    color: color,
                                    level: level,
                                  ),
                                ),
                              ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(
                            isMalay ? 'Cuba Lagi' : 'Try Again',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.skyBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).popUntil(
                            (r) =>
                                r.settings.name ==
                                    MathPracticeScreen.routeName ||
                                r.isFirst,
                          ),
                          icon: const Icon(Icons.home_rounded),
                          label: Text(
                            isMalay ? 'Menu' : 'Menu',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.skyBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: AppTheme.skyBlue,
                                width: 2,
                              ),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Question generator ────────────────────────────────────────────────────────
enum MathOp {
  count,
  add,
  subtract,
  multiply,
  divide,
  compare,
  missing,
  bond,
  mixed,
}

class _Question {
  const _Question({
    required this.questionText,
    required this.answer,
    required this.options,
    required this.emoji,
    this.hint,
    this.visualCount,
  });

  final String questionText;
  final int answer;
  final List<int> options;
  final String emoji;
  final String? hint;
  final int? visualCount;

  static const _emojis = [
    '🍎',
    '🐘',
    '⭐',
    '🌸',
    '🎈',
    '🍉',
    '🐬',
    '🏆',
    '🌈',
    '🦁',
    '🍊',
    '🐧',
    '🎵',
    '🦋',
    '🍓',
    '🐙',
    '🌻',
    '🎯',
    '🐮',
    '🎀',
  ];

  factory _Question.generate({
    required MathOp op,
    required int level,
    required Random rng,
    required bool isMalay,
  }) {
    const mixedOps = [
      MathOp.count,
      MathOp.add,
      MathOp.subtract,
      MathOp.multiply,
      MathOp.divide,
      MathOp.compare,
      MathOp.missing,
      MathOp.bond,
    ];
    final effectiveOp = op == MathOp.mixed
        ? mixedOps[rng.nextInt(mixedOps.length)]
        : op;

    int a, b, answer;
    String q, hint;
    int? visualCount;
    final seededOptions = <int>{};
    final emoji = _emojis[rng.nextInt(_emojis.length)];

    switch (effectiveOp) {
      case MathOp.count:
        final maxCount = [8, 12, 20][level - 1];
        answer = rng.nextInt(maxCount) + 1;
        q = isMalay ? 'Ada berapa?' : 'How many?';
        hint = isMalay ? 'Kira satu demi satu.' : 'Count them one by one.';
        visualCount = answer;
      case MathOp.add:
        final maxSum = [10, 20, 50][level - 1];
        answer = rng.nextInt(maxSum - 1) + 2;
        a = rng.nextInt(answer - 1) + 1;
        b = answer - a;
        if (level == 3 && rng.nextBool()) {
          a = rng.nextInt(maxSum) + 1;
          b = rng.nextInt(maxSum) + 1;
          answer = a + b;
        }
        q = '$a  +  $b  =  ?';
        hint = '';
      case MathOp.subtract:
        final range = [10, 20, 50][level - 1];
        a = rng.nextInt(range) + 1;
        b = rng.nextInt(a) + 1;
        answer = a - b;
        q = '$a  −  $b  =  ?';
        hint = '';
      case MathOp.multiply:
        final maxT = [5, 5, 10][level - 1];
        a = rng.nextInt(maxT - 1) + 2;
        b = rng.nextInt(maxT) + 1;
        answer = a * b;
        q = '$a  ×  $b  =  ?';
        hint = level == 1
            ? (isMalay ? '$a + $a + ... ($b kali)' : '$a + $a + ... ($b times)')
            : '';
      case MathOp.divide:
        final maxT = [5, 5, 12][level - 1];
        b = rng.nextInt(maxT - 1) + 2;
        answer = rng.nextInt(maxT) + 1;
        a = b * answer;
        q = '$a  ÷  $b  =  ?';
        hint = level == 1
            ? (isMalay
                  ? 'Berapa kumpulan $b dalam $a?'
                  : 'How many groups of $b are in $a?')
            : '';
      case MathOp.compare:
        final range = [10, 20, 50][level - 1];
        a = rng.nextInt(range) + 1;
        do {
          b = rng.nextInt(range) + 1;
        } while (b == a);
        final askBigger = rng.nextBool();
        answer = askBigger ? max(a, b) : min(a, b);
        q = isMalay
            ? 'Pilih nombor yang ${askBigger ? 'lebih besar' : 'lebih kecil'}:\n$a atau $b'
            : 'Pick the ${askBigger ? 'bigger' : 'smaller'} number:\n$a or $b';
        hint = isMalay ? 'Bandingkan dua nombor.' : 'Compare the two numbers.';
        seededOptions
          ..add(a)
          ..add(b);
      case MathOp.missing:
        final stepChoices = switch (level) {
          1 => const [1],
          2 => const [1, 2],
          _ => const [2, 5, 10],
        };
        final step = stepChoices[rng.nextInt(stepChoices.length)];
        final startMax = [7, 14, 35][level - 1];
        final start = rng.nextInt(startMax) + 1;
        final sequence = List.generate(4, (index) => start + index * step);
        final missingIndex = rng.nextInt(2) + 1;
        answer = sequence[missingIndex];
        q = sequence
            .asMap()
            .entries
            .map((entry) => entry.key == missingIndex ? '?' : '${entry.value}')
            .join(',  ');
        hint = isMalay
            ? 'Cari nombor dalam susunan.'
            : 'Find the number in the pattern.';
      case MathOp.bond:
        final target = [5, 10, 20][level - 1];
        a = rng.nextInt(target - 1) + 1;
        answer = target - a;
        q = '$a  +  ?  =  $target';
        hint = isMalay
            ? 'Nombor apa yang melengkapkan $target?'
            : 'What number makes $target?';
      case MathOp.mixed:
        // Should not reach here
        a = 1;
        b = 1;
        answer = 2;
        q = '1 + 1 = ?';
        hint = '';
    }

    // Generate 4 unique options including answer
    final opts = <int>{answer, ...seededOptions.where((value) => value >= 0)};
    while (opts.length < 4) {
      final delta = rng.nextInt(10) + 1;
      final candidate = rng.nextBool() ? answer + delta : answer - delta;
      opts.add(candidate >= 0 ? candidate : rng.nextInt(max(answer + 8, 10)));
    }
    final optList = opts.toList()..shuffle(rng);

    return _Question(
      questionText: q,
      answer: answer,
      options: optList,
      emoji: emoji,
      hint: hint.isEmpty ? null : hint,
      visualCount: visualCount,
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────
class _MathTopic {
  const _MathTopic({
    required this.labelMs,
    required this.labelEn,
    required this.subtitleMs,
    required this.subtitleEn,
    required this.op,
    required this.color,
    required this.icon,
  });

  final String labelMs;
  final String labelEn;
  final String subtitleMs;
  final String subtitleEn;
  final MathOp op;
  final Color color;
  final IconData icon;
}
