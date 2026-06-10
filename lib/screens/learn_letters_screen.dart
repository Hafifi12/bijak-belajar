import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/app_language.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/star_counter.dart';
import '../widgets/xp_popup.dart';

class LearnLettersScreen extends ConsumerStatefulWidget {
  const LearnLettersScreen({super.key});

  static const routeName = '/learn-letters';

  @override
  ConsumerState<LearnLettersScreen> createState() =>
      _LearnLettersScreenState();
}

class _LearnLettersScreenState extends ConsumerState<LearnLettersScreen>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  bool _recordedInitial = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  // ── Speech recognition ───────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String _speechResult = '';
  bool? _speechCorrect;

  // ── A–Z with 5 languages ───────────────────────────────────────
  static const _letters = <_LetterItem>[
    _LetterItem(
      letter: 'A',
      emoji: '🐔',
      malay: 'Ayam',
      english: 'Ant',
      mandarin: '苹果 (Píngguǒ)',
      tamil: 'அம்மா (Ammā)',
      indonesian: 'Apel',
      phonicsMalay: 'A seperti Ayam',
    ),
    _LetterItem(
      letter: 'B',
      emoji: '📚',
      malay: 'Buku',
      english: 'Ball',
      mandarin: '杯子 (Bēizi)',
      tamil: 'பந்து (Pandu)',
      indonesian: 'Buku',
      phonicsMalay: 'B seperti Buku',
    ),
    _LetterItem(
      letter: 'C',
      emoji: '☕',
      malay: 'Cawan',
      english: 'Cup',
      mandarin: '车 (Chē)',
      tamil: 'சந்திரன் (Candiran)',
      indonesian: 'Cangkir',
      phonicsMalay: 'C seperti Cawan',
    ),
    _LetterItem(
      letter: 'D',
      emoji: '🍈',
      malay: 'Durian',
      english: 'Duck',
      mandarin: '大象 (Dàxiàng)',
      tamil: 'தேன் (Tēṉ)',
      indonesian: 'Durian',
      phonicsMalay: 'D seperti Durian',
    ),
    _LetterItem(
      letter: 'E',
      emoji: '🦊',
      malay: 'Ekor',
      english: 'Egg',
      mandarin: '鹅 (É)',
      tamil: 'எலி (Eli)',
      indonesian: 'Ekor',
      phonicsMalay: 'E seperti Ekor',
    ),
    _LetterItem(
      letter: 'F',
      emoji: '🌅',
      malay: 'Fajar',
      english: 'Fish',
      mandarin: '风 (Fēng)',
      tamil: 'பூ (Pū)',
      indonesian: 'Fajar',
      phonicsMalay: 'F seperti Fajar',
    ),
    _LetterItem(
      letter: 'G',
      emoji: '🐘',
      malay: 'Gajah',
      english: 'Goat',
      mandarin: '狗 (Gǒu)',
      tamil: 'கடல் (Kaṭal)',
      indonesian: 'Gajah',
      phonicsMalay: 'G seperti Gajah',
    ),
    _LetterItem(
      letter: 'H',
      emoji: '🐯',
      malay: 'Harimau',
      english: 'Hat',
      mandarin: '花 (Huā)',
      tamil: 'புல் (Pul)',
      indonesian: 'Harimau',
      phonicsMalay: 'H seperti Harimau',
    ),
    _LetterItem(
      letter: 'I',
      emoji: '🐟',
      malay: 'Ikan',
      english: 'Ice',
      mandarin: '鱼 (Yú)',
      tamil: 'இலை (Ilai)',
      indonesian: 'Ikan',
      phonicsMalay: 'I seperti Ikan',
    ),
    _LetterItem(
      letter: 'J',
      emoji: '🌉',
      malay: 'Jambatan',
      english: 'Juice',
      mandarin: '橘子 (Júzi)',
      tamil: 'ஜன்னல் (Jannal)',
      indonesian: 'Jembatan',
      phonicsMalay: 'J seperti Jambatan',
    ),
    _LetterItem(
      letter: 'K',
      emoji: '🐱',
      malay: 'Kucing',
      english: 'Kite',
      mandarin: '快 (Kuài)',
      tamil: 'கிளி (Kiḷi)',
      indonesian: 'Kucing',
      phonicsMalay: 'K seperti Kucing',
    ),
    _LetterItem(
      letter: 'L',
      emoji: '🐄',
      malay: 'Lembu',
      english: 'Lion',
      mandarin: '老虎 (Lǎohǔ)',
      tamil: 'லாம்பு (Lāmpu)',
      indonesian: 'Lembu',
      phonicsMalay: 'L seperti Lembu',
    ),
    _LetterItem(
      letter: 'M',
      emoji: '🐒',
      malay: 'Monyet',
      english: 'Moon',
      mandarin: '猫 (Māo)',
      tamil: 'மரம் (Maram)',
      indonesian: 'Monyet',
      phonicsMalay: 'M seperti Monyet',
    ),
    _LetterItem(
      letter: 'N',
      emoji: '🍍',
      malay: 'Nanas',
      english: 'Nose',
      mandarin: '鸟 (Niǎo)',
      tamil: 'நாய் (Nāy)',
      indonesian: 'Nanas',
      phonicsMalay: 'N seperti Nanas',
    ),
    _LetterItem(
      letter: 'O',
      emoji: '🍊',
      malay: 'Oren',
      english: 'Owl',
      mandarin: '苹果 (Chéng)',
      tamil: 'ஒட்டகம் (Oṭṭakam)',
      indonesian: 'Oren',
      phonicsMalay: 'O seperti Oren',
    ),
    _LetterItem(
      letter: 'P',
      emoji: '🍌',
      malay: 'Pisang',
      english: 'Pen',
      mandarin: '苹 (Píng)',
      tamil: 'பழம் (Paḻam)',
      indonesian: 'Pisang',
      phonicsMalay: 'P seperti Pisang',
    ),
    _LetterItem(
      letter: 'Q',
      emoji: '👑',
      malay: 'Queen',
      english: 'Queen',
      mandarin: '球 (Qiú)',
      tamil: 'குரல் (Kural)',
      indonesian: 'Ratu',
      phonicsMalay: 'Q seperti Queen',
    ),
    _LetterItem(
      letter: 'R',
      emoji: '🦋',
      malay: 'Rama-rama',
      english: 'Rain',
      mandarin: '人 (Rén)',
      tamil: 'ரயில் (Rayil)',
      indonesian: 'Rama-rama',
      phonicsMalay: 'R seperti Rama-rama',
    ),
    _LetterItem(
      letter: 'S',
      emoji: '🦁',
      malay: 'Singa',
      english: 'Sun',
      mandarin: '蛇 (Shé)',
      tamil: 'சூரியன் (Cūriyaṉ)',
      indonesian: 'Singa',
      phonicsMalay: 'S seperti Singa',
    ),
    _LetterItem(
      letter: 'T',
      emoji: '🐭',
      malay: 'Tikus',
      english: 'Tree',
      mandarin: '兔 (Tù)',
      tamil: 'தண்ணீர் (Taṇṇīr)',
      indonesian: 'Tikus',
      phonicsMalay: 'T seperti Tikus',
    ),
    _LetterItem(
      letter: 'U',
      emoji: '🦐',
      malay: 'Udang',
      english: 'Umbrella',
      mandarin: '鱼 (Yú)',
      tamil: 'உணவு (Uṇavu)',
      indonesian: 'Udang',
      phonicsMalay: 'U seperti Udang',
    ),
    _LetterItem(
      letter: 'V',
      emoji: '🎻',
      malay: 'Violin',
      english: 'Van',
      mandarin: '花瓶 (Huāpíng)',
      tamil: 'வானம் (Vāṉam)',
      indonesian: 'Violin',
      phonicsMalay: 'V seperti Violin',
    ),
    _LetterItem(
      letter: 'W',
      emoji: '🍉',
      malay: 'Tembikai',
      english: 'Water',
      mandarin: '乌龟 (Wūguī)',
      tamil: 'வீடு (Vīṭu)',
      indonesian: 'Semangka',
      phonicsMalay: 'W seperti Tembikai',
    ),
    _LetterItem(
      letter: 'X',
      emoji: '🩻',
      malay: 'X-ray',
      english: 'X-ray',
      mandarin: 'X光 (X-guāng)',
      tamil: 'எக்ஸ்ரே (Eksrē)',
      indonesian: 'X-ray',
      phonicsMalay: 'X seperti X-ray',
    ),
    _LetterItem(
      letter: 'Y',
      emoji: '🪁',
      malay: 'Yoyo',
      english: 'Yak',
      mandarin: '鱼 (Yú)',
      tamil: 'யானை (Yāṉai)',
      indonesian: 'Yoyo',
      phonicsMalay: 'Y seperti Yoyo',
    ),
    _LetterItem(
      letter: 'Z',
      emoji: '🦓',
      malay: 'Zebra',
      english: 'Zebra',
      mandarin: '动物园 (Dòngwùyuán)',
      tamil: 'ஜீப் (Jīp)',
      indonesian: 'Zebra',
      phonicsMalay: 'Z seperti Zebra',
    ),
  ];

  static const _colors = [
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
    Color(0xFFE17055),
    Color(0xFF74B9FF),
    Color(0xFFA29BFE),
  ];

  Color get _color => _colors[_current % _colors.length];

  @override
  void initState() {
    super.initState();
    // Resume at the last letter the child saw, instead of restarting at A.
    final last = ref.read(progressServiceProvider).getLastLesson('letters');
    if (last.isNotEmpty) {
      final idx = _letters.indexWhere((l) => l.letter == last);
      if (idx >= 0) _current = idx;
    }
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _speech.cancel();
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
    if (_current < _letters.length - 1) {
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
    final item = _letters[_current];
    ref.read(progressServiceProvider).markModuleLesson('letters', item.letter);
    // TTS: narrate the letter and the word on each card navigation
    _speakCurrentLesson();
    // Reset speech feedback when moving to a new letter
    if (mounted) {
      setState(() {
        _speechResult = '';
        _speechCorrect = null;
      });
    }
  }

  Future<void> _speakCurrentLesson() async {
    final ps = ref.read(progressServiceProvider);
    if (!ps.voiceEnabled) return;
    final item = _letters[_current];
    final audio = ref.read(audioServiceProvider);
    final lang = ps.language;
    // Say the letter name, then the word in the active language
    await audio.speakLocale(item.letter, enabled: true, locale: 'en-US');
    await Future.delayed(const Duration(milliseconds: 380));
    final word = _wordForLanguage(item, lang);
    await audio.speakLocale(word, enabled: true, locale: lang.ttsLocale);
  }

  String _wordForLanguage(_LetterItem item, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.malay:
        return item.malay;
      case AppLanguage.mandarin:
        return item.mandarin;
      case AppLanguage.tamil:
        return item.tamil;
      case AppLanguage.indonesian:
        return item.indonesian;
      case AppLanguage.english:
        return item.english;
    }
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

  // ── Speech recognition ───────────────────────────────────────

  Future<void> _startListening() async {
    if (!_speechAvailable || _isListening) return;
    setState(() {
      _isListening = true;
      _speechResult = '';
      _speechCorrect = null;
    });
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _speechResult = result.recognizedWords);
        if (result.finalResult) _evaluateSpeech(result.recognizedWords);
      },
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
        cancelOnError: true,
        partialResults: true,
        localeId: 'en-US',
      ),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  void _evaluateSpeech(String words) {
    if (words.isEmpty) return;
    final item = _letters[_current];
    final target = item.english.toLowerCase();
    final letter = item.letter.toLowerCase();
    final said = words.toLowerCase().trim();
    final isCorrect = said.contains(letter) || said.contains(target);

    setState(() {
      _isListening = false;
      _speechCorrect = isCorrect;
    });

    if (isCorrect) {
      ref.read(progressServiceProvider).addStars(1);
      XpPopup.show(context, amount: 1);
      final audio = ref.read(audioServiceProvider);
      final ps = ref.read(progressServiceProvider);
      final praiseMalay = ps.language == AppLanguage.malay;
      audio.speakLocale(
        praiseMalay
            ? 'Bagus! Kamu sebut ${item.letter} dengan betul!'
            : 'Great job! You said ${item.letter} correctly!',
        enabled: ps.voiceEnabled,
        locale: praiseMalay ? 'ms-MY' : 'en-US',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(progressServiceProvider).language;
    final item = _letters[_current];
    final color = _color;
    final isMalay = language == AppLanguage.malay;
    final isFirst = _current == 0;
    final isLast = _current == _letters.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.moduleLetters,
        foregroundColor: Colors.white,
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
              tag: 'module-emoji-${LearnLettersScreen.routeName}',
              child: const Text('🔤', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMalay ? 'Belajar Huruf A–Z' : 'Learn Letters A–Z',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  '${_current + 1} / ${_letters.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
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
                          value: (_current + 1) / _letters.length,
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
                        '${_current + 1}/${_letters.length}',
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
              // ── Instruction hint ───────────────────────────────
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
                          isMalay
                              ? 'Dengar bunyi huruf, lihat contoh, kemudian sebut kuat-kuat!'
                              : 'Hear the letter sound, see the example, then say it aloud!',
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

              // ── Main card ──────────────────────────────────────
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          // Big letter with bounce
                          ScaleTransition(
                            scale: _bounceAnim,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      item.letter,
                                      style: const TextStyle(
                                        fontSize: 90,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 14,
                                    child: Text(
                                      item.letter.toLowerCase(),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withValues(
                                          alpha: 0.65,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Emoji + phonics hint
                          Text(
                            item.emoji,
                            style: const TextStyle(fontSize: 52),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              item.phonicsMalay,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: color,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ── 🎤 Speech recognition input ─────────
                          // Promoted above the word table: "say the letter"
                          // is this module's core interaction, not a footnote.
                          if (_speechAvailable) ...[
                            GestureDetector(
                              onTap: _isListening
                                  ? _stopListening
                                  : _startListening,
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 220),
                                constraints: const BoxConstraints(
                                  minHeight: AppTheme.kidTarget,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: _isListening
                                      ? const Color(0xFFE84393)
                                      : color,
                                  borderRadius:
                                      BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isListening
                                              ? const Color(0xFFE84393)
                                              : color)
                                          .withValues(alpha: 0.45),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isListening
                                          ? Icons.stop_circle_rounded
                                          : Icons.mic_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isListening
                                          ? (isMalay
                                              ? 'Saya dengar...'
                                              : 'Listening...')
                                          : (isMalay
                                              ? '🎤 Sebut huruf ${item.letter}!'
                                              : '🎤 Say letter ${item.letter}!'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_speechResult.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: (_speechCorrect == true
                                          ? const Color(0xFF34C759)
                                          : _speechCorrect == false
                                              ? AppTheme.appleRed
                                              : Colors.grey.shade200)
                                      .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _speechCorrect == true
                                        ? const Color(0xFF34C759)
                                        : _speechCorrect == false
                                            ? AppTheme.appleRed
                                            : Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _speechCorrect == true
                                          ? '✅'
                                          : _speechCorrect == false
                                              ? '❌'
                                              : '🎤',
                                      style: const TextStyle(
                                          fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '"$_speechResult"',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _speechCorrect == true
                                              ? const Color(0xFF34C759)
                                              : _speechCorrect == false
                                                  ? AppTheme.appleRed
                                                  : AppTheme.ink,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_speechCorrect == true) ...[
                                const SizedBox(height: 6),
                                Text(
                                  isMalay
                                      ? '⭐ +1 Bintang! Bagus sekali!'
                                      : '⭐ +1 Star! Great job!',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF34C759),
                                  ),
                                ),
                              ],
                            ],
                          ],

                          const SizedBox(height: 14),
                          _LetterWordTable(item: item, color: color),
                          const SizedBox(height: 14),
                          _PronounceButtons(
                            onSpeak: _speakIn,
                            malay: item.letter.toLowerCase(),
                            english: item.letter.toLowerCase(),
                            mandarin: item.letter.toLowerCase(),
                            indonesian: item.letter.toLowerCase(),
                            tamil: item.letter.toLowerCase(),
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

              // ── Navigation ─────────────────────────────────────
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
                          backgroundColor: AppTheme.deepBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(AppTheme.kidTarget),
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
                          backgroundColor: AppTheme.sunnyYellow,
                          foregroundColor: AppTheme.ink,
                          minimumSize: const Size.fromHeight(AppTheme.kidTarget),
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
                    '🌟 Bagus! Kamu dah kenal semua huruf A–Z! 🌟',
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

// ── 5-language letter word table ───────────────────────────────────────────────
class _LetterWordTable extends StatelessWidget {
  const _LetterWordTable({required this.item, required this.color});
  final _LetterItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Language tags instead of country flags: Mandarin and Tamil are
    // Malaysian community languages, not foreign ones.
    final rows = [
      ('BM', 'Melayu', item.malay),
      ('EN', 'English', item.english),
      ('中', '中文', item.mandarin),
      ('த', 'தமிழ்', item.tamil),
      ('ID', 'Indonesia', item.indonesian),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        flag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
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
                          fontSize: 15,
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

// ── Shared 5-language pronounce buttons ──────────────────────────────────────
class _PronounceButtons extends StatelessWidget {
  const _PronounceButtons({
    required this.onSpeak,
    required this.malay,
    required this.english,
    required this.mandarin,
    required this.indonesian,
    required this.tamil,
    required this.color,
  });

  final Future<void> Function(String word, String locale) onSpeak;
  final String malay;
  final String english;
  final String mandarin;
  final String indonesian;
  final String tamil;
  final Color color;

  // Language tags only — no country flags (Malaysian community languages).
  static const _langs = [
    (label: 'BM', locale: 'ms-MY'),
    (label: 'EN', locale: 'en-US'),
    (label: '中文', locale: 'zh-CN'),
    (label: 'ID', locale: 'id-ID'),
    (label: 'தமிழ்', locale: 'ta-IN'),
  ];

  String _wordFor(String locale) {
    switch (locale) {
      case 'ms-MY':
        return malay;
      case 'en-US':
        return english;
      case 'zh-CN':
        return mandarin;
      case 'id-ID':
        return indonesian;
      case 'ta-IN':
        return tamil;
      default:
        return english;
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
                      Text(
                        l.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.volume_up_rounded, size: 16, color: color),
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
class _LetterItem {
  const _LetterItem({
    required this.letter,
    required this.emoji,
    required this.malay,
    required this.english,
    required this.mandarin,
    required this.tamil,
    required this.indonesian,
    required this.phonicsMalay,
  });

  final String letter;
  final String emoji;
  final String malay;
  final String english;
  final String mandarin;
  final String tamil;
  final String indonesian;
  final String phonicsMalay;
}
