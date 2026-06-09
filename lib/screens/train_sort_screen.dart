import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_language.dart';
import '../models/train_mode.dart';
import '../utils/app_text.dart';
import '../widgets/star_counter.dart';
import 'home_screen.dart';

class TrainSortArgs {
  const TrainSortArgs({required this.mode});

  final TrainMode mode;
}

class TrainSortScreen extends ConsumerStatefulWidget {
  const TrainSortScreen({super.key});

  static const routeName = '/train-sort';

  @override
  ConsumerState<TrainSortScreen> createState() => _TrainSortScreenState();
}

class _TrainSortScreenState extends ConsumerState<TrainSortScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _trainController;
  late TrainMode _mode;
  List<String> _targetOrder = const [];
  List<String> _yard = const [];
  final List<String> _placed = [];
  String? _wrongValue;
  bool _ready = false;
  bool _completed = false;
  int _numberGroupStart = 0; // index into _allNumbers
  int _letterGroupStart = 0; // index into _allLetters

  static final _allNumbers = List.generate(100, (i) => '${i + 1}');
  static const _allLetters = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  ];

  String get _prefKey => 'train_group_${_mode.name}';

  @override
  void initState() {
    super.initState();
    _trainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final args = ModalRoute.of(context)?.settings.arguments as TrainSortArgs?;
    _mode = args?.mode ?? TrainMode.numbers;
    _ready = true;
    _loadGroupAndStart();
  }

  Future<void> _loadGroupAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_prefKey) ?? 0;
    if (_mode == TrainMode.numbers) {
      _numberGroupStart = saved % _allNumbers.length;
    } else {
      _letterGroupStart = saved % _allLetters.length;
    }
    if (mounted) _startRound(advance: false);
  }

  Future<void> _saveGroupIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = _mode == TrainMode.numbers ? _numberGroupStart : _letterGroupStart;
    await prefs.setInt(_prefKey, idx);
  }

  @override
  void dispose() {
    _trainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressServiceProvider);
    final language = progress.language;
    final nextValue = _placed.length < _targetOrder.length
        ? _targetOrder[_placed.length]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.trainTitle(_mode, language)),
        actions: [
          IconButton(
            tooltip: 'New game',
            onPressed: _startRound,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: StarCounter()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TrainHeader(
                mode: _mode,
                nextValue: nextValue,
                language: language,
                placedCount: _placed.length,
                totalCount: _targetOrder.length,
              ),
              const SizedBox(height: 14),
              _TrainTrack(
                mode: _mode,
                animation: _trainController,
                placed: _placed,
                targetOrder: _targetOrder,
                // Lets a child drag a choice car straight onto the next
                // empty slot instead of only tapping it.
                onCarDropped: _choose,
              ),
              const SizedBox(height: 14),
              if (_wrongValue != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    AppText.ui('tryNextCar', language),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFC62828),
                    ),
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  itemCount: _yard.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    final value = _yard[index];
                    return _TrainChoiceCar(
                      value: value,
                      color: _mode.color,
                      wrong: value == _wrongValue,
                      onTap: () => _choose(value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startRound({bool advance = true}) {
    List<String> order;
    if (_mode == TrainMode.numbers) {
      if (advance) {
        _numberGroupStart = (_numberGroupStart + 5) % _allNumbers.length;
      }
      final start = _numberGroupStart.clamp(0, _allNumbers.length - 5);
      order = _allNumbers.sublist(start, start + 5);
    } else {
      if (advance) {
        _letterGroupStart = (_letterGroupStart + 5) % _allLetters.length;
      }
      final start = _letterGroupStart.clamp(0, _allLetters.length - 5);
      order = _allLetters.sublist(start, start + 5);
    }
    _saveGroupIndex();
    final yard = [...order]..shuffle();
    setState(() {
      _targetOrder = order;
      _yard = yard;
      _placed.clear();
      _wrongValue = null;
      _completed = false;
    });
  }

  Future<void> _choose(String value) async {
    if (_completed || _placed.length >= _targetOrder.length) {
      return;
    }

    final progressService = ref.read(progressServiceProvider);
    final audioService = ref.read(audioServiceProvider);
    final expected = _targetOrder[_placed.length];

    if (value != expected) {
      setState(() {
        _wrongValue = value;
      });
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (mounted) {
        setState(() {
          _wrongValue = null;
        });
      }
      return;
    }

    await audioService.speak(
      AppText.trainSpeechValue(_mode, value, progressService.language),
      enabled: progressService.voiceEnabled,
      language: progressService.language,
    );

    setState(() {
      _yard = _yard.where((item) => item != value).toList();
      _placed.add(value);
      _wrongValue = null;
    });

    if (_placed.length == _targetOrder.length) {
      await _completeRound();
    }
  }

  Future<void> _completeRound() async {
    if (_completed) return;

    final progressService = ref.read(progressServiceProvider);
    final audioService = ref.read(audioServiceProvider);

    setState(() { _completed = true; });

    await progressService.completeChallenge(_mode.challengeMode);
    await audioService.playCelebration(enabled: progressService.soundEnabled);

    if (!mounted) return;

    final language = progressService.language;
    final isMalay = language == AppLanguage.malay;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 48)),
        content: Text(
          isMalay ? 'Tahniah! Kamu berjaya!' : 'Great job! Round complete!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _startRound(advance: true); // next group
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(isMalay ? 'Seterusnya' : 'Next'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _mode.color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _startRound(advance: false); // retry same group
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(isMalay ? 'Cuba Lagi' : 'Try Again'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).popUntil(
                        (route) => route.settings.name == HomeScreen.routeName);
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: Text(isMalay ? 'Laman Utama' : 'Home'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrainHeader extends ConsumerWidget {
  const _TrainHeader({
    required this.mode,
    required this.nextValue,
    required this.language,
    required this.placedCount,
    required this.totalCount,
  });

  final TrainMode mode;
  final String? nextValue;
  final AppLanguage language;
  final int placedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: mode.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(mode.icon, color: mode.color, size: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nextValue == null
                        ? AppText.ui('trainComplete', language)
                        : AppText.trainPrompt(mode, nextValue!, language),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$placedCount / $totalCount',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainTrack extends ConsumerWidget {
  const _TrainTrack({
    required this.mode,
    required this.animation,
    required this.placed,
    required this.targetOrder,
    required this.onCarDropped,
  });

  final TrainMode mode;
  final Animation<double> animation;
  final List<String> placed;
  final List<String> targetOrder;
  final ValueChanged<String> onCarDropped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 104,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Container(height: 5, color: const Color(0xFF24304F)),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final offset = (animation.value - 0.5) * 18;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(10, 22, 10, 0),
              child: Row(
                children: [
                  _Engine(color: mode.color),
                  for (var index = 0; index < targetOrder.length; index++) ...[
                    const SizedBox(width: 6),
                    _TrainCarSlot(
                      value: index < placed.length ? placed[index] : null,
                      color: mode.color,
                      // Only the next empty slot accepts a dropped car —
                      // dropping the right one completes that step.
                      isNextSlot: index == placed.length,
                      onCarDropped: index == placed.length ? onCarDropped : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Engine extends ConsumerWidget {
  const _Engine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 58,
      height: 54,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF24304F), width: 3),
      ),
      child: const Icon(Icons.train_rounded, color: Colors.white, size: 30),
    );
  }
}

class _TrainCarSlot extends ConsumerWidget {
  const _TrainCarSlot({
    required this.value,
    required this.color,
    this.isNextSlot = false,
    this.onCarDropped,
  });

  final String? value;
  final Color color;
  final bool isNextSlot;
  final ValueChanged<String>? onCarDropped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filled = value != null;

    Widget slot({bool highlighted = false}) => AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 42,
      height: 50,
      decoration: BoxDecoration(
        color: highlighted
            ? color.withValues(alpha: 0.22)
            : (filled ? Colors.white : Colors.white.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlighted
              ? color
              : (filled ? color : const Color(0xFFB5C3DE)),
          width: highlighted ? 4 : 3,
        ),
      ),
      child: Center(
        child: Text(
          value ?? '',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
        ),
      ),
    );

    if (!isNextSlot || onCarDropped == null) return slot();

    // The "next" empty slot doubles as a drop target — dragging the matching
    // choice car here completes the step the same way tapping it does.
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onCarDropped!(details.data),
      builder: (context, candidates, rejects) =>
          slot(highlighted: candidates.isNotEmpty),
    );
  }
}

class _TrainChoiceCar extends ConsumerWidget {
  const _TrainChoiceCar({
    required this.value,
    required this.color,
    required this.wrong,
    required this.onTap,
  });

  final String value;
  final Color color;
  final bool wrong;
  final VoidCallback onTap;

  Widget _card(BuildContext context, Color borderColor, {bool dimmed = false}) =>
      Material(
        color: wrong
            ? const Color(0xFFFFEBEE)
            : Colors.white.withValues(alpha: dimmed ? 0.35 : 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor, width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 84,
          height: 84,
          child: Center(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: borderColor),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = wrong ? const Color(0xFFC62828) : color;

    // Cars can be either tapped (original behavior, fully preserved) or
    // dragged onto the train's next empty slot — whichever a child finds
    // easier or more fun.
    return Draggable<String>(
      data: value,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.12, child: _card(context, borderColor)),
      ),
      childWhenDragging: _card(context, borderColor, dimmed: true),
      child: Material(
        color: wrong ? const Color(0xFFFFEBEE) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor, width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: borderColor),
            ),
          ),
        ),
      ),
    );
  }
}
