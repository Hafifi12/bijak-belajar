import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_language.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';

class LearnNumbersScreen extends StatefulWidget {
  const LearnNumbersScreen({super.key});

  static const routeName = '/learn-numbers';

  @override
  State<LearnNumbersScreen> createState() => _LearnNumbersScreenState();
}

class _LearnNumbersScreenState extends State<LearnNumbersScreen>
    with TickerProviderStateMixin {
  int _current = 0;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── 1–100 number list generated at startup ─────────────────────
  static final List<_NumberItem> _numbers = List.generate(100, (i) {
    final n = i + 1;
    return _NumberItem(
      number: n,
      emoji: _emoji(n),
      malay: _malay(n),
      english: _english(n),
      mandarin: _mandarin(n),
      tamil: _tamil(n),
      indonesian: _indonesian(n),
      color: _color(n),
    );
  });

  static Color _color(int n) {
    const palette = [
      Color(0xFFFF6B6B), Color(0xFFFF9F43), Color(0xFFFECA57),
      Color(0xFF1DD1A1), Color(0xFF48DBFB), Color(0xFF5F27CD),
      Color(0xFF6C5CE7), Color(0xFFFF7675), Color(0xFF00B894),
      Color(0xFFFDCB6E),
    ];
    return palette[(n - 1) % palette.length];
  }

  static const _emojis = [
    '🌟','🦋','🐣','🌸','🐟','🍎','🌈','🐙','🌺','🌙',
    '🎈','🐬','🌻','🦁','🍓','🐦','⭐','🦄','🎵','🍇',
    '🐘','🌴','🎀','🦊','🍊','🐧','🌊','🎯','🐝','🌵',
    '🏆','🦋','🐠','🌷','🎪','🦅','🍕','🐳','🌺','🎭',
    '🦒','🌿','🎸','🐢','🍉','🦜','🏄','🌍','🎨','🐮',
    '🎃','🦁','🌀','🐲','🍋','🦩','🏔','🌙','🎠','🦝',
    '🌈','🐯','🎋','🦚','🍑','🐺','🏡','🌟','🎡','🦭',
    '🎯','🐻','🌺','🦋','🍒','🐿','🏰','⭐','🎢','🦦',
    '🎪','🦊','🌸','🐬','🍓','🦁','🏯','🌙','🎨','🦅',
    '🎵','🐝','🌻','🦄','🍇','🐦','🏆','🌈','🎀','🌟',
  ];
  static String _emoji(int n) => _emojis[(n - 1) % _emojis.length];

  static String _malay(int n) {
    const ones = ['','satu','dua','tiga','empat','lima','enam','tujuh','lapan','sembilan',
      'sepuluh','sebelas','dua belas','tiga belas','empat belas','lima belas',
      'enam belas','tujuh belas','lapan belas','sembilan belas'];
    const tens = ['','','dua puluh','tiga puluh','empat puluh','lima puluh',
      'enam puluh','tujuh puluh','lapan puluh','sembilan puluh'];
    if (n == 100) return 'seratus';
    if (n < 20) return ones[n];
    final o = n % 10 == 0 ? '' : ' ${ones[n % 10]}';
    return '${tens[n ~/ 10]}$o';
  }

  static String _english(int n) {
    const ones = ['','one','two','three','four','five','six','seven','eight','nine',
      'ten','eleven','twelve','thirteen','fourteen','fifteen','sixteen',
      'seventeen','eighteen','nineteen'];
    const tens = ['','','twenty','thirty','forty','fifty','sixty','seventy','eighty','ninety'];
    if (n == 100) return 'one hundred';
    if (n < 20) return ones[n];
    final o = n % 10 == 0 ? '' : '-${ones[n % 10]}';
    return '${tens[n ~/ 10]}$o';
  }

  static String _mandarin(int n) {
    const d = ['','一','二','三','四','五','六','七','八','九'];
    if (n == 10) return '十';
    if (n == 100) return '一百';
    if (n < 10) return d[n];
    if (n < 20) return '十${n % 10 == 0 ? "" : d[n % 10]}';
    final o = n % 10 == 0 ? '' : d[n % 10];
    return '${d[n ~/ 10]}十$o';
  }

  static String _tamil(int n) {
    const t = [
      '','ஒன்று','இரண்டு','மூன்று','நான்கு','ஐந்து','ஆறு','ஏழு','எட்டு','ஒன்பது',
      'பத்து','பதினொன்று','பன்னிரண்டு','பதின்மூன்று','பதினான்கு','பதினைந்து',
      'பதினாறு','பதினேழு','பதினெட்டு','பத்தொன்பது','இருபது',
      'இருபத்தொன்று','இருபத்திரண்டு','இருபத்துமூன்று','இருபத்துநான்கு','இருபத்தைந்து',
      'இருபத்தாறு','இருபத்தேழு','இருபத்தெட்டு','இருபத்தொன்பது','முப்பது',
      'முப்பத்தொன்று','முப்பத்திரண்டு','முப்பத்துமூன்று','முப்பத்துநான்கு','முப்பத்தைந்து',
      'முப்பத்தாறு','முப்பத்தேழு','முப்பத்தெட்டு','முப்பத்தொன்பது','நாற்பது',
      'நாற்பத்தொன்று','நாற்பத்திரண்டு','நாற்பத்துமூன்று','நாற்பத்துநான்கு','நாற்பத்தைந்து',
      'நாற்பத்தாறு','நாற்பத்தேழு','நாற்பத்தெட்டு','நாற்பத்தொன்பது','ஐம்பது',
      'ஐம்பத்தொன்று','ஐம்பத்திரண்டு','ஐம்பத்துமூன்று','ஐம்பத்துநான்கு','ஐம்பத்தைந்து',
      'ஐம்பத்தாறு','ஐம்பத்தேழு','ஐம்பத்தெட்டு','ஐம்பத்தொன்பது','அறுபது',
      'அறுபத்தொன்று','அறுபத்திரண்டு','அறுபத்துமூன்று','அறுபத்துநான்கு','அறுபத்தைந்து',
      'அறுபத்தாறு','அறுபத்தேழு','அறுபத்தெட்டு','அறுபத்தொன்பது','எழுபது',
      'எழுபத்தொன்று','எழுபத்திரண்டு','எழுபத்துமூன்று','எழுபத்துநான்கு','எழுபத்தைந்து',
      'எழுபத்தாறு','எழுபத்தேழு','எழுபத்தெட்டு','எழுபத்தொன்பது','எண்பது',
      'எண்பத்தொன்று','எண்பத்திரண்டு','எண்பத்துமூன்று','எண்பத்துநான்கு','எண்பத்தைந்து',
      'எண்பத்தாறு','எண்பத்தேழு','எண்பத்தெட்டு','எண்பத்தொன்பது','தொண்ணூறு',
      'தொண்ணூற்றொன்று','தொண்ணூற்றிரண்டு','தொண்ணூற்றுமூன்று','தொண்ணூற்றுநான்கு',
      'தொண்ணூற்றைந்து','தொண்ணூற்றாறு','தொண்ணூற்றேழு','தொண்ணூற்றெட்டு',
      'தொண்ணூற்றொன்பது','நூறு',
    ];
    return n < t.length ? t[n] : '$n';
  }

  static String _indonesian(int n) {
    const ones = ['','satu','dua','tiga','empat','lima','enam','tujuh','delapan','sembilan',
      'sepuluh','sebelas','dua belas','tiga belas','empat belas','lima belas',
      'enam belas','tujuh belas','delapan belas','sembilan belas'];
    const tens = ['','','dua puluh','tiga puluh','empat puluh','lima puluh',
      'enam puluh','tujuh puluh','delapan puluh','sembilan puluh'];
    if (n == 100) return 'seratus';
    if (n < 20) return ones[n];
    final o = n % 10 == 0 ? '' : ' ${ones[n % 10]}';
    return '${tens[n ~/ 10]}$o';
  }

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _numbers.length - 1) {
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
    final item = _numbers[_current];
    final color = item.color;
    final isMalay = language == AppLanguage.malay;
    final isFirst = _current == 0;
    final isLast = _current == _numbers.length - 1;
    final showDots = _current < 20; // dots only for 1–20

    return Scaffold(
      backgroundColor: color.withValues(alpha: 0.07),
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(
          isMalay ? 'Belajar Nombor 1–100' : 'Learn Numbers 1–100',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_current + 1) / _numbers.length,
                  minHeight: 10,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            Text(
              '${_current + 1} / ${_numbers.length}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),

            // Main card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(color: color, width: 3),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Column(
                      children: [
                        // Big animated number circle
                        ScaleTransition(
                          scale: _bounceAnim,
                          child: ScaleTransition(
                            scale: _pulseAnim,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 18,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${item.number}',
                                  style: TextStyle(
                                    fontSize: item.number >= 100 ? 52 : 70,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Emoji
                        Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 46),
                        ),

                        const SizedBox(height: 10),

                        // 5-language table
                        _WordTable(item: item, color: color),

                        // Counting dots (1–20)
                        if (showDots) ...[
                          const SizedBox(height: 12),
                          _DotsDisplay(count: item.number, color: color),
                        ],

                        const SizedBox(height: 14),

                        // 5-language pronunciation buttons
                        _NumberPronounceButtons(
                          onSpeak: _speakIn,
                          item: item,
                          color: color,
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

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
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLast ? null : _next,
                      label: Text(
                        isMalay ? 'Seterusnya' : 'Next',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      iconAlignment: IconAlignment.end,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
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
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '🎉 Tahniah! Kamu dah kenal nombor 1–100! 🎉',
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

// ── 5-Language word table ──────────────────────────────────────────────────────
class _WordTable extends StatelessWidget {
  const _WordTable({required this.item, required this.color});
  final _NumberItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('🇲🇾', 'Melayu', item.malay),
      ('🇬🇧', 'English', item.english),
      ('🇨🇳', '中文', item.mandarin),
      ('🇮🇳', 'தமிழ்', item.tamil),
      ('🇮🇩', 'Indonesia', item.indonesian),
    ];
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          final (flag, lang, word) = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 74,
                      child: Text(
                        lang,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        word,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: color.withValues(alpha: 0.15),
                  indent: 14,
                  endIndent: 14,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Counting dots (shown for 1–20) ────────────────────────────────────────────
class _DotsDisplay extends StatelessWidget {
  const _DotsDisplay({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    var remaining = count;
    while (remaining > 0) {
      final rowCount = remaining > 5 ? 5 : remaining;
      remaining -= rowCount;
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              rowCount,
              (_) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}

// ── 5-language number pronounce buttons ───────────────────────────────────────
class _NumberPronounceButtons extends StatelessWidget {
  const _NumberPronounceButtons({
    required this.onSpeak,
    required this.item,
    required this.color,
  });

  final Future<void> Function(String word, String locale) onSpeak;
  final _NumberItem item;
  final Color color;

  static String _arabic(int n) {
    const words = [
      '', 'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة',
      'أحد عشر', 'اثنا عشر', 'ثلاثة عشر', 'أربعة عشر', 'خمسة عشر', 'ستة عشر', 'سبعة عشر',
      'ثمانية عشر', 'تسعة عشر', 'عشرون', 'واحد وعشرون', 'اثنان وعشرون', 'ثلاثة وعشرون',
      'أربعة وعشرون', 'خمسة وعشرون', 'ستة وعشرون', 'سبعة وعشرون', 'ثمانية وعشرون', 'تسعة وعشرون',
      'ثلاثون', 'واحد وثلاثون', 'اثنان وثلاثون', 'ثلاثة وثلاثون', 'أربعة وثلاثون', 'خمسة وثلاثون',
      'ستة وثلاثون', 'سبعة وثلاثون', 'ثمانية وثلاثون', 'تسعة وثلاثون', 'أربعون',
      'واحد وأربعون', 'اثنان وأربعون', 'ثلاثة وأربعون', 'أربعة وأربعون', 'خمسة وأربعون',
      'ستة وأربعون', 'سبعة وأربعون', 'ثمانية وأربعون', 'تسعة وأربعون', 'خمسون',
      'واحد وخمسون', 'اثنان وخمسون', 'ثلاثة وخمسون', 'أربعة وخمسون', 'خمسة وخمسون',
      'ستة وخمسون', 'سبعة وخمسون', 'ثمانية وخمسون', 'تسعة وخمسون', 'ستون',
      'واحد وستون', 'اثنان وستون', 'ثلاثة وستون', 'أربعة وستون', 'خمسة وستون',
      'ستة وستون', 'سبعة وستون', 'ثمانية وستون', 'تسعة وستون', 'سبعون',
      'واحد وسبعون', 'اثنان وسبعون', 'ثلاثة وسبعون', 'أربعة وسبعون', 'خمسة وسبعون',
      'ستة وسبعون', 'سبعة وسبعون', 'ثمانية وسبعون', 'تسعة وسبعون', 'ثمانون',
      'واحد وثمانون', 'اثنان وثمانون', 'ثلاثة وثمانون', 'أربعة وثمانون', 'خمسة وثمانون',
      'ستة وثمانون', 'سبعة وثمانون', 'ثمانية وثمانون', 'تسعة وثمانون', 'تسعون',
      'واحد وتسعون', 'اثنان وتسعون', 'ثلاثة وتسعون', 'أربعة وتسعون', 'خمسة وتسعون',
      'ستة وتسعون', 'سبعة وتسعون', 'ثمانية وتسعون', 'تسعة وتسعون', 'مئة',
    ];
    return n < words.length ? words[n] : '$n';
  }

  @override
  Widget build(BuildContext context) {
    final langs = [
      (flag: '🇲🇾', label: 'BM', word: item.malay, locale: 'ms-MY'),
      (flag: '🇬🇧', label: 'EN', word: item.english, locale: 'en-US'),
      (flag: '🇨🇳', label: '中文', word: item.mandarin, locale: 'zh-CN'),
      (flag: '🇸🇦', label: 'عربي', word: _arabic(item.number), locale: 'ar-SA'),
      (flag: '🇮🇳', label: 'தமிழ்', word: item.tamil, locale: 'ta-IN'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '🔊 Sebut dalam:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: langs.map((l) {
            return Material(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => onSpeak(l.word, l.locale),
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
                      Text(l.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
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

// ── Data model ────────────────────────────────────────────────────────────────
class _NumberItem {
  const _NumberItem({
    required this.number,
    required this.emoji,
    required this.malay,
    required this.english,
    required this.mandarin,
    required this.tamil,
    required this.indonesian,
    required this.color,
  });

  final int number;
  final String emoji;
  final String malay;
  final String english;
  final String mandarin;
  final String tamil;
  final String indonesian;
  final Color color;
}
