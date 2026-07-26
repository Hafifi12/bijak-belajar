import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../models/app_language.dart';
import '../models/challenge.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/star_counter.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key});

  static const routeName = '/puzzle';

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _Puzzle {
  const _Puzzle({
    required this.emoji,
    required this.answer,
    required this.answerBM,
    required this.bgColor,
  });
  final String emoji;
  final String answer;
  final String answerBM;
  final Color bgColor;
}

const _puzzles = <_Puzzle>[
  _Puzzle(
    emoji: '🐘',
    answer: 'Elephant',
    answerBM: 'Gajah',
    bgColor: Color(0xFFB0BEC5),
  ),
  _Puzzle(
    emoji: '🦁',
    answer: 'Lion',
    answerBM: 'Singa',
    bgColor: Color(0xFFFFCC80),
  ),
  _Puzzle(
    emoji: '🐬',
    answer: 'Dolphin',
    answerBM: 'Lumba-lumba',
    bgColor: Color(0xFF80DEEA),
  ),
  _Puzzle(
    emoji: '🦋',
    answer: 'Butterfly',
    answerBM: 'Rama-rama',
    bgColor: Color(0xFFF48FB1),
  ),
  _Puzzle(
    emoji: '🐸',
    answer: 'Frog',
    answerBM: 'Katak',
    bgColor: Color(0xFFA5D6A7),
  ),
  _Puzzle(
    emoji: '🐧',
    answer: 'Penguin',
    answerBM: 'Penguin',
    bgColor: Color(0xFF90CAF9),
  ),
  _Puzzle(
    emoji: '🦊',
    answer: 'Fox',
    answerBM: 'Rubah',
    bgColor: Color(0xFFFFAB91),
  ),
  _Puzzle(
    emoji: '🐙',
    answer: 'Octopus',
    answerBM: 'Sotong',
    bgColor: Color(0xFFCE93D8),
  ),
  _Puzzle(
    emoji: '🦒',
    answer: 'Giraffe',
    answerBM: 'Zirafah',
    bgColor: Color(0xFFFFE082),
  ),
  _Puzzle(
    emoji: '🐨',
    answer: 'Koala',
    answerBM: 'Koala',
    bgColor: Color(0xFFB0BEC5),
  ),
  _Puzzle(
    emoji: '🐢',
    answer: 'Turtle',
    answerBM: 'Kura-kura',
    bgColor: Color(0xFF80CBC4),
  ),
  _Puzzle(
    emoji: '🦜',
    answer: 'Parrot',
    answerBM: 'Kakak Tua',
    bgColor: Color(0xFFA5D6A7),
  ),
  _Puzzle(
    emoji: '🦓',
    answer: 'Zebra',
    answerBM: 'Zebra',
    bgColor: Color(0xFFECEFF1),
  ),
  _Puzzle(
    emoji: '🐮',
    answer: 'Cow',
    answerBM: 'Lembu',
    bgColor: Color(0xFFF8BBD0),
  ),
  _Puzzle(
    emoji: '🐔',
    answer: 'Chicken',
    answerBM: 'Ayam',
    bgColor: Color(0xFFFFF9C4),
  ),
  _Puzzle(
    emoji: '🐟',
    answer: 'Fish',
    answerBM: 'Ikan',
    bgColor: Color(0xFF80D8FF),
  ),
  _Puzzle(
    emoji: '🐝',
    answer: 'Bee',
    answerBM: 'Lebah',
    bgColor: Color(0xFFFFEE58),
  ),
  _Puzzle(
    emoji: '🐱',
    answer: 'Cat',
    answerBM: 'Kucing',
    bgColor: Color(0xFFFFCDD2),
  ),
  _Puzzle(
    emoji: '🐶',
    answer: 'Dog',
    answerBM: 'Anjing',
    bgColor: Color(0xFFD7CCC8),
  ),
  _Puzzle(
    emoji: '🐺',
    answer: 'Wolf',
    answerBM: 'Serigala',
    bgColor: Color(0xFFCFD8DC),
  ),
];

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  // Random starting picture so each session doesn't always open on puzzle 1.
  int _puzzleIndex = Random().nextInt(_puzzles.length);
  int _gridSize = 3;
  late List<int?> _tiles;
  int? _emptyIndex;
  int _moves = 0;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _initPuzzle();
  }

  void _initPuzzle() {
    final total = _gridSize * _gridSize;
    final solved = List<int?>.generate(total - 1, (i) => i)..add(null);
    final rng = Random();
    List<int?> shuffled;
    do {
      shuffled = [...solved]..shuffle(rng);
    } while (!_isSolvable(shuffled) || _isSolved(shuffled));
    _tiles = shuffled;
    _emptyIndex = _tiles.indexOf(null);
    _moves = 0;
    _solved = false;
  }

  bool _isSolvable(List<int?> tiles) {
    final flat = tiles.whereType<int>().toList();
    int inversions = 0;
    for (int i = 0; i < flat.length; i++) {
      for (int j = i + 1; j < flat.length; j++) {
        if (flat[i] > flat[j]) inversions++;
      }
    }
    if (_gridSize.isOdd) return inversions.isEven;
    final emptyRow = tiles.indexOf(null) ~/ _gridSize;
    final fromBottom = _gridSize - emptyRow;
    if (fromBottom.isEven) return inversions.isOdd;
    return inversions.isEven;
  }

  bool _isSolved(List<int?> tiles) {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i) return false;
    }
    return tiles.last == null;
  }

  void _tap(int index) {
    if (_solved) return;
    final empty = _emptyIndex!;
    final row = index ~/ _gridSize;
    final col = index % _gridSize;
    final eRow = empty ~/ _gridSize;
    final eCol = empty % _gridSize;
    final adjacent =
        (row == eRow && (col - eCol).abs() == 1) ||
        (col == eCol && (row - eRow).abs() == 1);
    if (!adjacent) return;
    var solvedNow = false;
    setState(() {
      _tiles[empty] = _tiles[index];
      _tiles[index] = null;
      _emptyIndex = index;
      _moves++;
      solvedNow = _isSolved(_tiles);
      _solved = solvedNow;
    });
    if (solvedNow) {
      _completePuzzle();
    }
  }

  Future<void> _completePuzzle() async {
    final progressService = ref.read(progressServiceProvider);
    // 3×3 pays 1 ⭐, 4×4 pays 2 ⭐ — harder board, better payout.
    await progressService.completeChallenge(
      ChallengeMode.puzzle,
      stars: _gridSize >= 4 ? 2 : 1,
    );
    if (!mounted) {
      return;
    }
    await ref
        .read(audioServiceProvider)
        .playCelebration(enabled: progressService.soundEnabled);
  }

  void _nextPuzzle() => setState(() {
    _puzzleIndex = (_puzzleIndex + 1) % _puzzles.length;
    _initPuzzle();
  });

  void _changeDifficulty(int size) => setState(() {
    _gridSize = size;
    _initPuzzle();
  });

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(progressServiceProvider).language;
    final isMalay = language == AppLanguage.malay;
    final puzzle = _puzzles[_puzzleIndex];
    const color = AppTheme.skyBlue;

    return Scaffold(
      backgroundColor: AppTheme.nightMid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const NightBar(Color(0xFF00897B)),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: isMalay ? 'Kembali' : 'Back',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMalay ? 'Teka-Teki Gambar 🧩' : 'Picture Puzzle 🧩',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            Text(
              '${isMalay ? 'Puzzle' : 'Puzzle'} ${_puzzleIndex + 1}/${_puzzles.length}  •  ${isMalay ? 'Langkah' : 'Moves'}: $_moves',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isMalay ? 'Puzzle baru' : 'New puzzle',
            onPressed: _nextPuzzle,
            icon: const Icon(Icons.shuffle_rounded),
          ),
          const Padding(
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
                          value: (_puzzleIndex + 1) / _puzzles.length,
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
                        '${_puzzleIndex + 1}/${_puzzles.length}',
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

              // Difficulty chips + hint row inside a white pill bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.deepBlue.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Emoji preview
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: puzzle.bgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            puzzle.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isMalay
                              ? 'Susun kepingan gambar ini!'
                              : 'Arrange the picture pieces!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Difficulty chips
                      for (final t in [
                        (3, isMalay ? 'Mudah' : 'Easy'),
                        (4, isMalay ? 'Susah' : 'Hard'),
                      ]) ...[
                        GestureDetector(
                          onTap: () => _changeDifficulty(t.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: t.$1 == _gridSize
                                  ? AppTheme.skyBlue
                                  : AppTheme.lightBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              t.$2,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: t.$1 == _gridSize
                                    ? Colors.white
                                    : AppTheme.deepBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
              ),

              // Board inside white container
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _solved
                            ? _SolvedOverlay(
                                puzzle: puzzle,
                                moves: _moves,
                                isMalay: isMalay,
                                color: color,
                                onNext: _nextPuzzle,
                                onRetry: () => setState(_initPuzzle),
                              )
                            : _PuzzleBoard(
                                puzzle: puzzle,
                                gridSize: _gridSize,
                                tiles: _tiles,
                                onTap: _tap,
                                color: color,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Board ─────────────────────────────────────────────────────────────────────
class _PuzzleBoard extends ConsumerWidget {
  const _PuzzleBoard({
    required this.puzzle,
    required this.gridSize,
    required this.tiles,
    required this.onTap,
    required this.color,
  });

  final _Puzzle puzzle;
  final int gridSize;
  final List<int?> tiles;
  final void Function(int) onTap;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: puzzle.bgColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.skyBlue.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final gap = 4.0;
          final tileSize =
              (constraints.maxWidth - 6 * 2 - gap * (gridSize - 1)) / gridSize;

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: gap,
              mainAxisSpacing: gap,
            ),
            itemCount: gridSize * gridSize,
            itemBuilder: (ctx2, index) {
              final tileNum = tiles[index];
              if (tileNum == null) {
                return Container(
                  decoration: BoxDecoration(
                    color: puzzle.bgColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }
              return GestureDetector(
                onTap: () => onTap(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: puzzle.bgColor,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _EmojiTile(
                      emoji: puzzle.emoji,
                      tileIndex: tileNum,
                      gridSize: gridSize,
                      tileSize: tileSize,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Tile: shows cropped region of the emoji ───────────────────────────────────
class _EmojiTile extends ConsumerWidget {
  const _EmojiTile({
    required this.emoji,
    required this.tileIndex,
    required this.gridSize,
    required this.tileSize,
  });

  final String emoji;
  final int tileIndex;
  final int gridSize;
  final double tileSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullSize = tileSize * gridSize;
    final col = tileIndex % gridSize;
    final row = tileIndex ~/ gridSize;

    return OverflowBox(
      maxWidth: fullSize,
      maxHeight: fullSize,
      alignment: Alignment.topLeft,
      child: Transform.translate(
        offset: Offset(-col * tileSize, -row * tileSize),
        child: SizedBox(
          width: fullSize,
          height: fullSize,
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: fullSize * 0.85, height: 1.0),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Solved overlay ────────────────────────────────────────────────────────────
class _SolvedOverlay extends ConsumerWidget {
  const _SolvedOverlay({
    required this.puzzle,
    required this.moves,
    required this.isMalay,
    required this.color,
    required this.onNext,
    required this.onRetry,
  });

  final _Puzzle puzzle;
  final int moves;
  final bool isMalay;
  final Color color;
  final VoidCallback onNext;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.skyBlue.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepBlue.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(puzzle.emoji, style: const TextStyle(fontSize: 88)),
          const SizedBox(height: 10),
          Text(
            '🎉 ${isMalay ? "Berjaya!" : "Solved!"}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.deepBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isMalay ? puzzle.answerBM : puzzle.answer,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.skyBlue,
            ),
          ),
          Text(
            '${isMalay ? "Langkah" : "Moves"}: $moves',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(isMalay ? 'Puzzle Seterusnya' : 'Next Puzzle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.skyBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.replay_rounded),
                    label: Text(isMalay ? 'Cuba Lagi' : 'Try Again'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.skyBlue,
                      side: const BorderSide(color: AppTheme.skyBlue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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
