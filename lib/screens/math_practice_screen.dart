import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../models/app_language.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/star_counter.dart';

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
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Back',
        ),
        // Hero continues the emoji "flight" from the Learning Path card.
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'module-emoji-${MathPracticeScreen.routeName}',
              child: const Text('🧮', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 8),
            Text(
              isMalay ? 'Latihan Matematik' : 'Maths Practice',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: AppTheme.skyBlue,
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: StarCounter()),
          ),
        ],
      ),
      body: BijakScene(
        topColor: const Color(0xFFE9F8FF),
        bottomColor: AppTheme.lightBlue,
        showHills: false,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.skyBlue, AppTheme.turquoise],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.skyBlue.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🧮', style: TextStyle(fontSize: 52)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMalay
                                ? 'Matematik Prasekolah'
                                : 'Preschool Maths',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isMalay
                                ? 'Pilih topik untuk berlatih!'
                                : 'Choose a topic to practise!',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Level selector hint
              _LevelHintBar(isMalay: isMalay),

              const SizedBox(height: 16),

              // Topic buttons
              ..._topics.map(
                (topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _TopicCard(topic: topic, isMalay: isMalay),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelHintBar extends ConsumerWidget {
  const _LevelHintBar({required this.isMalay});
  final bool isMalay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const levels = [
      (color: Color(0xFF1DD1A1), label: 'Tahap 1', labelEn: 'Level 1'),
      (color: Color(0xFFFF9F43), label: 'Tahap 2', labelEn: 'Level 2'),
      (color: Color(0xFFFF6B6B), label: 'Tahap 3', labelEn: 'Level 3'),
    ];
    return Row(
      children: levels
          .map(
            (l) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: l.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: l.color.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                      isMalay ? l.label : l.labelEn,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: l.color,
                      ),
                    ),
                    Text(
                      isMalay
                          ? (l.label == 'Tahap 1'
                                ? 'Mudah'
                                : l.label == 'Tahap 2'
                                ? 'Sederhana'
                                : 'Susah')
                          : (l.labelEn == 'Level 1'
                                ? 'Easy'
                                : l.labelEn == 'Level 2'
                                ? 'Medium'
                                : 'Hard'),
                      style: TextStyle(
                        fontSize: 10,
                        color: l.color.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TopicCard extends ConsumerWidget {
  const _TopicCard({required this.topic, required this.isMalay});
  final _MathTopic topic;
  final bool isMalay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: topic.color.withValues(alpha: 0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MathQuizScreen(op: topic.op, color: topic.color),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: topic.color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: topic.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(topic.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMalay ? topic.labelMs : topic.labelEn,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: topic.color,
                      ),
                    ),
                    Text(
                      isMalay ? topic.subtitleMs : topic.subtitleEn,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Level chips
                    Row(
                      children: [1, 2, 3]
                          .map(
                            (l) => GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MathQuizScreen(
                                    op: topic.op,
                                    color: topic.color,
                                    level: l,
                                  ),
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: topic.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: topic.color.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  isMalay ? 'Tahap $l' : 'Level $l',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: topic.color,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: topic.color.withValues(alpha: 0.5),
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
  });

  final MathOp op;
  final Color color;
  final int level; // 1=easy, 2=medium, 3=hard

  @override
  ConsumerState<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends ConsumerState<MathQuizScreen>
    with TickerProviderStateMixin {
  static const _totalQuestions = 10;

  final _rng = Random();
  final _answers = <bool>[];
  late _Question _q;

  // tracking
  int _score = 0;
  int _questionIndex = 0;
  bool _answered = false;
  int? _selectedOption;

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

  void _generateQuestion() {
    final isMalay =
        ref.read(progressServiceProvider).language == AppLanguage.malay;
    setState(() {
      _q = _Question.generate(
        op: widget.op,
        level: widget.level,
        rng: _rng,
        isMalay: isMalay,
      );
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
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.skyBlue,
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
        topColor: const Color(0xFFE9F8FF),
        bottomColor: AppTheme.lightBlue,
        showHills: false,
        child: SafeArea(
          child: Column(
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

              const Spacer(),

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
                          Text(_q.emoji, style: const TextStyle(fontSize: 46)),
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

              const Spacer(),

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
                    color: Color.lerp(
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
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.skyBlue,
        foregroundColor: Colors.white,
        title: Text(
          isMalay ? 'Keputusan 🏆' : 'Results 🏆',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BijakScene(
        topColor: const Color(0xFFE9F8FF),
        bottomColor: AppTheme.lightBlue,
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
