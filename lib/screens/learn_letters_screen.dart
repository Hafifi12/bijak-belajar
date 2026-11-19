import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/app_language.dart';
import '../providers/app_state.dart';
import '../services/on_device_speech.dart';
import '../theme/app_theme.dart';
import '../utils/app_text.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/star_counter.dart';
import '../widgets/xp_popup.dart';
import '../widgets/zara_prompt.dart';

class LearnLettersScreen extends ConsumerStatefulWidget {
  const LearnLettersScreen({super.key});

  static const routeName = '/learn-letters';

  @override
  ConsumerState<LearnLettersScreen> createState() => _LearnLettersScreenState();
}

class _LearnLettersScreenState extends ConsumerState<LearnLettersScreen>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  bool _recordedInitial = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  // ── Speech recognition ───────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  // null while checking; false when this phone can't recognise speech offline.
  bool? _onDeviceSpeech;
  // The microphone is only requested after the child taps "speak".
  bool _speechAvailable = false;
  bool _speechError = false;
  bool _isListening = false;
  String _speechResult = '';
  bool? _speechCorrect;

  // ── A–Z with 5 languages ───────────────────────────────────────
  static const _letters = <_LetterItem>[
    _LetterItem(
      letter: 'A',
      emoji: '🐔',
      malay: 'Ayam',
      english: 'Chicken',
      mandarin: '鸡 (jī)',
      tamil: 'கோழி (Kōḻi)',
      indonesian: 'Ayam',
      phonicsMalay: 'A seperti Ayam',
    ),
    _LetterItem(
      letter: 'B',
      emoji: '📚',
      malay: 'Buku',
      english: 'Book',
      mandarin: '书 (shū)',
      tamil: 'புத்தகம் (Puttakam)',
      indonesian: 'Buku',
      phonicsMalay: 'B seperti Buku',
    ),
    _LetterItem(
      letter: 'C',
      emoji: '☕',
      malay: 'Cawan',
      english: 'Cup',
      mandarin: '杯子 (bēizi)',
      tamil: 'கோப்பை (Kōppai)',
      indonesian: 'Cangkir',
      phonicsMalay: 'C seperti Cawan',
    ),
    _LetterItem(
      letter: 'D',
      emoji: '🍈',
      malay: 'Durian',
      english: 'Durian',
      mandarin: '榴莲 (liúlián)',
      tamil: 'துரியான் (Turiyān)',
      indonesian: 'Durian',
      phonicsMalay: 'D seperti Durian',
    ),
    _LetterItem(
      letter: 'E',
      emoji: '🦊',
      malay: 'Ekor',
      english: 'Tail',
      mandarin: '尾巴 (wěiba)',
      tamil: 'வால் (Vāl)',
      indonesian: 'Ekor',
      phonicsMalay: 'E seperti Ekor',
    ),
    _LetterItem(
      letter: 'F',
      emoji: '🌅',
      malay: 'Fajar',
      english: 'Dawn',
      mandarin: '黎明 (límíng)',
      tamil: 'விடியல் (Viṭiyal)',
      indonesian: 'Fajar',
      phonicsMalay: 'F seperti Fajar',
    ),
    _LetterItem(
      letter: 'G',
      emoji: '🐘',
      malay: 'Gajah',
      english: 'Elephant',
      mandarin: '大象 (dàxiàng)',
      tamil: 'யானை (Yāṉai)',
      indonesian: 'Gajah',
      phonicsMalay: 'G seperti Gajah',
    ),
    _LetterItem(
      letter: 'H',
      emoji: '🐯',
      malay: 'Harimau',
      english: 'Tiger',
      mandarin: '老虎 (lǎohǔ)',
      tamil: 'புலி (Puli)',
      indonesian: 'Harimau',
      phonicsMalay: 'H seperti Harimau',
    ),
    _LetterItem(
      letter: 'I',
      emoji: '🐟',
      malay: 'Ikan',
      english: 'Fish',
      mandarin: '鱼 (yú)',
      tamil: 'மீன் (Mīṉ)',
      indonesian: 'Ikan',
      phonicsMalay: 'I seperti Ikan',
    ),
    _LetterItem(
      letter: 'J',
      emoji: '🌉',
      malay: 'Jambatan',
      english: 'Bridge',
      mandarin: '桥 (qiáo)',
      tamil: 'பாலம் (Pālam)',
      indonesian: 'Jembatan',
      phonicsMalay: 'J seperti Jambatan',
    ),
    _LetterItem(
      letter: 'K',
      emoji: '🐱',
      malay: 'Kucing',
      english: 'Cat',
      mandarin: '猫 (māo)',
      tamil: 'பூனை (Pūṉai)',
      indonesian: 'Kucing',
      phonicsMalay: 'K seperti Kucing',
    ),
    _LetterItem(
      letter: 'L',
      emoji: '🐄',
      malay: 'Lembu',
      english: 'Cow',
      mandarin: '牛 (niú)',
      tamil: 'மாடு (Māṭu)',
      indonesian: 'Lembu',
      phonicsMalay: 'L seperti Lembu',
    ),
    _LetterItem(
      letter: 'M',
      emoji: '🐒',
      malay: 'Monyet',
      english: 'Monkey',
      mandarin: '猴子 (hóuzi)',
      tamil: 'குரங்கு (Kuraṅku)',
      indonesian: 'Monyet',
      phonicsMalay: 'M seperti Monyet',
    ),
    _LetterItem(
      letter: 'N',
      emoji: '🍍',
      malay: 'Nanas',
      english: 'Pineapple',
      mandarin: '菠萝 (bōluo)',
      tamil: 'அன்னாசி (Aṉṉāci)',
      indonesian: 'Nanas',
      phonicsMalay: 'N seperti Nanas',
    ),
    _LetterItem(
      letter: 'O',
      emoji: '🍊',
      malay: 'Oren',
      english: 'Orange',
      mandarin: '橙子 (chéngzi)',
      tamil: 'ஆரஞ்சு (Ārañcu)',
      indonesian: 'Jeruk',
      phonicsMalay: 'O seperti Oren',
    ),
    _LetterItem(
      letter: 'P',
      emoji: '🍌',
      malay: 'Pisang',
      english: 'Banana',
      mandarin: '香蕉 (xiāngjiāo)',
      tamil: 'வாழைப்பழம் (Vāḻaippaḻam)',
      indonesian: 'Pisang',
      phonicsMalay: 'P seperti Pisang',
    ),
    _LetterItem(
      letter: 'Q',
      emoji: '👑',
      malay: 'Ratu',
      english: 'Queen',
      mandarin: '女王 (nǚwáng)',
      tamil: 'ராணி (Rāṇi)',
      indonesian: 'Ratu',
      phonicsMalay: 'Q seperti Ratu',
    ),
    _LetterItem(
      letter: 'R',
      emoji: '🦋',
      malay: 'Rama-rama',
      english: 'Butterfly',
      mandarin: '蝴蝶 (húdié)',
      tamil: 'பட்டாம்பூச்சி (Paṭṭāmpūcci)',
      indonesian: 'Rama-rama',
      phonicsMalay: 'R seperti Rama-rama',
    ),
    _LetterItem(
      letter: 'S',
      emoji: '🦁',
      malay: 'Singa',
      english: 'Lion',
      mandarin: '狮子 (shīzi)',
      tamil: 'சிங்கம் (Ciṅkam)',
      indonesian: 'Singa',
      phonicsMalay: 'S seperti Singa',
    ),
    _LetterItem(
      letter: 'T',
      emoji: '🐭',
      malay: 'Tikus',
      english: 'Mouse',
      mandarin: '老鼠 (lǎoshǔ)',
      tamil: 'எலி (Eli)',
      indonesian: 'Tikus',
      phonicsMalay: 'T seperti Tikus',
    ),
    _LetterItem(
      letter: 'U',
      emoji: '🦐',
      malay: 'Udang',
      english: 'Shrimp',
      mandarin: '虾 (xiā)',
      tamil: 'இறால் (Iṟāl)',
      indonesian: 'Udang',
      phonicsMalay: 'U seperti Udang',
    ),
    _LetterItem(
      letter: 'V',
      emoji: '🎻',
      malay: 'Violin',
      english: 'Violin',
      mandarin: '小提琴 (xiǎotíqín)',
      tamil: 'வயலின் (Vayalin)',
      indonesian: 'Biola',
      phonicsMalay: 'V seperti Violin',
    ),
    _LetterItem(
      letter: 'W',
      emoji: '🍉',
      malay: 'Tembikai',
      english: 'Watermelon',
      mandarin: '西瓜 (xīguā)',
      tamil: 'தர்பூசணி (Tarpūcaṇi)',
      indonesian: 'Semangka',
      phonicsMalay: 'W seperti Tembikai',
    ),
    _LetterItem(
      letter: 'X',
      emoji: '🩻',
      malay: 'X-ray',
      english: 'X-ray',
      mandarin: 'X光 (X guāng)',
      tamil: 'எக்ஸ்ரே (Eksrē)',
      indonesian: 'Sinar-X',
      phonicsMalay: 'X seperti X-ray',
    ),
    _LetterItem(
      letter: 'Y',
      emoji: '🪀',
      malay: 'Yoyo',
      english: 'Yo-yo',
      mandarin: '悠悠球 (yōuyōuqiú)',
      tamil: 'யோயோ (Yōyō)',
      indonesian: 'Yoyo',
      phonicsMalay: 'Y seperti Yoyo',
    ),
    _LetterItem(
      letter: 'Z',
      emoji: '🦓',
      malay: 'Zebra',
      english: 'Zebra',
      mandarin: '斑马 (bānmǎ)',
      tamil: 'வரிக்குதிரை (Varikkutirai)',
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
    OnDeviceSpeech.isAvailable().then((available) {
      if (mounted) setState(() => _onDeviceSpeech = available);
    });
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _speechError = true;
        });
      },
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

  /// Strips romanisation hints like "苹果 (Píngguǒ)" → "苹果" so the TTS
  /// engine only receives the target script.
  static String _ttsClean(String s) =>
      s.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();

  /// "Letter, then its example" — A → "A seperti Ayam" (BM),
  /// "A for Ant" (EN), "A, 苹果" (other languages).
  String _letterPhrase(_LetterItem item, AppLanguage lang) {
    return switch (lang) {
      AppLanguage.malay => item.phonicsMalay,
      AppLanguage.english => '${item.letter} for ${item.english}',
      _ => '${item.letter}, ${_ttsClean(_wordForLanguage(item, lang))}',
    };
  }

  Future<void> _speakCurrentLesson() async {
    final ps = ref.read(progressServiceProvider);
    if (!ps.voiceEnabled) return;
    final item = _letters[_current];
    final audio = ref.read(audioServiceProvider);
    final lang = ps.language;
    // Letter name in the app language's voice, then the example phrase.
    await audio.speakLocale(item.letter, enabled: true, locale: lang.ttsLocale);
    await Future.delayed(const Duration(milliseconds: 380));
    await audio.speakLocale(
      _letterPhrase(item, lang),
      enabled: true,
      locale: lang.ttsLocale,
    );
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

  /// Requests the microphone only when the child taps "speak", after telling
  /// the grown-up why (Play User Data policy). Skips the explanation when the
  /// permission was already granted.
  Future<void> _onSpeakTapped() async {
    if (_isListening) {
      await _stopListening();
      return;
    }
    if (!_speechAvailable) {
      if (!await _speech.hasPermission) {
        final proceed = await _explainMicrophone();
        if (proceed != true || !mounted) return;
      }
      await _initSpeech();
      if (!_speechAvailable) {
        if (mounted) setState(() => _speechError = true);
        return;
      }
    }
    await _startListening();
  }

  Future<bool?> _explainMicrophone() {
    final language = ref.read(progressServiceProvider).language;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppText.ui('micTitle', language)),
        content: Text(AppText.ui('micBodyOnDevice', language)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppText.ui('notNow', language)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppText.ui('continueLabel', language)),
          ),
        ],
      ),
    );
  }

  Future<void> _startListening() async {
    if (!_speechAvailable || _isListening) return;
    setState(() {
      _isListening = true;
      _speechError = false;
      _speechResult = '';
      _speechCorrect = null;
    });
    final language = ref.read(progressServiceProvider).language;
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
        // Offline only: the plugin would otherwise fall back to the online
        // recogniser, and a child's voice must never leave the phone.
        onDevice: true,
        localeId: language.ttsLocale,
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
    final language = ref.read(progressServiceProvider).language;
    final target = _ttsClean(_wordForLanguage(item, language)).toLowerCase();
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
      final praise = switch (ps.language) {
        AppLanguage.malay => 'Bagus! Kamu sebut ${item.letter} dengan betul!',
        AppLanguage.english => 'Great job! You said ${item.letter} correctly!',
        AppLanguage.mandarin => '太棒了！你正确地说出了 ${item.letter}！',
        AppLanguage.tamil => 'அருமை! ${item.letter} என்பதைச் சரியாகச் சொன்னாய்!',
        AppLanguage.indonesian =>
          'Bagus! Kamu menyebut ${item.letter} dengan benar!',
      };
      audio.speakLocale(
        praise,
        enabled: ps.voiceEnabled,
        locale: ps.language.ttsLocale,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(progressServiceProvider).language;
    final item = _letters[_current];
    final color = _color;
    final isFirst = _current == 0;
    final isLast = _current == _letters.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.nightMid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const NightBar(AppTheme.moduleLetters),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: language.copy(ms: 'Kembali', en: 'Back', zh: '返回', ta: 'பின்செல்'),
        ),
        // Hero continues the emoji "flight" from the Learning Path card.
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'module-emoji-${LearnLettersScreen.routeName}',
              child: const Text('🔤', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    language.copy(ms: 'Belajar Huruf A–Z', en: 'Learn Letters A–Z', zh: '学习字母 A–Z', ta: 'எழுத்துகள் A–Z கற்போம்'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_current + 1} / ${_letters.length}',
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
        topColor: AppTheme.nightTop,
        bottomColor: AppTheme.nightBottom,
        showHills: false,
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    AppBar().preferredSize.height,
              ),
              child: IntrinsicHeight(
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
                    // ── Zara asks the question ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ZaraPrompt(
                        message: language.copy(ms: 'Huruf apakah ini? Dengar & sebut kuat-kuat!', en: 'What letter is this? Listen & say it aloud!', zh: '这是什么字母？听一听，大声念出来！', ta: 'இது என்ன எழுத்து? கேட்டு உரக்கச் சொல்!'),
                        sub: language.copy(ms: 'Dengar & sebut huruf ini', en: 'What letter is this?', zh: '这是什么字母？', ta: 'இது என்ன எழுத்து?'),
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
                                color: AppTheme.deepBlue.withValues(
                                  alpha: 0.14,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 9),
                              ),
                            ],
                          ),
                          child: Padding(
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
                                // Offered only when this phone can recognise speech
                                // offline. Otherwise a short note says why.
                                if (_onDeviceSpeech == false) ...[
                                  Container(
                                    key: const Key('speech-unavailable'),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1EEFF),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      AppText.ui('speechUnavailable', language),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppTheme.ink,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ] else if (_onDeviceSpeech == true) ...[
                                  GestureDetector(
                                    key: const Key('speak-button'),
                                    onTap: _onSpeakTapped,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
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
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                (_isListening
                                                        ? const Color(
                                                            0xFFE84393,
                                                          )
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
                                                ? (language.copy(ms: 'Saya dengar...', en: 'Listening...', zh: '正在听...', ta: 'கேட்கிறது...'))
                                                : (language.copy(ms: '🎤 Sebut huruf ${item.letter}!', en: '🎤 Say letter ${item.letter}!', zh: '🎤 请念字母 ${item.letter}！', ta: '🎤 எழுத்து ${item.letter}-ஐ சொல்!')),
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
                                  if (_speechError) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      AppText.ui('speechError', language),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppTheme.ink,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                  if (_speechResult.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (_speechCorrect == true
                                                    ? const Color(0xFF34C759)
                                                    : _speechCorrect == false
                                                    ? AppTheme.appleRed
                                                    : Colors.grey.shade200)
                                                .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(18),
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
                                              fontSize: 18,
                                            ),
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
                                        language.copy(ms: '⭐ +1 Bintang! Bagus sekali!', en: '⭐ +1 Star! Great job!', zh: '⭐ +1 星！做得好！', ta: '⭐ +1 நட்சத்திரம்! சிறப்பு!'),
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
                                  language: language,
                                  onSpeak: _speakIn,
                                  malay: '${item.letter}, ${item.malay}',
                                  english: '${item.letter}, ${item.english}',
                                  mandarin:
                                      '${item.letter}, ${_ttsClean(item.mandarin)}',
                                  indonesian:
                                      '${item.letter}, ${item.indonesian}',
                                  tamil:
                                      '${item.letter}, ${_ttsClean(item.tamil)}',
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
                                language.copy(ms: 'Sebelum', en: 'Back', zh: '返回', ta: 'பின்செல்'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.deepBlue,
                                disabledBackgroundColor: AppTheme.deepBlue.withValues(alpha: 0.4),
                                disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(
                                  AppTheme.kidTarget,
                                ),
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
                                language.copy(ms: 'Seterusnya', en: 'Next', zh: '下一步', ta: 'அடுத்தது'),
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
                                minimumSize: const Size.fromHeight(
                                  AppTheme.kidTarget,
                                ),
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
    required this.language,
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
  final AppLanguage language;

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
            language.copy(ms: '🔊 Sebut dalam:', en: '🔊 Say it in:', zh: '🔊 用以下语言念：', ta: '🔊 இந்த மொழிகளில் சொல்:'),
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
