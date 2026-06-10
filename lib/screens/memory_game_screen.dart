import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../data/memory_data.dart';
import '../models/app_language.dart';
import '../models/challenge.dart';
import '../models/memory_item.dart';
import '../utils/app_text.dart';
import '../widgets/shape_display.dart';
import '../widgets/star_counter.dart';
import 'reward_screen.dart';

class MemoryGameArgs {
  const MemoryGameArgs({required this.category, this.stage = MemoryStage.easy});

  final MemoryCategory category;
  final MemoryStage stage;
}

class MemoryGameScreen extends ConsumerStatefulWidget {
  const MemoryGameScreen({super.key});

  static const routeName = '/memory-game';

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen> {
  late MemoryCategory _category;
  late MemoryStage _stage;
  List<_MemoryCardEntry> _cards = const [];
  final Set<String> _faceUp = {};
  final Set<String> _matched = {};
  String? _firstCardId;
  bool _busy = false;
  bool _completed = false;
  bool _previewing = false;
  bool _ready = false;
  int _gameToken = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments as MemoryGameArgs?;
    _category = args?.category ?? MemoryCategory.animals;
    _stage = args?.stage ?? MemoryStage.easy;
    _ready = true;
    _startNewGame();
  }

  @override
  Widget build(BuildContext context) {
    final category = _category;
    final language = ref.watch(progressServiceProvider).language;
    final matchedPairs = _matched.length ~/ 2;
    final totalPairs = _cards.length ~/ 2;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: language == AppLanguage.malay ? 'Kembali' : 'Back',
        ),
        title: Text(AppText.categoryTitle(category, language)),
        actions: [
          IconButton(
            tooltip: 'New game',
            onPressed: _busy ? null : _startNewGame,
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
              _MemoryHeader(
                category: category,
                stage: _stage,
                matchedPairs: matchedPairs,
                totalPairs: totalPairs,
                previewing: _previewing,
                language: language,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = _stage.gridSize;
                    final spacing = switch (_stage) {
                      MemoryStage.easy => 10.0,
                      MemoryStage.normal => 8.0,
                      MemoryStage.medium => 6.0,
                      MemoryStage.high => 2.0,
                    };
                    final compact = _stage.gridSize >= 5;
                    final ultraCompact = _stage.gridSize >= 10;

                    return GridView.builder(
                      itemCount: _cards.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: 0.82,
                      ),
                      itemBuilder: (context, index) {
                        final entry = _cards[index];
                        final visible =
                            entry.bonus ||
                            _faceUp.contains(entry.instanceId) ||
                            _matched.contains(entry.instanceId);

                        return _MemoryTile(
                          entry: entry,
                          visible: visible,
                          matched: _matched.contains(entry.instanceId),
                          categoryColor: category.color,
                          language: language,
                          compact: compact,
                          ultraCompact: ultraCompact,
                          onTap: () => _tapCard(entry),
                        );
                      },
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

  void _startNewGame() {
    final gameToken = ++_gameToken;
    final entries = <_MemoryCardEntry>[];
    for (final item in memoryItemsFor(_category, pairCount: _stage.pairCount)) {
      entries
        ..add(_MemoryCardEntry(instanceId: '${item.id}_a', item: item))
        ..add(_MemoryCardEntry(instanceId: '${item.id}_b', item: item));
    }
    if (_stage.hasBonusCard) {
      entries.add(
        const _MemoryCardEntry(
          instanceId: 'bonus_star',
          item: MemoryItem(id: 'bonus_star', label: 'Bonus Star', symbol: '⭐'),
          bonus: true,
        ),
      );
    }
    entries.shuffle();

    setState(() {
      _cards = entries;
      _faceUp
        ..clear()
        ..addAll(entries.map((entry) => entry.instanceId));
      _matched.clear();
      _firstCardId = null;
      _busy = true;
      _completed = false;
      _previewing = true;
    });

    _hidePreview(gameToken);
  }

  Future<void> _hidePreview(int gameToken) async {
    await Future<void>.delayed(_stage.previewDuration);

    if (!mounted || gameToken != _gameToken || _completed) {
      return;
    }

    setState(() {
      _faceUp
        ..clear()
        ..addAll(
          _cards.where((entry) => entry.bonus).map((entry) => entry.instanceId),
        );
      _busy = false;
      _previewing = false;
    });
  }

  Future<void> _tapCard(_MemoryCardEntry entry) async {
    if (_busy ||
        entry.bonus ||
        _previewing ||
        _completed ||
        _faceUp.contains(entry.instanceId) ||
        _matched.contains(entry.instanceId)) {
      return;
    }

    setState(() {
      _faceUp.add(entry.instanceId);
    });

    final firstCardId = _firstCardId;
    if (firstCardId == null) {
      _firstCardId = entry.instanceId;
      return;
    }

    final firstEntry = _cards.firstWhere(
      (card) => card.instanceId == firstCardId,
    );
    final isMatch = firstEntry.item.id == entry.item.id;

    if (isMatch) {
      setState(() {
        _matched
          ..add(firstEntry.instanceId)
          ..add(entry.instanceId);
        _firstCardId = null;
      });

      if (_matched.length == _cards.where((entry) => !entry.bonus).length) {
        await _completeGame();
      }
      return;
    }

    setState(() {
      _busy = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    setState(() {
      _faceUp
        ..remove(firstEntry.instanceId)
        ..remove(entry.instanceId);
      _firstCardId = null;
      _busy = false;
    });
  }

  Future<void> _completeGame() async {
    if (_completed) {
      return;
    }

    final progressService = ref.read(progressServiceProvider);
    final audioService = ref.read(audioServiceProvider);
    final navigator = Navigator.of(context);

    setState(() {
      _busy = true;
      _completed = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));
    final badge = await progressService.completeChallenge(
      ChallengeMode.memory,
      stars: _stage.starReward,
    );
    await audioService.playCelebration(enabled: progressService.soundEnabled);

    if (!mounted) {
      return;
    }

    navigator.pushNamed(
      RewardScreen.routeName,
      arguments: RewardArgs(
        modeLabel: AppText.ui('memoryGame', progressService.language),
        nextRoute: MemoryGameScreen.routeName,
        nextArguments: MemoryGameArgs(category: _category, stage: _stage),
        badge: badge,
      ),
    );
  }
}

class _MemoryHeader extends ConsumerWidget {
  const _MemoryHeader({
    required this.category,
    required this.stage,
    required this.matchedPairs,
    required this.totalPairs,
    required this.previewing,
    required this.language,
  });

  final MemoryCategory category;
  final MemoryStage stage;
  final int matchedPairs;
  final int totalPairs;
  final bool previewing;
  final AppLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMalay = language == AppLanguage.malay;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, color: category.color, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    previewing
                        ? AppText.ui('lookCarefully', language)
                        : AppText.ui('findPairs', language),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${stage.boardLabel(isMalay: isMalay)}  •  $matchedPairs / $totalPairs ${AppText.ui('pairs', language)}',
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

class _MemoryTile extends ConsumerWidget {
  const _MemoryTile({
    required this.entry,
    required this.visible,
    required this.matched,
    required this.categoryColor,
    required this.language,
    required this.compact,
    required this.ultraCompact,
    required this.onTap,
  });

  final _MemoryCardEntry entry;
  final bool visible;
  final bool matched;
  final Color categoryColor;
  final AppLanguage language;
  final bool compact;
  final bool ultraCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = matched ? const Color(0xFF2E7D32) : categoryColor;

    return Semantics(
      button: true,
      label: visible
          ? AppText.memoryLabel(entry.item, language)
          : AppText.ui('hiddenCard', language),
      child: Material(
        color: visible ? Colors.white : categoryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor, width: ultraCompact ? 1.2 : 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: visible
                ? _VisibleCard(
                    key: ValueKey(entry.instanceId),
                    item: entry.item,
                    matched: matched,
                    color: categoryColor,
                    language: language,
                    compact: compact,
                    ultraCompact: ultraCompact,
                  )
                : _HiddenCard(
                    key: const ValueKey('hidden'),
                    ultraCompact: ultraCompact,
                  ),
          ),
        ),
      ),
    );
  }
}

class _HiddenCard extends ConsumerWidget {
  const _HiddenCard({super.key, required this.ultraCompact});

  final bool ultraCompact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Icon(
        Icons.question_mark_rounded,
        color: Colors.white,
        size: ultraCompact ? 16 : 42,
      ),
    );
  }
}

class _VisibleCard extends ConsumerWidget {
  const _VisibleCard({
    super.key,
    required this.item,
    required this.matched,
    required this.color,
    required this.language,
    required this.compact,
    required this.ultraCompact,
  });

