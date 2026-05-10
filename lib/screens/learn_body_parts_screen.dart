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
      malay: 'Kaki (tapak)',
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
                          ScaleTransition(
                            scale: _bounceAnim,
                            child: ScaleTransition(
                              scale: _pulseAnim,
                              child: _DoctorBodyChart(
                                parts: _parts,
                                selectedIndex: _current,
                                language: language,
                                onSelect: _goToPart,
                              ),
                            ),
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

class _DoctorBodyChart extends StatelessWidget {
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

  static const _spots = <_BodySpot>[
    _BodySpot(0, 0.52, 0.17, 18),
    _BodySpot(1, 0.52, 0.19, 14),
    _BodySpot(2, 0.52, 0.225, 13),
    _BodySpot(3, 0.52, 0.265, 13),
    _BodySpot(4, 0.65, 0.19, 13),
    _BodySpot(5, 0.51, 0.105, 14),
    _BodySpot(6, 0.52, 0.275, 12),
    _BodySpot(7, 0.62, 0.345, 16),
    _BodySpot(8, 0.25, 0.59, 16),
    _BodySpot(9, 0.20, 0.64, 13),
    _BodySpot(10, 0.52, 0.49, 18),
    _BodySpot(11, 0.54, 0.73, 18),
    _BodySpot(12, 0.55, 0.80, 16),
    _BodySpot(13, 0.55, 0.955, 16),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = parts[selectedIndex];
    final label = selected.wordFor(language);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 390),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: selected.color.withValues(alpha: 0.24)),
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
              _BodyPartThumbnail(
                asset: selected.photoAsset,
                color: selected.color,
                size: 42,
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
                            color: selected.color.withValues(alpha: 0.38),
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
        ],
      ),
    );
  }
}

class _SelectedPartPhotoCard extends StatelessWidget {
  const _SelectedPartPhotoCard({required this.part, required this.language});

  final _BodyPart part;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
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

class _ExactBodyPartPhoto extends StatelessWidget {
  const _ExactBodyPartPhoto({
    required this.asset,
    required this.color,
    required this.size,
  });

  final String asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
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

class _BodyPartThumbnail extends StatelessWidget {
  const _BodyPartThumbnail({
    required this.asset,
    required this.color,
    required this.size,
  });

  final String asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
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

class _BodySpotButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
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

class _DoctorCallout extends StatelessWidget {
  const _DoctorCallout({
    required this.color,
    required this.label,
    required this.english,
  });

  final Color color;
  final String label;
  final String english;

  @override
  Widget build(BuildContext context) {
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

class _PartPickerStrip extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
