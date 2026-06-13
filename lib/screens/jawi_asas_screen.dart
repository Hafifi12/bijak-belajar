import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../models/app_language.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/star_counter.dart';
import 'jawi_trace_screen.dart';

/// Jawi Asas — teaches the 28 Arabic/Jawi letters used in Bahasa Melayu Jawi
/// in a warm, fun style for Malaysian Muslim preschool children.
class JawiAsasScreen extends ConsumerStatefulWidget {
  const JawiAsasScreen({super.key});

  static const routeName = '/jawi-asas';

  @override
  ConsumerState<JawiAsasScreen> createState() => _JawiAsasScreenState();
}

class _JawiAsasScreenState extends ConsumerState<JawiAsasScreen>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  bool _recordedInitial = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  // 28 Jawi / Arabic letters with Malay pronunciation guide and a Malay example word
  static const _jawis = <_JawiItem>[
    _JawiItem(
      jawi: 'ا',
      name: 'Alif',
      example: 'anak',
      exampleJawi: 'اناق',
      emoji: '👶',
    ),
    _JawiItem(
      jawi: 'ب',
      name: 'Ba',
      example: 'buku',
      exampleJawi: 'بوكو',
      emoji: '📚',
    ),
    _JawiItem(
      jawi: 'ت',
      name: 'Ta',
      example: 'tali',
      exampleJawi: 'تالي',
      emoji: '🪢',
    ),
    _JawiItem(
      jawi: 'ث',
      name: 'Tha',
      example: 'thabit',
      exampleJawi: 'ثابت',
      emoji: '⭐',
    ),
    _JawiItem(
      jawi: 'ج',
      name: 'Jim',
      example: 'jambatan',
      exampleJawi: 'جمباتن',
      emoji: '🌉',
    ),
    _JawiItem(
      jawi: 'ح',
      name: 'Ha',
      example: 'hari',
      exampleJawi: 'هاري',
      emoji: '☀️',
    ),
    _JawiItem(
      jawi: 'خ',
      name: 'Kha',
      example: 'khabar',
      exampleJawi: 'خابر',
      emoji: '📰',
    ),
    _JawiItem(
      jawi: 'د',
      name: 'Dal',
      example: 'dapur',
      exampleJawi: 'دافور',
      emoji: '🍳',
    ),
    _JawiItem(
      jawi: 'ذ',
      name: 'Zal',
      example: 'zikir',
      exampleJawi: 'ذكر',
      emoji: '🤲',
    ),
    _JawiItem(
      jawi: 'ر',
      name: 'Ra',
      example: 'rama-rama',
      exampleJawi: 'راما-راما',
      emoji: '🦋',
    ),
    _JawiItem(
      jawi: 'ز',
      name: 'Zai',
      example: 'zaman',
      exampleJawi: 'زامن',
      emoji: '🕰️',
    ),
    _JawiItem(
      jawi: 'س',
      name: 'Sin',
      example: 'singa',
      exampleJawi: 'سيڠا',
      emoji: '🦁',
    ),
    _JawiItem(
      jawi: 'ش',
      name: 'Shin',
      example: 'syukur',
      exampleJawi: 'شكور',
      emoji: '🙏',
    ),
    _JawiItem(
      jawi: 'ص',
      name: 'Sad',
      example: 'sabar',
      exampleJawi: 'صابر',
      emoji: '😌',
    ),
    _JawiItem(
      jawi: 'ض',
      name: 'Dad',
      example: 'darurat',
      exampleJawi: 'ضرورة',
      emoji: '⚠️',
    ),
    _JawiItem(
      jawi: 'ط',
      name: 'Ta (besar)',
      example: 'tabib',
      exampleJawi: 'طبيب',
      emoji: '🏥',
    ),
    _JawiItem(
      jawi: 'ظ',
      name: 'Za (besar)',
      example: 'zalim',
      exampleJawi: 'ظالم',
      emoji: '⚖️',
    ),
    _JawiItem(
      jawi: 'ع',
      name: 'Ain',
      example: 'alam',
      exampleJawi: 'عالم',
      emoji: '🌍',
    ),
    _JawiItem(
      jawi: 'غ',
      name: 'Ghain',
      example: 'ghairah',
      exampleJawi: 'غيره',
      emoji: '🔥',
    ),
    _JawiItem(
      jawi: 'ف',
      name: 'Fa',
      example: 'fajar',
      exampleJawi: 'فجر',
      emoji: '🌅',
    ),
    _JawiItem(
      jawi: 'ق',
      name: 'Qaf',
      example: 'quran',
      exampleJawi: 'قرآن',
      emoji: '📖',
    ),
    _JawiItem(
      jawi: 'ك',
      name: 'Kaf',
      example: 'kucing',
      exampleJawi: 'كوچيڠ',
      emoji: '🐱',
    ),
    _JawiItem(
      jawi: 'ل',
      name: 'Lam',
      example: 'lembu',
      exampleJawi: 'لمبو',
      emoji: '🐄',
    ),
    _JawiItem(
      jawi: 'م',
      name: 'Mim',
      example: 'matahari',
      exampleJawi: 'ماتاهاري',
      emoji: '☀️',
    ),
    _JawiItem(
      jawi: 'ن',
      name: 'Nun',
      example: 'nanas',
      exampleJawi: 'ناناس',
      emoji: '🍍',
    ),
    _JawiItem(
      jawi: 'و',
      name: 'Waw',
      example: 'warna',
      exampleJawi: 'وارنا',
      emoji: '🌈',
    ),
    _JawiItem(
      jawi: 'ه',
      name: 'Ha (kecil)',
      example: 'hujan',
      exampleJawi: 'هوجن',
      emoji: '🌧️',
    ),
    _JawiItem(
      jawi: 'ي',
      name: 'Ya',
      example: 'yatim',
      exampleJawi: 'يتيم',
      emoji: '🤗',
    ),
  ];

  static const _colors = [
    Color(0xFF00897B),
    Color(0xFF039BE5),
    Color(0xFF7B1FA2),
    Color(0xFFE64A19),
    Color(0xFF00ACC1),
    Color(0xFF43A047),
    Color(0xFF3949AB),
  ];

  Color get _color => _colors[_current % _colors.length];

  @override
  void initState() {
    super.initState();
    // Resume at the last Jawi letter the child saw, instead of restarting
    // at alif every session.
    final last = ref.read(progressServiceProvider).getLastLesson('jawi');
    if (last.isNotEmpty) {
      final idx = _jawis.indexWhere((j) => j.jawi == last);
      if (idx >= 0) _current = idx;
    }
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_recordedInitial) {
      _recordedInitial = true;
      _recordCurrentLesson();
    }
  }

  void _next() {
    if (_current < _jawis.length - 1) {
      setState(() => _current++);
      _bounceController.forward(from: 0);
      _recordCurrentLesson();
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() => _current--);
      _bounceController.forward(from: 0);
      _recordCurrentLesson();
    }
  }

  void _recordCurrentLesson() {
    final item = _jawis[_current];
    ref.read(progressServiceProvider).markModuleLesson('jawi', item.jawi);
  }

  Future<void> _speakIn(String word, String locale) async {
    final progress = ref.read(progressServiceProvider);
    final audio = ref.read(audioServiceProvider);
    await audio.speakLocale(
      word,
      enabled: progress.voiceEnabled,
      locale: locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(progressServiceProvider).language;
    final item = _jawis[_current];
    final color = _color;
    final isFirst = _current == 0;
    final isLast = _current == _jawis.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.moduleJawi,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: language == AppLanguage.malay ? 'Kembali' : 'Back',
        ),
        // Hero continues the emoji "flight" from the Learning Path card.
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'module-emoji-${JawiAsasScreen.routeName}',
              child: const Text('🌙', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    language == AppLanguage.malay
                        ? 'Jawi Asas — حروف جاوي'
                        : 'Jawi Letters — حروف جاوي',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_current + 1} / ${_jawis.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
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
              // ── Progress bar ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (_current + 1) / _jawis.length,
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
                        '${_current + 1}/${_jawis.length}',
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
              // ── Instruction ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.center_focus_strong_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          language == AppLanguage.malay
                              ? 'Lihat huruf Jawi, baca namanya, dan sebut contoh perkataan!'
                              : 'See the Jawi letter, read its name, and say the example word!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepBlue.withValues(alpha: 0.14),
                          blurRadius: 18,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Big Jawi letter
                            ScaleTransition(
                              scale: _bounceAnim,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    item.jawi,
                                    style: const TextStyle(
                                      fontSize: 90,
                                      color: Colors.white,
                                      height: 1.2,
                                      fontFamily: 'serif',
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Name
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // ── Trace this letter (Jawi v2) ──
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => JawiTraceScreen(
                                    letter: item.jawi,
                                    letterName: item.name,
                                    color: color,
                                  ),
                                ),
                              ),
                              icon: const Text(
                                '✍️',
                                style: TextStyle(fontSize: 20),
                              ),
                              label: Text(
                                language == AppLanguage.malay
                                    ? 'Jejak Huruf Ini! +⭐'
                                    : 'Trace This Letter! +⭐',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.sunnyYellow,
                                foregroundColor: AppTheme.ink,
                                minimumSize:
                                    const Size.fromHeight(AppTheme.kidTarget),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusLg),
                                ),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Example word row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.emoji,
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.example,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: color,
                                        ),
                                      ),
                                      Text(
                                        item.exampleJawi,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: color.withValues(alpha: 0.8),
                                          fontFamily: 'serif',
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _JawiPronounceButtons(
                              onSpeak: _speakIn,
                              arabicLetter: item.jawi,
                              arabicName: item.name,
                              color: color,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Navigation ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isFirst ? null : _prev,
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        label: Text(
                          language == AppLanguage.malay ? 'Sebelum' : 'Back',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                          side: const BorderSide(
                            color: Colors.white,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLast ? null : _next,
                        label: Text(
                          language == AppLanguage.malay ? 'Seterusnya' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        iconAlignment: IconAlignment.end,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.sunnyYellow,
                          foregroundColor: AppTheme.ink,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 6,
                          side: const BorderSide(
                            color: Colors.white,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (isLast)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '🌙 Alhamdulillah! Semua huruf Jawi dah kenal! ⭐',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JawiPronounceButtons extends ConsumerWidget {
  const _JawiPronounceButtons({
    required this.onSpeak,
    required this.arabicLetter,
    required this.arabicName,
    required this.color,
  });

  final Future<void> Function(String word, String locale) onSpeak;
  final String arabicLetter;
  final String arabicName;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '🔊 Sebut:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        _btn('🇸🇦', 'عربي', arabicLetter, 'ar-SA'),
      ],
    );
  }

  Widget _btn(String flag, String label, String word, String locale) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () => onSpeak(word, locale),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.volume_up_rounded, size: 15, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _JawiItem {
  const _JawiItem({
    required this.jawi,
    required this.name,
    required this.example,
    required this.exampleJawi,
    required this.emoji,
  });

  final String jawi;
  final String name;
  final String example;
  final String exampleJawi;
  final String emoji;
}
