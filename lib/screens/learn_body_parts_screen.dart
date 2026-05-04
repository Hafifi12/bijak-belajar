import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_language.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';

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
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  static const _parts = <_BodyPart>[
    _BodyPart(
      malay: 'Kepala',
      english: 'Head',
      arabic: 'رأس',
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
      arabic: 'عيون',
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
      arabic: 'أنف',
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
      arabic: 'فم',
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
      english: 'Ear',
      arabic: 'أذن',
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
      arabic: 'شعر',
      mandarin: '头发 (Tóufa)',
      tamil: 'முடி (Muṭi)',
      emoji: '💇',
      bodyEmoji: '🧑',
      fun: 'Rambut tumbuh di atas kepala!',
      color: Color(0xFF8D6E63),
      icon: Icons.face_3_rounded,
    ),
    _BodyPart(
      malay: 'Leher',
      english: 'Neck',
      arabic: 'رقبة',
      mandarin: '脖子 (Bózi)',
      tamil: 'கழுத்து (Kaḻuttu)',
      emoji: '🦒',
      bodyEmoji: '🧍',
      fun: 'Leher menyambung kepala dengan badan!',
      color: Color(0xFF00B894),
      icon: Icons.sentiment_satisfied_alt_rounded,
    ),
    _BodyPart(
      malay: 'Bahu',
      english: 'Shoulder',
      arabic: 'كتف',
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
      english: 'Hand',
      arabic: 'يد',
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
      english: 'Finger',
      arabic: 'أصبع',
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
      english: 'Tummy',
      arabic: 'بطن',
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
      english: 'Leg',
      arabic: 'رِجل',
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
      english: 'Knee',
      arabic: 'ركبة',
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
      english: 'Foot',
      arabic: 'قدم',
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

  void _next() {
    if (_current < _parts.length - 1) {
      setState(() => _current++);
      _bounceController.forward(from: 0);
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() => _current--);
      _bounceController.forward(from: 0);
    }
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

    return Scaffold(
      backgroundColor: color.withValues(alpha: 0.07),
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(
          isMalay ? 'Anggota Badan 🧍' : 'Body Parts 🧍',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: List.generate(_parts.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _current ? 24 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: i == _current
                            ? color
                            : color.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Main card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(color: color, width: 3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        // Big emoji with bounce
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

                        const SizedBox(height: 14),

                        // Malay word — BIG
                        Text(
                          item.malay,
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: color,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // English word
                        Text(
                          item.english,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: color.withValues(alpha: 0.65),
                          ),
                        ),

                        // Arabic word
                        Text(
                          item.arabic,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: color.withValues(alpha: 0.55),
                          ),
                          textDirection: TextDirection.rtl,
                        ),

                        const SizedBox(height: 14),

                        // Fun fact bubble
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lightbulb_rounded,
                                color: color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  item.fun,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Body pointer icon
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, color: color, size: 32),
                            const SizedBox(width: 8),
                            Text(
                              isMalay
                                  ? 'Tunjuk anggota badan kamu!'
                                  : 'Point to yours!',
                              style: TextStyle(
                                fontSize: 14,
                                color: color.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // 5-language pronounce buttons
                        _BodyPronounceButtons(
                          onSpeak: _speakIn,
                          item: item,
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Navigation
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
                        backgroundColor: color,
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
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
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
    (flag: '🇸🇦', label: 'عربي', locale: 'ar-SA'),
    (flag: '🇮🇳', label: 'தமிழ்', locale: 'ta-IN'),
  ];

  String _wordFor(String locale) {
    switch (locale) {
      case 'ms-MY': return item.malay;
      case 'en-US': return item.english;
      case 'zh-CN': return item.mandarin;
      case 'ar-SA': return item.arabic;
      case 'ta-IN': return item.tamil;
      default: return item.english;
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
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
    required this.arabic,
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
  final String arabic;
  final String mandarin;
  final String tamil;
  final String emoji;
  final String bodyEmoji;
  final String fun;
  final Color color;
  final IconData icon;
}
