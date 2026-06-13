import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../models/app_language.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/star_counter.dart';
import '../widgets/xp_popup.dart';

class LearnNumbersScreen extends ConsumerStatefulWidget {
  const LearnNumbersScreen({super.key});

  static const routeName = '/learn-numbers';

  @override
  ConsumerState<LearnNumbersScreen> createState() => _LearnNumbersScreenState();
}

class _LearnNumbersScreenState extends ConsumerState<LearnNumbersScreen>
    with TickerProviderStateMixin {
  int _current = 0;
  bool _recordedInitial = false;
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
      Color(0xFFFF6B6B),
      Color(0xFFFF9F43),
      Color(0xFFFECA57),
      Color(0xFF1DD1A1),
      Color(0xFF48DBFB),
      Color(0xFF5F27CD),
      Color(0xFF6C5CE7),
      Color(0xFFFF7675),
      Color(0xFF00B894),
      Color(0xFFFDCB6E),
    ];
    return palette[(n - 1) % palette.length];
  }

  static const _emojis = [
    '🌟',
    '🦋',
    '🐣',
    '🌸',
    '🐟',
    '🍎',
    '🌈',
    '🐙',
    '🌺',
    '🌙',
    '🎈',
    '🐬',
    '🌻',
    '🦁',
    '🍓',
    '🐦',
    '⭐',
    '🦄',
    '🎵',
    '🍇',
    '🐘',
    '🌴',
    '🎀',
    '🦊',
    '🍊',
    '🐧',
    '🌊',
    '🎯',
    '🐝',
    '🌵',
    '🏆',
    '🦋',
    '🐠',
    '🌷',
    '🎪',
    '🦅',
    '🍕',
    '🐳',
    '🌺',
    '🎭',
    '🦒',
    '🌿',
    '🎸',
    '🐢',
    '🍉',
    '🦜',
    '🏄',
    '🌍',
    '🎨',
    '🐮',
    '🎃',
    '🦁',
    '🌀',
    '🐲',
    '🍋',
    '🦩',
    '🏔',
    '🌙',
    '🎠',
    '🦝',
    '🌈',
    '🐯',
    '🎋',
    '🦚',
    '🍑',
    '🐺',
    '🏡',
    '🌟',
    '🎡',
    '🦭',
    '🎯',
    '🐻',
    '🌺',
    '🦋',
    '🍒',
    '🐿',
    '🏰',
    '⭐',
    '🎢',
    '🦦',
    '🎪',
    '🦊',
    '🌸',
    '🐬',
    '🍓',
    '🦁',
    '🏯',
    '🌙',
    '🎨',
    '🦅',
    '🎵',
    '🐝',
    '🌻',
    '🦄',
    '🍇',
    '🐦',
    '🏆',
    '🌈',
    '🎀',
    '🌟',
  ];
  static String _emoji(int n) => _emojis[(n - 1) % _emojis.length];

  static String _malay(int n) {
    const ones = [
      '',
      'satu',
      'dua',
      'tiga',
      'empat',
      'lima',
      'enam',
      'tujuh',
      'lapan',
      'sembilan',
      'sepuluh',
      'sebelas',
      'dua belas',
      'tiga belas',
      'empat belas',
      'lima belas',
      'enam belas',
      'tujuh belas',
      'lapan belas',
      'sembilan belas',
    ];
    const tens = [
      '',
      '',
      'dua puluh',
      'tiga puluh',
      'empat puluh',
      'lima puluh',
      'enam puluh',
      'tujuh puluh',
      'lapan puluh',
      'sembilan puluh',
    ];
    if (n == 100) return 'seratus';
    if (n < 20) return ones[n];
    final o = n % 10 == 0 ? '' : ' ${ones[n % 10]}';
    return '${tens[n ~/ 10]}$o';
  }

  static String _english(int n) {
    const ones = [
      '',
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
      'ten',
      'eleven',
      'twelve',
      'thirteen',
      'fourteen',
      'fifteen',
      'sixteen',
      'seventeen',
      'eighteen',
      'nineteen',
    ];
    const tens = [
      '',
      '',
      'twenty',
      'thirty',
      'forty',
      'fifty',
      'sixty',
      'seventy',
      'eighty',
      'ninety',
    ];
    if (n == 100) return 'one hundred';
    if (n < 20) return ones[n];
    final o = n % 10 == 0 ? '' : '-${ones[n % 10]}';
    return '${tens[n ~/ 10]}$o';
  }

  static String _mandarin(int n) {
    const d = ['', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
    if (n == 10) return '十';
    if (n == 100) return '一百';
    if (n < 10) return d[n];
    if (n < 20) return '十${n % 10 == 0 ? "" : d[n % 10]}';
    final o = n % 10 == 0 ? '' : d[n % 10];
    return '${d[n ~/ 10]}十$o';
  }

  static String _tamil(int n) {
    const t = [
      '',
      'ஒன்று',
      'இரண்டு',
      'மூன்று',
      'நான்கு',
      'ஐந்து',
      'ஆறு',
      'ஏழு',
      'எட்டு',
      'ஒன்பது',
      'பத்து',
      'பதினொன்று',
      'பன்னிரண்டு',
      'பதின்மூன்று',
      'பதினான்கு',
      'பதினைந்து',
      'பதினாறு',
      'பதினேழு',
      'பதினெட்டு',
      'பத்தொன்பது',
      'இருபது',
      'இருபத்தொன்று',
      'இருபத்திரண்டு',
      'இருபத்துமூன்று',
      'இருபத்துநான்கு',
      'இருபத்தைந்து',
      'இருபத்தாறு',
      'இருபத்தேழு',
      'இருபத்தெட்டு',
      'இருபத்தொன்பது',
      'முப்பது',
      'முப்பத்தொன்று',
      'முப்பத்திரண்டு',
      'முப்பத்துமூன்று',
      'முப்பத்துநான்கு',
      'முப்பத்தைந்து',
      'முப்பத்தாறு',
      'முப்பத்தேழு',
      'முப்பத்தெட்டு',
      'முப்பத்தொன்பது',
      'நாற்பது',
      'நாற்பத்தொன்று',
      'நாற்பத்திரண்டு',
      'நாற்பத்துமூன்று',
      'நாற்பத்துநான்கு',
      'நாற்பத்தைந்து',
      'நாற்பத்தாறு',
      'நாற்பத்தேழு',
      'நாற்பத்தெட்டு',
      'நாற்பத்தொன்பது',
      'ஐம்பது',
      'ஐம்பத்தொன்று',
      'ஐம்பத்திரண்டு',
      'ஐம்பத்துமூன்று',
      'ஐம்பத்துநான்கு',
      'ஐம்பத்தைந்து',
      'ஐம்பத்தாறு',
      'ஐம்பத்தேழு',
      'ஐம்பத்தெட்டு',
      'ஐம்பத்தொன்பது',
      'அறுபது',
      'அறுபத்தொன்று',
      'அறுபத்திரண்டு',
      'அறுபத்துமூன்று',
      'அறுபத்துநான்கு',
      'அறுபத்தைந்து',
      'அறுபத்தாறு',
      'அறுபத்தேழு',
      'அறுபத்தெட்டு',
      'அறுபத்தொன்பது',
      'எழுபது',
      'எழுபத்தொன்று',
      'எழுபத்திரண்டு',
      'எழுபத்துமூன்று',
      'எழுபத்துநான்கு',
      'எழுபத்தைந்து',
      'எழுபத்தாறு',
      'எழுபத்தேழு',
      'எழுபத்தெட்டு',
      'எழுபத்தொன்பது',
      'எண்பது',
      'எண்பத்தொன்று',
      'எண்பத்திரண்டு',
      'எண்பத்துமூன்று',
      'எண்பத்துநான்கு',
      'எண்பத்தைந்து',
      'எண்பத்தாறு',
      'எண்பத்தேழு',
      'எண்பத்தெட்டு',
      'எண்பத்தொன்பது',
      'தொண்ணூறு',
      'தொண்ணூற்றொன்று',
      'தொண்ணூற்றிரண்டு',
      'தொண்ணூற்றுமூன்று',
      'தொண்ணூற்றுநான்கு',
      'தொண்ணூற்றைந்து',
      'தொண்ணூற்றாறு',
      'தொண்ணூற்றேழு',
      'தொண்ணூற்றெட்டு',
      'தொண்ணூற்றொன்பது',
      'நூறு',
    ];
    return n < t.length ? t[n] : '$n';
  }

  static String _indonesian(int n) {
    const ones = [
      '',
      'satu',
      'dua',
      'tiga',
      'empat',
      'lima',
      'enam',
      'tujuh',
      'delapan',
      'sembilan',
      'sepuluh',
      'sebelas',
      'dua belas',
      'tiga belas',
      'empat belas',
      'lima belas',
      'enam belas',
      'tujuh belas',
      'delapan belas',
      'sembilan belas',
    ];
    const tens = [
      '',
      '',
      'dua puluh',
      'tiga puluh',
      'empat puluh',
      'lima puluh',
      'enam puluh',
      'tujuh puluh',
      'delapan puluh',
      'sembilan puluh',
    ];
    if (n == 100) return 'seratus';
    if (n < 20) return ones[n];
    final o = n % 10 == 0 ? '' : ' ${ones[n % 10]}';
    return '${tens[n ~/ 10]}$o';
  }

  @override
  void initState() {
    super.initState();
    // Resume where the child left off — restarting a 100-card journey at
    // number 1 on every open was the app's single biggest re-entry friction.
    final last = ref.read(progressServiceProvider).getLastLesson('numbers');
    final lastNum = int.tryParse(last);
    if (lastNum != null && lastNum >= 1 && lastNum <= _numbers.length) {
      _current = lastNum - 1;
    }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_recordedInitial) {
      _recordedInitial = true;
      _recordCurrentLesson();
    }
  }

  void _next() {
    if (_current < _numbers.length - 1) {
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

  /// Band finish lines — reaching these for the first time pays a bonus, so
  /// the 100-card journey has mid-way payoffs instead of one long grind.
  static const _bandEnds = {10, 20, 50, 100};

  void _recordCurrentLesson() {
    final ps = ref.read(progressServiceProvider);
    final item = _numbers[_current];
    final isNewBandEnd = _bandEnds.contains(item.number) &&
        !ps.hasSeenLesson('numbers', '${item.number}');
    ps.markModuleLesson('numbers', '${item.number}');
    if (isNewBandEnd) {
      _celebrateBand(item.number);
    } else {
      // TTS: narrate the number and its name on every card load
      _speakCurrentLesson();
    }
  }

  Future<void> _celebrateBand(int n) async {
    final ps = ref.read(progressServiceProvider);
    await ps.addStars(5);
    if (!mounted) return;
    XpPopup.show(context, amount: 5);
    _bounceController.forward(from: 0);
    final isMalay = ps.language == AppLanguage.malay;
    await ref.read(audioServiceProvider).speakLocale(
          isMalay
              ? 'Hebat! Kamu sudah sampai nombor $n! Lima bintang bonus!'
              : 'Amazing! You reached number $n! Five bonus stars!',
          enabled: ps.voiceEnabled,
          locale: isMalay ? 'ms-MY' : 'en-US',
        );
  }

  Future<void> _speakCurrentLesson() async {
    final ps = ref.read(progressServiceProvider);
    if (!ps.voiceEnabled) return;
    final item = _numbers[_current];
    final audio = ref.read(audioServiceProvider);
    final lang = ps.language;
    // Speak the numeral in the app language — an English "five" inside a
    // Malay lesson is exactly the mixed-pronunciation bug parents flagged.
    await audio.speakLocale(
      '${item.number}',
      enabled: true,
      locale: lang.ttsLocale,
    );
    await Future.delayed(const Duration(milliseconds: 420));
    await audio.speakLocale(
      _wordForLanguage(item, lang),
      enabled: true,
      locale: lang.ttsLocale,
    );
  }

  String _wordForLanguage(_NumberItem item, AppLanguage language) {
    return switch (language) {
      AppLanguage.malay => item.malay,
      AppLanguage.english => item.english,
      AppLanguage.mandarin => item.mandarin,
      AppLanguage.tamil => item.tamil,
      AppLanguage.indonesian => item.indonesian,
    };
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

  String _levelLabel(int n, bool isMalay) {
    if (n <= 10) {
      return isMalay ? 'Tahap 1: Nombor 1–10' : 'Level 1: Numbers 1–10';
    }
    if (n <= 20) {
      return isMalay ? 'Tahap 2: Nombor 11–20' : 'Level 2: Numbers 11–20';
    }
    if (n <= 50) {
      return isMalay ? 'Tahap 3: Nombor 21–50' : 'Level 3: Numbers 21–50';
    }
    return isMalay ? 'Tahap 4: Nombor 51–100' : 'Level 4: Numbers 51–100';
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(progressServiceProvider).language;
    final item = _numbers[_current];
    final color = item.color;
    final isMalay = language == AppLanguage.malay;
    final isFirst = _current == 0;
    final isLast = _current == _numbers.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        // Module identity color — must match the Numbers tile on Home and
        // the Learning Path card so pre-readers know where they are.
        backgroundColor: AppTheme.moduleNumbers,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: isMalay ? 'Kembali' : 'Back',
        ),
        // Hero continues the emoji "flight" from the Learning Path card.
        // Moved from leading into the title row so the back button can occupy leading.
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'module-emoji-${LearnNumbersScreen.routeName}',
              child: const Text('🔢', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isMalay ? 'Nombor 1–100' : 'Numbers 1–100',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _levelLabel(_current + 1, isMalay),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
              // Progress bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (_current + 1) / _numbers.length,
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
                        '${_current + 1}/100',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _FocusInstruction(
                  color: color,
                  text: isMalay
                      ? 'Baca perkataan, kira objek, kemudian cuba sebut sendiri.'
                      : 'Read the word, count the objects, then try saying it yourself.',
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
                          // Poking the giant number is the first thing every
                          // child tries — it now replays the narration.
                          Semantics(
                            button: true,
                            label: isMalay
                                ? 'Nombor ${item.number}. Sentuh untuk dengar.'
                                : 'Number ${item.number}. Tap to hear.',
                            child: GestureDetector(
                              onTap: () {
                                _bounceController.forward(from: 0);
                                _speakCurrentLesson();
                              },
                              child: ScaleTransition(
                                scale: _bounceAnim,
                                child: ScaleTransition(
                                  scale: _pulseAnim,
                                  child: _NumberStage(item: item, color: color),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ReadNumberCard(
                            color: color,
                            prompt: isMalay
                                ? 'Baca nombor ini:'
                                : 'Read this number:',
                            word: _wordForLanguage(item, language),
                          ),
                          const SizedBox(height: 12),
                          _NumberPronunciationPanel(
                            item: item,
                            color: color,
                            isMalay: isMalay,
                            onSpeak: _speakIn,
                          ),
                          const SizedBox(height: 12),
                          _CountingObjectsPanel(
                            count: item.number,
                            color: color,
                            objectEmoji: item.emoji,
                            isMalay: isMalay,
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
                    // Pre-readers don't parse "greyed out = unavailable" —
                    // on the first card the Back button is simply absent.
                    if (!isFirst) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _prev,
                          icon: const Icon(Icons.arrow_back_ios_rounded),
                          label: Text(
                            isMalay ? 'Sebelum' : 'Back',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.deepBlue,
                            foregroundColor: Colors.white,
                            minimumSize:
                                const Size.fromHeight(AppTheme.kidTarget),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLg),
                            ),
                            elevation: 5,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
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
                          backgroundColor: AppTheme.sunnyYellow,
                          foregroundColor: AppTheme.ink,
                          minimumSize:
                              const Size.fromHeight(AppTheme.kidTarget),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLg),
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
                    isMalay
                        ? '🎉 Tahniah! Kamu dah kenal nombor 1–100! 🎉'
                        : '🎉 Well done! You know numbers 1–100! 🎉',
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
      ),
    );
  }
}

class _FocusInstruction extends StatelessWidget {
  const _FocusInstruction({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const Icon(
              Icons.center_focus_strong_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                height: 1.22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberStage extends StatelessWidget {
  const _NumberStage({required this.item, required this.color});

  final _NumberItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 176,
          height: 176,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.72)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: Colors.white, width: 5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.36),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
        ),
        Positioned(
          top: 12,
          right: 18,
          child: Text(item.emoji, style: const TextStyle(fontSize: 30)),
        ),
        Text(
          '${item.number}',
          style: TextStyle(
            fontSize: item.number >= 100 ? 78 : 96,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 0.95,
            shadows: const [
              Shadow(
                color: Color(0x55000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadNumberCard extends StatelessWidget {
  const _ReadNumberCard({
    required this.color,
    required this.prompt,
    required this.word,
  });

  final Color color;
  final String prompt;
  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prompt,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Counting objects ─────────────────────────────────────────────────────────
class _CountingObjectsPanel extends ConsumerStatefulWidget {
  const _CountingObjectsPanel({
    required this.count,
    required this.color,
    required this.objectEmoji,
    required this.isMalay,
  });

  final int count;
  final Color color;
  final String objectEmoji;
  final bool isMalay;

  @override
  ConsumerState<_CountingObjectsPanel> createState() => _CountingObjectsPanelState();
}

class _CountingObjectsPanelState extends ConsumerState<_CountingObjectsPanel> {
  final ScrollController _scrollController = ScrollController();
  int _counted = 0;

  @override
  void didUpdateWidget(covariant _CountingObjectsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _counted = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ≥52dp cells — counting circles are primary kid tap targets.
        final columns = (constraints.maxWidth / 56).floor().clamp(4, 7).toInt();
        final rows = (widget.count / columns).ceil();
        final gridHeight = rows <= 4 ? rows * 58.0 : 232.0;
        final scrollable = rows > 4;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: widget.color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.touch_app_rounded, color: widget.color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isMalay
                          ? 'Sentuh objek untuk mengira'
                          : 'Tap objects to count',
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$_counted/${widget.count}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (_counted > 0) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: widget.isMalay ? 'Kira semula' : 'Count again',
                      onPressed: () => setState(() => _counted = 0),
                      icon: Icon(Icons.replay_rounded, color: widget.color),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: gridHeight,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: scrollable,
                  child: GridView.builder(
                    controller: _scrollController,
                    primary: false,
                    physics: scrollable
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    itemCount: widget.count,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final number = index + 1;
                      final counted = index < _counted;
                      return Semantics(
                        button: true,
                        selected: counted,
                        label: widget.isMalay
                            ? 'Objek nombor $number'
                            : 'Object number $number',
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => setState(() => _counted = number),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: counted ? widget.color : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.color.withValues(alpha: 0.55),
                                  width: counted ? 2.5 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.color.withValues(
                                      alpha: counted ? 0.30 : 0.10,
                                    ),
                                    blurRadius: counted ? 8 : 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.objectEmoji,
                                  style: TextStyle(fontSize: counted ? 21 : 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (scrollable) ...[
                const SizedBox(height: 8),
                Text(
                  widget.isMalay
                      ? 'Skrol untuk lihat semua ${widget.count} objek.'
                      : 'Scroll to see all ${widget.count} objects.',
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── 5-language pronunciation display ─────────────────────────────────────────
class _NumberPronunciationPanel extends StatelessWidget {
  const _NumberPronunciationPanel({
    required this.item,
    required this.color,
    required this.isMalay,
    required this.onSpeak,
  });

  final _NumberItem item;
  final Color color;
  final bool isMalay;
  final Future<void> Function(String word, String locale) onSpeak;

  @override
  Widget build(BuildContext context) {
    // One audio-first language list (replaces the old read-only word table +
    // chip wrap, which showed the same five words twice). Each row is a
    // full-width, ≥56dp tap target: tap anywhere on the row to hear the word.
    //
    // No country flags: Mandarin and Tamil are Malaysian community languages —
    // tagging them with China/India flags misframes them for our audience.
    final rows = [
      (tag: 'BM', label: 'Bahasa Melayu', word: item.malay, locale: 'ms-MY'),
      (tag: 'EN', label: 'English', word: item.english, locale: 'en-US'),
      (tag: '中', label: '中文', word: item.mandarin, locale: 'zh-CN'),
      (tag: 'த', label: 'தமிழ்', word: item.tamil, locale: 'ta-IN'),
      (tag: 'ID', label: 'Indonesia', word: item.indonesian, locale: 'id-ID'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.record_voice_over_rounded, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isMalay
                      ? 'Sentuh untuk dengar dalam 5 bahasa'
                      : 'Tap to hear in 5 languages',
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Semantics(
                button: true,
                label: '${row.label}: ${row.word}',
                child: Material(
                  color: color.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    onTap: () => onSpeak(row.word, row.locale),
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: AppTheme.kidTarget,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              row.tag,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 72,
                            child: Text(
                              row.label,
                              maxLines: 2,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              row.word,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.volume_up_rounded, size: 22, color: color),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
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
