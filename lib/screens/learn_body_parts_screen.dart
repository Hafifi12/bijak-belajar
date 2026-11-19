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
  ConsumerState<LearnBodyPartsScreen> createState() =>
      _LearnBodyPartsScreenState();
}

class _LearnBodyPartsScreenState extends ConsumerState<LearnBodyPartsScreen> {
  int _current = 0;
  bool _recordedInitial = false;

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
      _recordCurrentLesson();
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() => _current--);
      _recordCurrentLesson();
    }
  }

  void _goToPart(int index) {
    if (index < 0 || index >= _parts.length || index == _current) {
      return;
    }
    setState(() => _current = index);
    _recordCurrentLesson();
  }

  void _recordCurrentLesson() {
    final item = _parts[_current];
    ref
        .read(progressServiceProvider)
        .markModuleLesson('bodyparts', item.english);
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
    final language = ps.language;
    final word = language.usesMalayCopy ? _parts[_dsTarget].malay : _parts[_dsTarget].english;
    await ref
        .read(audioServiceProvider)
        .speakLocale(
          language.copy(ms: 'Doktor kata: sentuh $word!', en: 'Doctor says: touch your $word!', zh: '医生说：请触摸你的$word！', ta: 'மருத்துவர் சொல்கிறார்: உன் $word-ஐத் தொடு!'),
          enabled: ps.voiceEnabled,
          locale: language.ttsLocale,
        );
  }

  Future<void> _handleDoctorTap(int index) async {
    if (!_doctorSaysActive || _dsTarget < 0) return;
    final ps = ref.read(progressServiceProvider);
    final language = ps.language;
    final audio = ref.read(audioServiceProvider);

    if (index == _dsTarget) {
      if (_dsFirstTry) _dsStars++;
      setState(() => _dsLastTapCorrect = true);
      await audio.speakLocale(
        language.copy(ms: 'Betul! Pandai!', en: 'Correct! Well done!', zh: '正确！做得好！', ta: 'சரி! நன்று!'),
        enabled: ps.voiceEnabled,
        locale: language.ttsLocale,
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
        language.copy(ms: 'Cuba lagi!', en: 'Try again!', zh: '再试一次！', ta: 'மீண்டும் முயற்சி செய்!'),
        enabled: ps.voiceEnabled,
        locale: language.ttsLocale,
      );
    }
  }

  Future<void> _finishDoctorSays() async {
    final ps = ref.read(progressServiceProvider);
    final language = ps.language;
    final earned = _dsStars;
    _stopDoctorSays();
    if (earned > 0) {
      await ps.addStars(earned);
      if (!mounted) return;
      XpPopup.show(context, amount: earned);
    }
    await ref
        .read(audioServiceProvider)
        .speakLocale(
          language.copy(ms: 'Permainan tamat! Kamu dapat $earned bintang!', en: 'Game over! You earned $earned stars!', zh: '游戏结束！你获得了 $earned 颗星星！', ta: 'விளையாட்டு முடிந்தது! நீ $earned நட்சத்திரங்கள் பெற்றாய்!'),
          enabled: ps.voiceEnabled,
          locale: language.ttsLocale,
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

  void _finishLesson() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(progressServiceProvider).language;
    final item = _parts[_current];
    final isFirst = _current == 0;
    final isLast = _current == _parts.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.nightMid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const NightBar(AppTheme.moduleBodyParts),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: language.copy(ms: 'Kembali', en: 'Back', zh: '返回', ta: 'பின்செல்'),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language.copy(ms: 'Anggota Badan', en: 'Body Parts', zh: '身体部位', ta: 'உடல் பாகங்கள்'),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            Text(
              language.copy(ms: 'Bahagian ${_current + 1} daripada ${_parts.length}', en: 'Part ${_current + 1} of ${_parts.length}', zh: '第 ${_current + 1} 部分，共 ${_parts.length} 部分', ta: 'பகுதி ${_current + 1} / ${_parts.length}'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w700,
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
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (_current + 1) / _parts.length,
                          minHeight: 10,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.sunnyYellow,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_current + 1} / ${_parts.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: Column(
                    children: [
                      _DoctorBodyChart(
                        key: const Key('body-anatomy-stage'),
                        parts: _parts,
                        selectedIndex: _doctorSaysActive ? -1 : _current,
                        language: language,
                        gameTarget: _doctorSaysActive ? _dsTarget : null,
                        onSelect: _doctorSaysActive
                            ? _handleDoctorTap
                            : _goToPart,
                      ),
                      const SizedBox(height: 12),
                      if (_doctorSaysActive)
                        _DoctorSaysBar(
                          active: true,
                          round: _dsRound,
                          total: _dsTotalRounds,
                          targetWord: _dsTarget >= 0
                              ? (language.usesMalayCopy
                                    ? _parts[_dsTarget].malay
                                    : _parts[_dsTarget].english)
                              : null,
                          lastCorrect: _dsLastTapCorrect,
                          language: language,
                          onStart: _startDoctorSays,
                          onStop: _stopDoctorSays,
                          onRepeat: _speakDoctorPrompt,
                        )
                      else ...[
                        _BodyVocabularyCard(
                          key: const Key('body-vocabulary-card'),
                          part: item,
                          language: language,
                          onSpeak: _speakIn,
                        ),
                        const SizedBox(height: 12),
                        _PartPickerStrip(
                          parts: _parts,
                          selectedIndex: _current,
                          language: language,
                          onSelect: _goToPart,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            key: const Key('body-doctor-says-button'),
                            onPressed: _startDoctorSays,
                            icon: const Icon(Icons.medical_services_rounded),
                            label: Text(
                              language.copy(ms: 'Main “Doktor Kata”', en: 'Play “Doctor Says”', zh: '玩“医生说”', ta: '“மருத்துவர் சொல்கிறார்” விளையாடு'),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.deepBlue,
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: AppTheme.sunnyYellow,
                                width: 3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!_doctorSaysActive)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: AppTheme.nightMid.withValues(alpha: 0.98),
                    border: const Border(
                      top: BorderSide(color: Colors.white24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            key: const Key('body-back-button'),
                            onPressed: isFirst ? null : _prev,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 21,
                            ),
                            label: _ResponsiveButtonLabel(
                              language.copy(ms: 'Sebelum', en: 'Back', zh: '返回', ta: 'பின்செல்'),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white38,
                              side: BorderSide(
                                color: isFirst
                                    ? Colors.white24
                                    : Colors.white54,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            key: const Key('body-next-button'),
                            onPressed: isLast ? _finishLesson : _next,
                            label: _ResponsiveButtonLabel(
                              isLast
                                  ? (language.copy(ms: 'Selesai', en: 'Finish', zh: '完成', ta: 'முடி'))
                                  : (language.copy(ms: 'Seterusnya', en: 'Next', zh: '下一步', ta: 'அடுத்தது')),
                            ),
                            icon: Icon(
                              isLast
                                  ? Icons.check_circle_rounded
                                  : Icons.arrow_forward_rounded,
                            ),
                            iconAlignment: IconAlignment.end,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLast
                                  ? AppTheme.leafGreen
                                  : AppTheme.skyBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsiveButtonLabel extends StatelessWidget {
  const _ResponsiveButtonLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _BodyVocabularyCard extends StatelessWidget {
  const _BodyVocabularyCard({
    super.key,
    required this.part,
    required this.language,
    required this.onSpeak,
  });

  final _BodyPart part;
  final AppLanguage language;
  final Future<void> Function(String, String) onSpeak;

  @override
  Widget build(BuildContext context) {
    final word = part.wordFor(language);
    final translations = <(String, String, String)>[
      ('BM', part.malay, 'ms-MY'),
      ('EN', part.english, 'en-US'),
      ('中', part.mandarin, 'zh-CN'),
      ('ID', part.indonesian, 'id-ID'),
      ('த', part.tamil, 'ta-IN'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: part.color.withValues(alpha: 0.28), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BodyPartThumbnail(
                asset: part.photoAsset,
                color: part.color,
                size: 58,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: part.color,
                        fontSize: 30,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (word != part.english) ...[
                      const SizedBox(height: 5),
                      Text(
                        part.english,
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 52,
                height: 52,
                child: IconButton.filled(
                  onPressed: () => onSpeak(word, language.ttsLocale),
                  tooltip: 'Pronounce $word',
                  style: IconButton.styleFrom(backgroundColor: part.color),
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in translations)
                ActionChip(
                  avatar: Text(
                    entry.$1,
                    style: TextStyle(
                      color: part.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  label: Text(
                    entry.$2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  onPressed: () => onSpeak(entry.$2, entry.$3),
                  backgroundColor: part.color.withValues(alpha: 0.09),
                  side: BorderSide(color: part.color.withValues(alpha: 0.22)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorBodyChart extends StatelessWidget {
  const _DoctorBodyChart({
    super.key,
    required this.parts,
    required this.selectedIndex,
    required this.language,
    required this.onSelect,
    this.gameTarget,
  });

  final List<_BodyPart> parts;
  final int selectedIndex;
  final AppLanguage language;
  final ValueChanged<int> onSelect;
  final int? gameTarget;

  static const _spots = <_BodySpot>[
    _BodySpot(0, 0.50, 0.125, _Side.left, 0.15),
    _BodySpot(1, 0.50, 0.150, _Side.left, 0.27),
    _BodySpot(2, 0.50, 0.175, _Side.left, 0.39),
    _BodySpot(3, 0.50, 0.205, _Side.left, 0.51),
    _BodySpot(4, 0.565, 0.160, _Side.right, 0.10),
    _BodySpot(5, 0.49, 0.090, _Side.left, 0.04),
    _BodySpot(6, 0.50, 0.215, _Side.right, 0.22),
    _BodySpot(7, 0.615, 0.275, _Side.right, 0.34),
    _BodySpot(8, 0.715, 0.520, _Side.right, 0.58),
    _BodySpot(9, 0.285, 0.545, _Side.left, 0.63),
    _BodySpot(10, 0.50, 0.420, _Side.right, 0.46),
    _BodySpot(11, 0.53, 0.760, _Side.right, 0.84),
    _BodySpot(12, 0.55, 0.680, _Side.right, 0.72),
    _BodySpot(13, 0.51, 0.930, _Side.left, 0.92),
  ];

  static String _shortLabel(String raw) =>
      raw.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();

  void _selectNearest(Offset point, Size size) {
    // One gesture surface owns the whole anatomy image. This deliberately avoids
    // stacked hit regions around the face, where eyes, nose, mouth and teeth sit
    // close together. The closest anatomical point always wins deterministically.
    var nearest = _spots.first;
    var distance = double.infinity;
    for (final spot in _spots) {
      final dx = point.dx - spot.tx * size.width;
      final dy = point.dy - spot.ty * size.height;
      final candidate = dx * dx + dy * dy;
      if (candidate < distance) {
        distance = candidate;
        nearest = spot;
      }
    }
    onSelect(nearest.index);
  }

  @override
  Widget build(BuildContext context) {
    final gameMode = selectedIndex < 0;
    final selected = !gameMode && selectedIndex < parts.length
        ? parts[selectedIndex]
        : null;
    final accent = selected?.color ?? AppTheme.moduleBodyParts;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.32), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  gameMode
                      ? Icons.medical_services_rounded
                      : Icons.touch_app_rounded,
                  color: accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameMode
                          ? (language.copy(ms: 'Doktor kata: sentuh bahagian yang disebut', en: 'Doctor says: touch the named body part', zh: '医生说：请触摸说出的身体部位', ta: 'மருத்துவர் சொல்கிறார்: சொல்லப்பட்ட உடல் பாகத்தைத் தொடு'))
                          : (language.copy(ms: 'Tekan mana-mana bahagian badan', en: 'Tap any body part', zh: '点击任意身体部位', ta: 'எந்த உடல் பாகத்தையும் தட்டு')),
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      language.copy(ms: 'Ikut anak panah atau pilih daripada senarai', en: 'Follow the arrow or choose from the list', zh: '跟随箭头，或从列表中选择', ta: 'அம்புக்குறியைப் பின்பற்று அல்லது பட்டியலிலிருந்து தேர்ந்தெடு'),
                      style: const TextStyle(
                        color: Color(0xFF68789F),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final imageWidth = min(220.0, constraints.maxWidth);
              final imageSize = Size(imageWidth, imageWidth * 1.5);
              return Center(
                child: SizedBox(
                  width: imageSize.width,
                  height: imageSize.height,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) =>
                        _selectNearest(details.localPosition, imageSize),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/images/body_parts_doctor_photo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.4),
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
                        ),
                        if (selected != null)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: _SelectedPartPointer(
                                spot: _spots[selectedIndex],
                                text: _shortLabel(selected.wordFor(language)),
                                color: selected.color,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SelectedPartPointer extends StatelessWidget {
  const _SelectedPartPointer({
    required this.spot,
    required this.text,
    required this.color,
  });

  final _BodySpot spot;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const labelWidth = 92.0;
        const labelHeight = 34.0;
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final labelLeft = spot.side == _Side.left
            ? 8.0
            : size.width - labelWidth - 8;
        final labelTop = (spot.slot * size.height - labelHeight / 2).clamp(
          8.0,
          size.height - labelHeight - 8,
        );
        final labelCenter = Offset(
          labelLeft + labelWidth / 2,
          labelTop + labelHeight / 2,
        );
        final target = Offset(spot.tx * size.width, spot.ty * size.height);

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BodyPartArrowPainter(
                  start: labelCenter,
                  target: target,
                  color: color,
                ),
              ),
            ),
            Positioned(
              left: labelLeft,
              top: labelTop,
              child: _PartNameTag(text: text, color: color, width: labelWidth),
            ),
          ],
        );
      },
    );
  }
}

class _BodyPartArrowPainter extends CustomPainter {
  const _BodyPartArrowPainter({
    required this.start,
    required this.target,
    required this.color,
  });

  final Offset start;
  final Offset target;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final delta = target - start;
    final length = delta.distance;
    if (length == 0) return;

    final direction = delta / length;
    final normal = Offset(-direction.dy, direction.dx);
    final arrowBase = target - direction * 12;
    final outline = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final line = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, arrowBase, outline);
    canvas.drawLine(start, arrowBase, line);

    final arrow = Path()
      ..moveTo(target.dx, target.dy)
      ..lineTo(arrowBase.dx + normal.dx * 7, arrowBase.dy + normal.dy * 7)
      ..lineTo(arrowBase.dx - normal.dx * 7, arrowBase.dy - normal.dy * 7)
      ..close();
    canvas.drawPath(arrow, Paint()..color = Colors.white);
    canvas.drawPath(
      arrow,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _BodyPartArrowPainter oldDelegate) =>
      oldDelegate.start != start ||
      oldDelegate.target != target ||
      oldDelegate.color != color;
}

/// Floating name label for the current body part, shown just above its hotspot.
class _PartNameTag extends StatelessWidget {
  const _PartNameTag({
    required this.text,
    required this.color,
    required this.width,
  });

  final String text;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
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

enum _Side { left, right }

class _BodySpot {
  const _BodySpot(this.index, this.tx, this.ty, this.side, this.slot);

  final int index;
  final double tx; // anatomical target x (0..1 of width)
  final double ty; // anatomical target y (0..1 of height)
  final _Side side; // which gutter the label pin sits in
  final double slot; // label pin vertical centre (0..1 of height)
}

// Kept as a code-native fallback if the photo asset is unavailable in a future
// build variant.
// ignore: unused_element
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
// ── "Doctor says…" control bar ───────────────────────────────────────────────
class _DoctorSaysBar extends StatelessWidget {
  const _DoctorSaysBar({
    required this.active,
    required this.round,
    required this.total,
    required this.targetWord,
    required this.lastCorrect,
    required this.language,
    required this.onStart,
    required this.onStop,
    required this.onRepeat,
  });

  final bool active;
  final int round;
  final int total;
  final String? targetWord;
  final bool? lastCorrect;
  final AppLanguage language;
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
        semanticLabel: language.copy(ms: 'Mula permainan Doktor Kata', en: 'Start Doctor Says game', zh: '开始“医生说”游戏', ta: '“மருத்துவர் சொல்கிறார்” விளையாட்டைத் தொடங்கு'),
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
                      language.copy(ms: 'Doktor Kata!', en: 'Doctor Says!', zh: '医生说！', ta: 'மருத்துவர் சொல்கிறார்!'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      language.copy(ms: 'Dengar dan sentuh anggota yang betul • ⭐ setiap betul', en: 'Listen and touch the right part • ⭐ per correct', zh: '听指令，触摸正确的部位 • 每答对一次 ⭐', ta: 'கேட்டு சரியான பகுதியைத் தொடு • சரியான ஒவ்வொரு முறைக்கும் ⭐'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 30,
              ),
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
                  language.copy(ms: 'Pusingan $round/$total — sentuh:', en: 'Round $round/$total — touch:', zh: '第 $round/$total 轮 — 请触摸：', ta: 'சுற்று $round/$total — தொடு:'),
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
            tooltip: language.copy(ms: 'Ulang arahan', en: 'Repeat instruction', zh: '重复指令', ta: 'அறிவுறுத்தலை மீண்டும் கேள்'),
            icon: const Icon(Icons.volume_up_rounded, color: color),
          ),
          IconButton(
            onPressed: onStop,
            tooltip: language.copy(ms: 'Berhenti', en: 'Stop', zh: '停止', ta: 'நிறுத்து'),
            icon: const Icon(Icons.close_rounded, color: AppTheme.inkMuted),
          ),
        ],
      ),
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
