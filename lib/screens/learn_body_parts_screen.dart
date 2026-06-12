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

/// Belajar Anggota Badan — Learn Body Parts
/// Malaysian kindergarten style for preschool children.
class LearnBodyPartsScreen extends ConsumerStatefulWidget {
  const LearnBodyPartsScreen({super.key});

  static const routeName = '/learn-body-parts';

  @override
  ConsumerState<LearnBodyPartsScreen> createState() => _LearnBodyPartsScreenState();
}

class _LearnBodyPartsScreenState extends ConsumerState<LearnBodyPartsScreen>
    with TickerProviderStateMixin {
  int _current = 0;
  bool _recordedInitial = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

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
      photoAsset: 'assets/images/body_parts/head.png',
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
      photoAsset: 'assets/images/body_parts/eyes.png',
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
      photoAsset: 'assets/images/body_parts/nose.png',
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
      photoAsset: 'assets/images/body_parts/mouth.png',
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
      photoAsset: 'assets/images/body_parts/ears.png',
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
      photoAsset: 'assets/images/body_parts/hair.png',
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
      photoAsset: 'assets/images/body_parts/teeth.png',
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
      photoAsset: 'assets/images/body_parts/shoulder.png',
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
      photoAsset: 'assets/images/body_parts/hands.png',
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
      photoAsset: 'assets/images/body_parts/fingers.png',
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
      photoAsset: 'assets/images/body_parts/stomach.png',
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
      photoAsset: 'assets/images/body_parts/legs.png',
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
      photoAsset: 'assets/images/body_parts/knees.png',
    ),
    _BodyPart(
      malay: 'Tapak Kaki',
      english: 'Feet',
      indonesian: 'Telapak kaki',
      mandarin: '脚 (Jiǎo)',
      tamil: 'பாதம் (Pātam)',
      emoji: '🦶',
      bodyEmoji: '🦶',
      fun: 'Tapak kaki untuk berdiri!',
      color: Color(0xFF55EFC4),
      photoAsset: 'assets/images/body_parts/feet.png',
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
  }

  @override
  void dispose() {
    _bounceController.dispose();
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

  void _goToPart(int index) {
    if (index < 0 || index >= _parts.length || index == _current) {
      return;
    }
    setState(() => _current = index);
    _bounceController.forward(from: 0);
    _recordCurrentLesson();
  }

  void _recordCurrentLesson() {
    final item = _parts[_current];
    ref.read(progressServiceProvider).markModuleLesson('bodyparts', item.english);
  }

  // ── "Doctor says…" mini-game ──────────────────────────────────
  // Simon-says on the body chart: the doctor names a part (TTS), the child
  // taps it. 5 rounds; first-try hits earn a star each. Pure engagement —
  // turns a one-session module into a repeatable game.
  static const _dsTotalRounds = 5;
  final Random _dsRng = Random();
  bool _doctorSaysActive = false;
  int _dsRound = 0;
  int _dsTarget = -1;
  int _dsStars = 0;
  bool _dsFirstTry = true;
  bool? _dsLastTapCorrect;

  void _startDoctorSays() {
    setState(() {
      _doctorSaysActive = true;
      _dsRound = 1;
      _dsStars = 0;
      _dsFirstTry = true;
      _dsLastTapCorrect = null;
    });
    _nextDoctorPrompt();
  }

  void _stopDoctorSays() {
    setState(() {
      _doctorSaysActive = false;
      _dsTarget = -1;
      _dsLastTapCorrect = null;
    });
  }

  void _nextDoctorPrompt() {
    var next = _dsRng.nextInt(_parts.length);
    if (next == _dsTarget) next = (next + 1) % _parts.length;
    setState(() {
      _dsTarget = next;
      _dsFirstTry = true;
      _dsLastTapCorrect = null;
    });
    _speakDoctorPrompt();
  }

  Future<void> _speakDoctorPrompt() async {
    if (_dsTarget < 0) return;
    final ps = ref.read(progressServiceProvider);
    final isMalay = ps.language == AppLanguage.malay;
    final word = isMalay ? _parts[_dsTarget].malay : _parts[_dsTarget].english;
    await ref.read(audioServiceProvider).speakLocale(
          isMalay
              ? 'Doktor kata: sentuh $word!'
              : 'Doctor says: touch your $word!',
          enabled: ps.voiceEnabled,
          locale: isMalay ? 'ms-MY' : 'en-US',
        );
  }

  Future<void> _handleDoctorTap(int index) async {
    if (!_doctorSaysActive || _dsTarget < 0) return;
    final ps = ref.read(progressServiceProvider);
    final isMalay = ps.language == AppLanguage.malay;
    final audio = ref.read(audioServiceProvider);

    if (index == _dsTarget) {
      if (_dsFirstTry) _dsStars++;
      setState(() => _dsLastTapCorrect = true);
      await audio.speakLocale(
        isMalay ? 'Betul! Pandai!' : 'Correct! Well done!',
        enabled: ps.voiceEnabled,
        locale: isMalay ? 'ms-MY' : 'en-US',
      );
      if (!mounted) return;
      if (_dsRound >= _dsTotalRounds) {
        await _finishDoctorSays();
      } else {
        setState(() => _dsRound++);
        _nextDoctorPrompt();
      }
    } else {
      setState(() {
        _dsFirstTry = false;
        _dsLastTapCorrect = false;
      });
      await audio.speakLocale(
        isMalay ? 'Cuba lagi!' : 'Try again!',
        enabled: ps.voiceEnabled,
        locale: isMalay ? 'ms-MY' : 'en-US',
      );
    }
  }

  Future<void> _finishDoctorSays() async {
    final ps = ref.read(progressServiceProvider);
    final isMalay = ps.language == AppLanguage.malay;
    final earned = _dsStars;
    _stopDoctorSays();
    if (earned > 0) {
      await ps.addStars(earned);
      if (!mounted) return;
      XpPopup.show(context, amount: earned);
    }
    await ref.read(audioServiceProvider).speakLocale(
          isMalay
              ? 'Permainan tamat! Kamu dapat $earned bintang!'
              : 'Game over! You earned $earned stars!',
          enabled: ps.voiceEnabled,
          locale: isMalay ? 'ms-MY' : 'en-US',
        );
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
    final item = _parts[_current];
    final color = _color;
    final isMalay = language == AppLanguage.malay;
    final isFirst = _current == 0;
    final isLast = _current == _parts.length - 1;
    final mainWord = item.wordFor(language);

    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.moduleBodyParts,
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
              tag: 'module-emoji-${LearnBodyPartsScreen.routeName}',
              child: const Text('🧍', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMalay ? 'Anggota Badan' : 'Body Parts',
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
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: 0.20)),
                  ),
                  child: Row(
                    children: [
                      _BodyPartThumbnail(
                        asset: item.photoAsset,
                        color: color,
                        size: 36,
                      ),
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
                          // No constant pulse on the chart: the wobble made
                          // the tap spots feel misaligned and hurt precision.
                          ScaleTransition(
                            scale: _bounceAnim,
                            child: _DoctorBodyChart(
                              parts: _parts,
                              // No highlight during the game — it would
                              // leak hints.
                              selectedIndex:
                                  _doctorSaysActive ? -1 : _current,
                              language: language,
                              onSelect: _doctorSaysActive
                                  ? (i) => _handleDoctorTap(i)
                                  : _goToPart,
                            ),
                          ),

                          const SizedBox(height: 10),
                          _DoctorSaysBar(
                            active: _doctorSaysActive,
                            round: _dsRound,
                            total: _dsTotalRounds,
                            targetWord: _doctorSaysActive && _dsTarget >= 0
                                ? (isMalay
                                    ? _parts[_dsTarget].malay
                                    : _parts[_dsTarget].english)
                                : null,
                            lastCorrect: _dsLastTapCorrect,
                            isMalay: isMalay,
                            onStart: _startDoctorSays,
                            onStop: _stopDoctorSays,
                            onRepeat: _speakDoctorPrompt,
                          ),

                          const SizedBox(height: 12),
                          _PartPickerStrip(
                            parts: _parts,
                            selectedIndex: _current,
                            language: language,
                            onSelect: _goToPart,
                          ),

                          const SizedBox(height: 10),
                          _SelectedPartPhotoCard(
                            part: item,
                            language: language,
                          ),

                          const SizedBox(height: 14),

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

                          // All other languages — 2×2 grid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LangChip(
                                flag: 'BM',
                                text: item.malay,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              _LangChip(
                                flag: '中',
                                text: item.mandarin,
                                color: color,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LangChip(
                                flag: 'ID',
                                text: item.indonesian,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              _LangChip(
                                flag: 'த',
                                text: item.tamil,
                                color: color,
                              ),
                            ],
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
                    isMalay
                        ? '🎉 Tahniah! Kamu dah kenal semua anggota badan! 🧍'
                        : '🎉 Well done! You know all the body parts! 🧍',
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

class _DoctorBodyChart extends ConsumerWidget {
  const _DoctorBodyChart({
    required this.parts,
    required this.selectedIndex,
    required this.language,
    required this.onSelect,
  });

  final List<_BodyPart> parts;
  final int selectedIndex;
  final AppLanguage language;
  final ValueChanged<int> onSelect;

  // Fractional (x, y) positions measured against the actual
  // body_parts_doctor_photo.png asset (1024×1536, same 2:3 ratio as the
  // AspectRatio container, so no crop shift). Index order = _parts order.
  static const _spots = <_BodySpot>[
    _BodySpot(0, 0.50, 0.125, 18), // Head (forehead)
    _BodySpot(1, 0.50, 0.150, 13), // Eyes
    _BodySpot(2, 0.50, 0.175, 12), // Nose
    _BodySpot(3, 0.50, 0.205, 12), // Mouth
    _BodySpot(4, 0.565, 0.160, 12), // Ears (right ear)
    _BodySpot(5, 0.49, 0.090, 15), // Hair (top of head)
    _BodySpot(6, 0.50, 0.215, 10), // Teeth (in the smile)
    _BodySpot(7, 0.615, 0.275, 15), // Shoulder (right)
    _BodySpot(8, 0.715, 0.520, 16), // Hands (open right palm)
    _BodySpot(9, 0.285, 0.545, 13), // Fingers (left hand)
    _BodySpot(10, 0.50, 0.420, 18), // Stomach
    _BodySpot(11, 0.53, 0.760, 16), // Legs (shin)
    _BodySpot(12, 0.55, 0.680, 15), // Knees
    _BodySpot(13, 0.51, 0.930, 16), // Feet
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // selectedIndex == -1 → "Doctor says…" game mode: nothing highlighted
    // and no callout, so the chart cannot leak the answer.
    final _BodyPart? selected =
        (selectedIndex >= 0 && selectedIndex < parts.length)
            ? parts[selectedIndex]
            : null;
    final accent = selected?.color ?? AppTheme.moduleBodyParts;
    final label = selected?.wordFor(language);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 390),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepBlue.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (selected != null)
                _BodyPartThumbnail(
                  asset: selected.photoAsset,
                  color: selected.color,
                  size: 42,
                )
              else
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🩺', style: TextStyle(fontSize: 22)),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  language == AppLanguage.malay
                      ? 'Foto doktor: sentuh bahagian badan'
                      : 'Doctor photo: tap a body part',
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 2 / 3,
            // Pinch-zoom: spots live inside the same transformed subtree, so
            // they stay glued to the photo and remain tappable when zoomed.
            // panEnabled stays false so one-finger drags still scroll the page.
            child: InteractiveViewer(
              maxScale: 3,
              panEnabled: false,
              child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/body_parts_doctor_photo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.38),
                            width: 2,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.deepBlue.withValues(alpha: 0.12),
                            ],
                          ),
                        ),
                      ),
                    ),
                    for (final spot in _spots)
                      Positioned(
                        left: (spot.x * w) - spot.radius,
                        top: (spot.y * h) - spot.radius,
                        width: spot.radius * 2,
                        height: spot.radius * 2,
                        child: _BodySpotButton(
                          selected: spot.index == selectedIndex,
                          color: parts[spot.index].color,
                          label: parts[spot.index].wordFor(language),
                          onTap: () => onSelect(spot.index),
                        ),
                      ),
                    if (selected != null && label != null)
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 10,
                        child: _DoctorCallout(
                          color: selected.color,
                          label: label,
                          english: selected.english,
                        ),
                      ),
                  ],
                );
              },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedPartPhotoCard extends ConsumerWidget {
  const _SelectedPartPhotoCard({required this.part, required this.language});

  final _BodyPart part;
  final AppLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = part.wordFor(language);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 3,
      shadowColor: part.color.withValues(alpha: 0.16),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _showZoom(context, label),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: part.color.withValues(alpha: 0.20)),
          ),
          child: Row(
            children: [
              _ExactBodyPartPhoto(
                asset: part.photoAsset,
                color: part.color,
                size: 104,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == AppLanguage.malay
                          ? 'Foto sebenar bahagian ini'
                          : 'Real photo of this part',
                      style: const TextStyle(
                        color: Color(0xFF68789F),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: part.color,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      language == AppLanguage.malay
                          ? 'Tekan untuk zum foto sebenar.'
                          : 'Tap to zoom the real photo.',
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: part.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: part.color.withValues(alpha: 0.28)),
                ),
                child: Text(
                  language == AppLanguage.malay ? 'Zum' : 'Zoom',
                  style: TextStyle(
                    color: part.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showZoom(BuildContext context, String label) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.deepBlue.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: part.color,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ExactBodyPartPhoto(
                  asset: part.photoAsset,
                  color: part.color,
                  size: 260,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExactBodyPartPhoto extends ConsumerWidget {
  const _ExactBodyPartPhoto({
    required this.asset,
    required this.color,
    required this.size,
  });

  final String asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size > 120 ? 26 : 18),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.lightBlue,
          border: Border.all(color: color.withValues(alpha: 0.35), width: 2),
          borderRadius: BorderRadius.circular(size > 120 ? 26 : 18),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.lightBlue,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Photo',
                    style: TextStyle(color: color, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(size > 120 ? 26 : 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyPartThumbnail extends ConsumerWidget {
  const _BodyPartThumbnail({
    required this.asset,
    required this.color,
    required this.size,
  });

  final String asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ExactBodyPartPhoto(asset: asset, color: color, size: size);
  }
}

class _BodySpot {
  const _BodySpot(this.index, this.x, this.y, this.radius);

  final int index;
  final double x;
  final double y;
  final double radius;
}

class _BodySpotButton extends ConsumerWidget {
  const _BodySpotButton({
    required this.selected,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected ? color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.white : color,
                width: selected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: selected ? 0.42 : 0.18),
                  blurRadius: selected ? 14 : 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: selected ? 9 : 7,
                height: selected ? 9 : 7,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorCallout extends ConsumerWidget {
  const _DoctorCallout({
    required this.color,
    required this.label,
    required this.english,
  });

  final Color color;
  final String label;
  final String english;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label == english ? label : '$label  •  $english',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Kept as a code-native fallback if the photo asset is unavailable in a future
// build variant.
// ignore: unused_element
class _BodyChartPainter extends CustomPainter {
  const _BodyChartPainter({required this.selectedPart, required this.color});

  final String selectedPart;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final skin = Paint()..color = const Color(0xFFFFD6B1);
    final skinShade = Paint()..color = const Color(0xFFEBAE82);
    final hair = Paint()..color = const Color(0xFF4B3428);
    final outline = Paint()
      ..color = const Color(0xFF31557E).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final shirt = Paint()..color = const Color(0xFFBDEFFF);
    final shorts = Paint()..color = const Color(0xFF7A5CFF);
    final highlight = Paint()
      ..color = color.withValues(alpha: 0.34)
      ..style = PaintingStyle.fill;
    final highlightStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final board = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.04, h * 0.02, w * 0.92, h * 0.94),
      const Radius.circular(24),
    );
    canvas.drawRRect(board, Paint()..color = Colors.white);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.17),
        width: w * 0.24,
        height: h * 0.17,
      ),
      skin,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.125),
        width: w * 0.25,
        height: h * 0.12,
      ),
      3.08,
      3.28,
      false,
      hair
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.045,
    );
    hair
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.36, h * 0.17),
        width: w * 0.05,
        height: h * 0.055,
      ),
      skin,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.64, h * 0.17),
        width: w * 0.05,
        height: h * 0.055,
      ),
      skin,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.285),
          width: w * 0.12,
          height: h * 0.07,
        ),
        const Radius.circular(14),
      ),
      skin,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.46, h * 0.15),
        width: w * 0.025,
        height: h * 0.015,
      ),
      Paint()..color = AppTheme.ink,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.54, h * 0.15),
        width: w * 0.025,
        height: h * 0.015,
      ),
      Paint()..color = AppTheme.ink,
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.165),
      Offset(w * 0.49, h * 0.19),
      outline,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.215),
        width: w * 0.08,
        height: h * 0.035,
      ),
      0.1,
      2.9,
      false,
      outline,
    );
    canvas.drawLine(
      Offset(w * 0.47, h * 0.225),
      Offset(w * 0.53, h * 0.225),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );

    final torso = Path()
      ..moveTo(w * 0.36, h * 0.31)
      ..quadraticBezierTo(w * 0.50, h * 0.27, w * 0.64, h * 0.31)
      ..lineTo(w * 0.62, h * 0.58)
      ..quadraticBezierTo(w * 0.50, h * 0.64, w * 0.38, h * 0.58)
      ..close();
    canvas.drawPath(torso, shirt);
    canvas.drawPath(torso, outline);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.39, h * 0.57, w * 0.22, h * 0.095),
        const Radius.circular(16),
      ),
      shorts,
    );

    _drawLimb(
      canvas,
      skin,
      outline,
      Offset(w * 0.36, h * 0.33),
      Offset(w * 0.24, h * 0.53),
      w * 0.045,
    );
    _drawLimb(
      canvas,
      skin,
      outline,
      Offset(w * 0.64, h * 0.33),
      Offset(w * 0.76, h * 0.53),
      w * 0.045,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.22, h * 0.59),
        width: w * 0.085,
        height: h * 0.07,
      ),
      skin,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.78, h * 0.59),
        width: w * 0.085,
        height: h * 0.07,
      ),
      skin,
    );

    _drawLimb(
      canvas,
      skin,
      outline,
      Offset(w * 0.44, h * 0.65),
      Offset(w * 0.40, h * 0.88),
      w * 0.052,
    );
    _drawLimb(
      canvas,
      skin,
      outline,
      Offset(w * 0.56, h * 0.65),
      Offset(w * 0.60, h * 0.88),
      w * 0.052,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.39, h * 0.94),
        width: w * 0.14,
        height: h * 0.055,
      ),
      skinShade,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.61, h * 0.94),
        width: w * 0.14,
        height: h * 0.055,
      ),
      skinShade,
    );

    _drawHighlight(canvas, size, selectedPart, highlight, highlightStroke);
  }

  void _drawLimb(
    Canvas canvas,
    Paint fill,
    Paint outline,
    Offset start,
    Offset end,
    double width,
  ) {
    final limb = Paint()
      ..color = fill.color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, limb);
    canvas.drawLine(start, end, outline);
  }

  void _drawHighlight(
    Canvas canvas,
    Size size,
    String part,
    Paint fill,
    Paint stroke,
  ) {
    final w = size.width;
    final h = size.height;

    void oval(double cx, double cy, double ww, double hh) {
      final rect = Rect.fromCenter(
        center: Offset(w * cx, h * cy),
        width: w * ww,
        height: h * hh,
      );
      canvas.drawOval(rect, fill);
      canvas.drawOval(rect, stroke);
    }

    void rrect(double l, double t, double ww, double hh) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * l, h * t, w * ww, h * hh),
        const Radius.circular(18),
      );
      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, stroke);
    }

    switch (part) {
      case 'Hair':
        oval(0.5, 0.095, 0.22, 0.09);
        break;
      case 'Head':
        oval(0.5, 0.17, 0.29, 0.2);
        break;
      case 'Eyes':
        oval(0.46, 0.15, 0.07, 0.045);
        oval(0.54, 0.15, 0.07, 0.045);
        break;
      case 'Ears':
        oval(0.36, 0.17, 0.08, 0.08);
        oval(0.64, 0.17, 0.08, 0.08);
        break;
      case 'Nose':
        oval(0.5, 0.18, 0.07, 0.06);
        break;
      case 'Mouth':
      case 'Teeth':
        oval(0.5, part == 'Teeth' ? 0.228 : 0.215, 0.13, 0.05);
        break;
      case 'Shoulder':
        rrect(0.32, 0.30, 0.36, 0.09);
        break;
      case 'Hands':
        oval(0.22, 0.59, 0.12, 0.1);
        oval(0.78, 0.59, 0.12, 0.1);
        break;
      case 'Fingers':
        oval(0.16, 0.62, 0.11, 0.08);
        oval(0.84, 0.62, 0.11, 0.08);
        break;
      case 'Stomach':
        oval(0.5, 0.49, 0.25, 0.17);
        break;
      case 'Legs':
        rrect(0.36, 0.64, 0.28, 0.27);
        break;
      case 'Knees':
        oval(0.41, 0.79, 0.11, 0.08);
        oval(0.59, 0.79, 0.11, 0.08);
        break;
      case 'Feet':
        oval(0.39, 0.94, 0.16, 0.07);
        oval(0.61, 0.94, 0.16, 0.07);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BodyChartPainter oldDelegate) {
    return oldDelegate.selectedPart != selectedPart ||
        oldDelegate.color != color;
  }
}

