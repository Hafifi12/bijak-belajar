import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_language.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  static const routeName = '/puzzle';

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
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
  _Puzzle(emoji: '🐘', answer: 'Elephant',  answerBM: 'Gajah',       bgColor: Color(0xFFB0BEC5)),
  _Puzzle(emoji: '🦁', answer: 'Lion',      answerBM: 'Singa',       bgColor: Color(0xFFFFCC80)),
  _Puzzle(emoji: '🐬', answer: 'Dolphin',   answerBM: 'Lumba-lumba', bgColor: Color(0xFF80DEEA)),
  _Puzzle(emoji: '🦋', answer: 'Butterfly', answerBM: 'Rama-rama',   bgColor: Color(0xFFF48FB1)),
  _Puzzle(emoji: '🐸', answer: 'Frog',      answerBM: 'Katak',       bgColor: Color(0xFFA5D6A7)),
  _Puzzle(emoji: '🐧', answer: 'Penguin',   answerBM: 'Penguin',     bgColor: Color(0xFF90CAF9)),
  _Puzzle(emoji: '🦊', answer: 'Fox',       answerBM: 'Rubah',       bgColor: Color(0xFFFFAB91)),
  _Puzzle(emoji: '🐙', answer: 'Octopus',   answerBM: 'Sotong',      bgColor: Color(0xFFCE93D8)),
  _Puzzle(emoji: '🦒', answer: 'Giraffe',   answerBM: 'Zirafah',     bgColor: Color(0xFFFFE082)),
  _Puzzle(emoji: '🐨', answer: 'Koala',     answerBM: 'Koala',       bgColor: Color(0xFFB0BEC5)),
  _Puzzle(emoji: '🐢', answer: 'Turtle',    answerBM: 'Kura-kura',   bgColor: Color(0xFF80CBC4)),
  _Puzzle(emoji: '🦜', answer: 'Parrot',    answerBM: 'Kakak Tua',   bgColor: Color(0xFFA5D6A7)),
  _Puzzle(emoji: '🦓', answer: 'Zebra',     answerBM: 'Zebra',       bgColor: Color(0xFFECEFF1)),
  _Puzzle(emoji: '🐮', answer: 'Cow',       answerBM: 'Lembu',       bgColor: Color(0xFFF8BBD0)),
  _Puzzle(emoji: '🐔', answer: 'Chicken',   answerBM: 'Ayam',        bgColor: Color(0xFFFFF9C4)),
  _Puzzle(emoji: '🐟', answer: 'Fish',      answerBM: 'Ikan',        bgColor: Color(0xFF80D8FF)),
  _Puzzle(emoji: '🐝', answer: 'Bee',       answerBM: 'Lebah',       bgColor: Color(0xFFFFEE58)),
  _Puzzle(emoji: '🐱', answer: 'Cat',       answerBM: 'Kucing',      bgColor: Color(0xFFFFCDD2)),
  _Puzzle(emoji: '🐶', answer: 'Dog',       answerBM: 'Anjing',      bgColor: Color(0xFFD7CCC8)),
  _Puzzle(emoji: '🐺', answer: 'Wolf',      answerBM: 'Serigala',    bgColor: Color(0xFFCFD8DC)),
];

class _PuzzleScreenState extends State<PuzzleScreen> {
  int _puzzleIndex = 0;
  int _gridSize = 2;
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
    final adjacent = (row == eRow && (col - eCol).abs() == 1) ||
        (col == eCol && (row - eRow).abs() == 1);
    if (!adjacent) return;
    setState(() {
      _tiles[empty] = _tiles[index];
      _tiles[index] = null;
      _emptyIndex = index;
      _moves++;
      if (_isSolved(_tiles)) {
        _solved = true;
        context.read<AudioService>().playCelebration(
            enabled: context.read<ProgressService>().soundEnabled);
      }
    });
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
    final language = context.watch<ProgressService>().language;
    final isMalay = language == AppLanguage.malay;
    final puzzle = _puzzles[_puzzleIndex];
    const color = Color(0xFF6C5CE7);

    return Scaffold(
      backgroundColor: color.withValues(alpha: 0.07),
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(
          isMalay ? 'Teka-Teki Gambar' : 'Picture Puzzle',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: isMalay ? 'Puzzle baru' : 'New puzzle',
            onPressed: _nextPuzzle,
            icon: const Icon(Icons.shuffle_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Level + move counter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text(isMalay ? 'Tahap:' : 'Level:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 10),
                  ...[
                    (2, isMalay ? 'Mudah' : 'Easy'),
                    (3, isMalay ? 'Susah' : 'Hard'),
                  ].map((t) {
                    final (s, label) = t;
                    final sel = s == _gridSize;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: sel,
                        selectedColor: color,
                        labelStyle: TextStyle(
                          color: sel ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => _changeDifficulty(s),
                      ),
                    );
                  }),
                  const Spacer(),
                  Text(
                    '${isMalay ? 'Langkah' : 'Moves'}: $_moves',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Hint row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: puzzle.bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.5)),
                    ),
                    child: Center(child: Text(puzzle.emoji, style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isMalay ? 'Susun kepingan gambar ini!' : 'Arrange the picture pieces!',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Board
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Board ─────────────────────────────────────────────────────────────────────
class _PuzzleBoard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: puzzle.bgColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 3),
      ),
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(builder: (ctx, constraints) {
        final gap = 4.0;
        final tileSize = (constraints.maxWidth - 6 * 2 - gap * (gridSize - 1)) / gridSize;

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
      }),
    );
  }
}

// ── Tile: shows cropped region of the emoji ───────────────────────────────────
class _EmojiTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
class _SolvedOverlay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: puzzle.bgColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(puzzle.emoji, style: const TextStyle(fontSize: 88)),
          const SizedBox(height: 10),
          Text(
            '🎉 ${isMalay ? "Berjaya!" : "Solved!"}',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            isMalay ? puzzle.answerBM : puzzle.answer,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            '${isMalay ? "Langkah" : "Moves"}: $moves',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(isMalay ? 'Puzzle Seterusnya' : 'Next Puzzle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