  final MemoryItem item;
  final bool matched;
  final Color color;
  final AppLanguage language;
  final bool compact;
  final bool ultraCompact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(ultraCompact ? 2 : (compact ? 5 : 8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: _MemoryItemArt(
                item: item,
                color: color,
                compact: compact,
                ultraCompact: ultraCompact,
              ),
            ),
          ),
          if (!ultraCompact) ...[
            SizedBox(height: compact ? 2 : 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AppText.memoryLabel(item, language),
                maxLines: 1,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: compact ? 11 : 17,
                  color: matched
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF24304F),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemoryItemArt extends ConsumerWidget {
  const _MemoryItemArt({
    required this.item,
    required this.color,
    required this.compact,
    required this.ultraCompact,
  });

  final MemoryItem item;
  final Color color;
  final bool compact;
  final bool ultraCompact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayColor = item.displayColor;
    final shapeKind = item.shapeKind;
    final symbol = item.symbol;
    final icon = item.icon;

    if (symbol != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          symbol,
          style: TextStyle(fontSize: ultraCompact ? 22 : (compact ? 34 : 54)),
        ),
      );
    }

    if (displayColor != null) {
      return Container(
        width: ultraCompact ? 20 : (compact ? 32 : 52),
        height: ultraCompact ? 20 : (compact ? 32 : 52),
        decoration: BoxDecoration(
          color: displayColor,
          borderRadius: BorderRadius.circular(ultraCompact ? 4 : 8),
          border: Border.all(
            color: const Color(0xFF24304F),
            width: ultraCompact ? 1 : 3,
          ),
        ),
      );
    }

    if (shapeKind != null) {
      return ShapeDisplay(
        shape: shapeKind,
        size: ultraCompact ? 20 : (compact ? 34 : 56),
        color: color,
      );
    }

    return Icon(
      icon ?? Icons.star_rounded,
      size: ultraCompact ? 20 : (compact ? 32 : 50),
      color: color,
    );
  }
}

class _MemoryCardEntry {
  const _MemoryCardEntry({
    required this.instanceId,
    required this.item,
    this.bonus = false,
  });

  final String instanceId;
  final MemoryItem item;
  final bool bonus;
}