class _PartPickerStrip extends ConsumerWidget {
  const _PartPickerStrip({
    required this.parts,
    required this.selectedIndex,
    required this.language,
    required this.onSelect,
  });

  final List<_BodyPart> parts;
  final int selectedIndex;
  final AppLanguage language;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: parts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final part = parts[index];
          final selected = index == selectedIndex;
          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            avatar: _BodyPartThumbnail(
              asset: part.photoAsset,
              color: selected ? Colors.white : part.color,
              size: 24,
            ),
            label: Text(part.wordFor(language)),
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppTheme.ink,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
            selectedColor: part.color,
            backgroundColor: part.color.withValues(alpha: 0.10),
            side: BorderSide(color: part.color.withValues(alpha: 0.25)),
            onSelected: (_) => onSelect(index),
          );
        },
      ),
    );
  }
}

/// Small chip showing a flag + translated word.
class _LangChip extends ConsumerWidget {
  const _LangChip({
    required this.flag,
    required this.text,
    required this.color,
  });

  final String flag;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Text(
            flag,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
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

class _BodyPronounceButtons extends ConsumerWidget {
  const _BodyPronounceButtons({
    required this.onSpeak,
    required this.item,
    required this.color,
  });

  final Future<void> Function(String word, String locale) onSpeak;
  final _BodyPart item;
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
    final raw = switch (locale) {
      'ms-MY' => item.malay,
      'en-US' => item.english,
      'zh-CN' => item.mandarin,
      'id-ID' => item.indonesian,
      'ta-IN' => item.tamil,
      _ => item.english,
    };
    // Strip parenthetical romanisation (e.g. "头 (Tóu)" → "头",
    // "தலை (Talai)" → "தலை") so TTS engines only receive the target script.
    return raw.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            ref.watch(progressServiceProvider).language == AppLanguage.malay
                ? '🔊 Sebut dalam:'
                : '🔊 Say it in:',
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
    required this.photoAsset,
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
  final String photoAsset;

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

// ── "Doctor says…" control bar ───────────────────────────────────────────────
class _DoctorSaysBar extends StatelessWidget {
  const _DoctorSaysBar({
    required this.active,
    required this.round,
    required this.total,
    required this.targetWord,
    required this.lastCorrect,
    required this.isMalay,
    required this.onStart,
    required this.onStop,
    required this.onRepeat,
  });

  final bool active;
  final int round;
  final int total;
  final String? targetWord;
  final bool? lastCorrect;
  final bool isMalay;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    const color = AppTheme.moduleBodyParts;

    if (!active) {
      return Pressable(
        onTap: onStart,
        pressedScale: 0.97,
        semanticLabel: isMalay
            ? 'Mula permainan Doktor Kata'
            : 'Start Doctor Says game',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.78)],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🩺', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMalay ? 'Doktor Kata!' : 'Doctor Says!',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isMalay
                          ? 'Dengar dan sentuh anggota yang betul • ⭐ setiap betul'
                          : 'Listen and touch the right part • ⭐ per correct',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill_rounded,
                  color: Colors.white, size: 30),
            ],
          ),
        ),
      );
    }

    final feedbackEmoji = lastCorrect == null
        ? '🩺'
        : lastCorrect == true
            ? '✅'
            : '❌';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Text(feedbackEmoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMalay
                      ? 'Pusingan $round/$total — sentuh:'
                      : 'Round $round/$total — touch:',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.inkMuted,
                  ),
                ),
                Text(
                  targetWord ?? '…',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRepeat,
            tooltip: isMalay ? 'Ulang arahan' : 'Repeat instruction',
            icon: const Icon(Icons.volume_up_rounded, color: color),
          ),
          IconButton(
            onPressed: onStop,
            tooltip: isMalay ? 'Berhenti' : 'Stop',
            icon: const Icon(Icons.close_rounded, color: AppTheme.inkMuted),
          ),
        ],
      ),
    );
  }
}
