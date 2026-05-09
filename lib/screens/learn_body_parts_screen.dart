import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_language.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/star_counter.dart';

/// Belajar Anggota Badan — Learn Body Parts
/// Malaysian kindergarten style for preschool children.
class LearnBodyPartsScreen extends StatefulWidget {
  const LearnBodyPartsScreen({super.key});

  static const routeName = '/learn-body-parts';

  @override
  State<LearnBodyPartsScreen> createState() => _LearnBodyPartsScreenState();
}

class _LearnBodyPartsScreenState extends State<LearnBodyPartsScreen>
    with TickerProviderStateMixin {
  int _current = 0;
  bool _recordedInitial = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  static const _parts = <_BodyPart>[
    _BodyPart(
      malay: 'Kepala',
      english: 'Head',
      indonesian: 'Kepala',
      mandarin: '头 (Tóu)',
      tamil: 'தலை (Talai)',
      emoji: '🧠',
      bodyEmoji: '👤',
      fun: 'Kepala untuk berfikir!',
      color: Color(0xFFFF6B6B),
      icon: Icons.face_rounded,
    ),
    _BodyPart(
      malay: 'Mata',
      english: 'Eyes',
      indonesian: 'Mata',
      mandarin: '眼睛 (Yǎnjīng)',
      tamil: 'கண்கள் (Kaṇkaḷ)',
      emoji: '👀',
      bodyEmoji: '👁️',
      fun: 'Mata untuk melihat!',
      color: Color(0xFF5F27CD),
      icon: Icons.visibility_rounded,
    ),
    _BodyPart(
      malay: 'Hidung',
      english: 'Nose',
      indonesian: 'Hidung',
      mandarin: '鼻子 (Bízi)',
      tamil: 'மூக்கு (Mūkku)',
      emoji: '👃',
      bodyEmoji: '👃',
      fun: 'Hidung untuk menghidu!',
      color: Color(0xFFFF9F43),
      icon: Icons.air_rounded,
    ),
    _BodyPart(
      malay: 'Mulut',
      english: 'Mouth',
      indonesian: 'Mulut',
      mandarin: '嘴巴 (Zuǐbā)',
      tamil: 'வாய் (Vāy)',
      emoji: '👄',
      bodyEmoji: '👄',
      fun: 'Mulut untuk bercakap dan makan!',
      color: Color(0xFFEE5A24),
      icon: Icons.record_voice_over_rounded,
    ),
    _BodyPart(
      malay: 'Telinga',
      english: 'Ears',
      indonesian: 'Telinga',
      mandarin: '耳朵 (Ěrduǒ)',
      tamil: 'காது (Kātu)',
      emoji: '👂',
      bodyEmoji: '👂',
      fun: 'Telinga untuk mendengar!',
      color: Color(0xFFFECA57),
      icon: Icons.hearing_rounded,
    ),
    _BodyPart(
      malay: 'Rambut',
      english: 'Hair',
      indonesian: 'Rambut',
      mandarin: '头发 (Tóufa)',
      tamil: 'முடி (Muṭi)',
      emoji: '💇',
      bodyEmoji: '🧑',
      fun: 'Rambut tumbuh di atas kepala!',
      color: Color(0xFF8D6E63),
      icon: Icons.face_3_rounded,
    ),
    _BodyPart(
      malay: 'Gigi',
      english: 'Teeth',
      indonesian: 'Gigi',
      mandarin: '牙齿 (Yáchǐ)',
      tamil: 'பற்கள் (Paṟkaḷ)',
      emoji: '🦷',
      bodyEmoji: '😁',
      fun: 'Gigi membantu kita mengunyah makanan!',
      color: Color(0xFF00B894),
      icon: Icons.sentiment_very_satisfied_rounded,
    ),
    _BodyPart(
      malay: 'Bahu',
      english: 'Shoulder',
      indonesian: 'Bahu',
      mandarin: '肩膀 (Jiānbǎng)',
      tamil: 'தோள் (Tōḷ)',
      emoji: '💪',
      bodyEmoji: '🧍',
      fun: 'Bahu di kiri dan kanan badan!',
      color: Color(0xFF0984E3),
      icon: Icons.accessibility_new_rounded,
    ),
    _BodyPart(
      malay: 'Tangan',
      english: 'Hands',
      indonesian: 'Tangan',
      mandarin: '手 (Shǒu)',
      tamil: 'கை (Kai)',
      emoji: '✋',
      bodyEmoji: '🤲',
      fun: 'Tangan untuk melambai dan memegang!',
      color: Color(0xFF6C5CE7),
      icon: Icons.pan_tool_rounded,
    ),
    _BodyPart(
      malay: 'Jari',
      english: 'Fingers',
      indonesian: 'Jari',
      mandarin: '手指 (Shǒuzhǐ)',
      tamil: 'விரல் (Viral)',
      emoji: '☝️',
      bodyEmoji: '🖐️',
      fun: 'Kita ada sepuluh jari!',
      color: Color(0xFFE84393),
      icon: Icons.touch_app_rounded,
    ),
    _BodyPart(
      malay: 'Perut',
      english: 'Stomach',
      indonesian: 'Perut',
      mandarin: '肚子 (Dùzi)',
      tamil: 'வயிறு (Vayiṟu)',
      emoji: '🫃',
      bodyEmoji: '🧍',
      fun: 'Perut menyimpan makanan!',
      color: Color(0xFF00CEC9),
      icon: Icons.circle_rounded,
    ),
    _BodyPart(
      malay: 'Kaki',
      english: 'Legs',
      indonesian: 'Kaki',
      mandarin: '腿 (Tuǐ)',
      tamil: 'கால் (Kāl)',
      emoji: '🦵',
      bodyEmoji: '🦵',
      fun: 'Kaki untuk berlari dan melompat!',
      color: Color(0xFFFF7675),
      icon: Icons.directions_run_rounded,
    ),
    _BodyPart(
      malay: 'Lutut',
      english: 'Knees',
      indonesian: 'Lutut',
      mandarin: '膝盖 (Xīgài)',
      tamil: 'முழங்கால் (Muḻankāl)',
      emoji: '🦿',
      bodyEmoji: '🧎',
      fun: 'Lutut boleh membengkok!',
      color: Color(0xFF636E72),
      icon: Icons.airline_seat_legroom_extra_rounded,
    ),
    _BodyPart(
      malay: 'Kaki (tapak)',
      english: 'Feet',
      indonesian: 'Telapak kaki',
      mandarin: '脚 (Jiǎo)',
      tamil: 'பாதம் (Pātam)',
      emoji: '🦶',
      bodyEmoji: '🦶',
      fun: 'Tapak kaki untuk berdiri!',
      color: Color(0xFF55EFC4),
      icon: Icons.directions_walk_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color get _color => _parts[_current].color;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_recordedInitial) {
      _recordedInitial = true;
      _recordCurrentLesson();
    }
  }

  void _next() {
    if (_current < _parts.length - 1) {
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
    final item = _parts[_current];
    context.read<ProgressService>().markModuleLesson('bodyparts', item.english);
  }

  Future<void> _speakIn(String word, String locale) async {
    final progress = context.read<ProgressService>();
    final audio = context.read<AudioService>();
    await audio.speakLocale(
      word,
      enabled: progress.voiceEnabled,
      locale: locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<ProgressService>().language;
    final item = _parts[_current];
    final color = _color;
    final isMalay = language == AppLanguage.malay;
    final isFirst = _current == 0;
    final isLast = _current == _parts.length - 1;
    final mainWord = item.wordFor(language);

    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.skyBlue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMalay ? 'Anggota Badan 🧍' : 'Body Parts 🧍',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            Text(
              isMalay
                  ? 'Bahagian ${_current + 1} dari ${_parts.length}'
                  : 'Part ${_current + 1} of ${_parts.length}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
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
              // Progress bar + counter pill
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (_current + 1) / _parts.length,
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
                        '${_current + 1}/${_parts.length}',
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

              // Instruction hint
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isMalay
                              ? 'Tunjuk anggota badan kamu! ${item.fun}'
                              : 'Point to yours! ${item.funEnglish}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // White content container
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepBlue.withValues(alpha: 0.14),
                          blurRadius: 18,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          // Big emoji — bounce + pulse
                          ScaleTransition(
                            scale: _bounceAnim,
                            child: ScaleTransition(
                              scale: _pulseAnim,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
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
                                    item.emoji,
                                    style: const TextStyle(fontSize: 72),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Selected language word — BIG
                          Text(
                            mainWord,
                            style: TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          if (mainWord != item.english)
                            Text(
                              item.english,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: color.withValues(alpha: 0.65),
                              ),
                            ),

                          const SizedBox(height: 6),

                          // Mandarin + Tamil row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LangChip(
                                flag: '🇨🇳',
                                text: item.mandarin,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              _LangChip(
                                flag: '🇮🇩',
                                text: item.indonesian,
                                color: color,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _LangChip(
                            flag: '🇮🇳',
                            text: item.tamil,
                            color: color,
                          ),

                          const SizedBox(height: 16),

                          // Pronounce buttons
                          _BodyPronounceButtons(
                            onSpeak: _speakIn,
                            item: item,
                            color: color,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isFirst ? null : _prev,
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        label: Text(
                          isMalay ? 'Sebelum' : 'Back',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLast ? null : _next,
                        label: Text(
                          isMalay ? 'Seterusnya' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        iconAlignment: IconAlignment.end,
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
                  ],
                ),
              ),

              if (isLast)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    '🎉 Tahniah! Kamu dah kenal semua anggota badan! 🧍',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepBlue,
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

/// Small chip showing a flag + translated word.
class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.flag,
    required this.text,
    required this.color,
  });

  final String flag;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyPronounceButtons extends StatelessWidget {
  const _BodyPronounceButtons({
    required this.onSpeak,
    required this.item,
    required this.color,
  });

  final Future<void> Function(String word, String locale) onSpeak;
  final _BodyPart item;
  final Color color;

  static const _langs = [
    (flag: '🇲🇾', label: 'BM', locale: 'ms-MY'),
    (flag: '🇬🇧', label: 'EN', locale: 'en-US'),
    (flag: '🇨🇳', label: '中文', locale: 'zh-CN'),
    (flag: '🇮🇩', label: 'ID', locale: 'id-ID'),
    (flag: '🇮🇳', label: 'தமிழ்', locale: 'ta-IN'),
  ];

  String _wordFor(String locale) {
    switch (locale) {
      case 'ms-MY':
        return item.malay;
      case 'en-US':
        return item.english;
      case 'zh-CN':
        return item.mandarin;
      case 'id-ID':
        return item.indonesian;
      case 'ta-IN':
        return item.tamil;
      default:
        return item.english;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '🔊 Sebut dalam:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _langs.map((l) {
            return Material(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => onSpeak(_wordFor(l.locale), l.locale),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
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
                      Text(l.flag, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        l.label,
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
          }).toList(),
        ),
      ],
    );
  }
}

class _BodyPart {
  const _BodyPart({
    required this.malay,
    required this.english,
    required this.indonesian,
    required this.mandarin,
    required this.tamil,
    required this.emoji,
    required this.bodyEmoji,
    required this.fun,
    required this.color,
    required this.icon,
  });

  final String malay;
  final String english;
  final String indonesian;
  final String mandarin;
  final String tamil;
  final String emoji;
  final String bodyEmoji;
  final String fun;
  final Color color;
  final IconData icon;

  String wordFor(AppLanguage language) {
    return switch (language) {
      AppLanguage.malay => malay,
      AppLanguage.english => english,
      AppLanguage.mandarin => mandarin,
      AppLanguage.tamil => tamil,
      AppLanguage.indonesian => indonesian,
    };
  }

  String get funEnglish => 'Say "$english" and point gently.';
}
