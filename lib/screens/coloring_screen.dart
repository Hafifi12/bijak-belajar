import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../models/app_language.dart';
// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────
class _DrawPoint {
  const _DrawPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
  });
  final Offset offset;
  final Color color;
  final double strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry — Category picker
// ─────────────────────────────────────────────────────────────────────────────
class ColoringScreen extends ConsumerWidget {
  const ColoringScreen({super.key});
  static const routeName = '/coloring';

  static const _categories = <_ColoringCategory>[
    _ColoringCategory(
      id: 'animals',
      emoji: '🐘',
      labelMs: 'Haiwan',
      labelEn: 'Animals',
      color: Color(0xFF00C9A7),
      subjects: [
        _Subject('🐘', 'Gajah', 'Elephant'),
        _Subject('🦁', 'Singa', 'Lion'),
        _Subject('🐬', 'Lumba-lumba', 'Dolphin'),
        _Subject('🐔', 'Ayam', 'Chicken'),
        _Subject('🦋', 'Kupu-kupu', 'Butterfly'),
        _Subject('🐸', 'Katak', 'Frog'),
        _Subject('🐙', 'Sotong', 'Octopus'),
        _Subject('🦄', 'Kuda Bertanduk', 'Unicorn'),
        _Subject('🐢', 'Kura-kura', 'Turtle'),
        _Subject('🦊', 'Musang', 'Fox'),
      ],
    ),
    _ColoringCategory(
      id: 'fruits',
      emoji: '🍎',
      labelMs: 'Buah-buahan',
      labelEn: 'Fruits',
      color: Color(0xFFFF4D4F),
      subjects: [
        _Subject('🍎', 'Epal', 'Apple'),
        _Subject('🍌', 'Pisang', 'Banana'),
        _Subject('🍇', 'Anggur', 'Grapes'),
        _Subject('🍓', 'Strawberi', 'Strawberry'),
        _Subject('🍊', 'Oren', 'Orange'),
        _Subject('🥭', 'Mangga', 'Mango'),
        _Subject('🍍', 'Nenas', 'Pineapple'),
        _Subject('🍉', 'Tembikai', 'Watermelon'),
        _Subject('🫐', 'Blueberry', 'Blueberry'),
        _Subject('🥝', 'Kiwi', 'Kiwi'),
      ],
    ),
    _ColoringCategory(
      id: 'shapes',
      emoji: '🔴',
      labelMs: 'Bentuk',
      labelEn: 'Shapes',
      color: Color(0xFF7A5CFF),
      subjects: [
        _Subject('🔴', 'Bulatan', 'Circle'),
        _Subject('🟦', 'Segi Empat', 'Square'),
        _Subject('🔺', 'Segitiga', 'Triangle'),
        _Subject('⬛', 'Empat Segi', 'Rectangle'),
        _Subject('⭐', 'Bintang', 'Star'),
        _Subject('❤️', 'Hati', 'Heart'),
        _Subject('💎', 'Berlian', 'Diamond'),
        _Subject('🔶', 'Rombus', 'Rhombus'),
        _Subject('🟣', 'Oval', 'Oval'),
        _Subject('🔷', 'Heksagon', 'Hexagon'),
      ],
    ),
    _ColoringCategory(
      id: 'transport',
      emoji: '🚌',
      labelMs: 'Pengangkutan',
      labelEn: 'Transport',
      color: Color(0xFF1EA7FF),
      subjects: [
        _Subject('🚌', 'Bas', 'Bus'),
        _Subject('🚂', 'Kereta Api', 'Train'),
        _Subject('✈️', 'Kapal Terbang', 'Aeroplane'),
        _Subject('🚗', 'Kereta', 'Car'),
        _Subject('🚢', 'Kapal', 'Ship'),
        _Subject('🚁', 'Helikopter', 'Helicopter'),
        _Subject('🛵', 'Motosikal', 'Motorcycle'),
        _Subject('🚒', 'Trak Bomba', 'Fire Truck'),
        _Subject('🚀', 'Roket', 'Rocket'),
        _Subject('🛶', 'Bot', 'Boat'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressServiceProvider);
    final isMalay = progress.language == AppLanguage.malay;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9F43),
        foregroundColor: Colors.white,
        // Continues the emoji "flight" started from the module card on the
        // Learning Path screen — same Hero tag, same emoji.
        leading: Center(
          child: Hero(
            tag: 'module-emoji-${ColoringScreen.routeName}',
            child: const Text('🎨', style: TextStyle(fontSize: 26)),
          ),
        ),
        title: Text(
          isMalay ? 'Jom Mewarna! 🎨' : 'Let\'s Colour! 🎨',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _ColoringHeader(isMalay: isMalay)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final cat = _categories[i];
                  return _CategoryCard(
                    category: cat,
                    isMalay: isMalay,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => _SubjectPickerScreen(
                          category: cat,
                          isMalay: isMalay,
                        ),
                      ));
                    },
                  );
                },
                childCount: _categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────
class _ColoringHeader extends ConsumerWidget {
  const _ColoringHeader({required this.isMalay});
  final bool isMalay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9F43), Color(0xFFFFD21E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9F43).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🎨', style: TextStyle(fontSize: 50)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMalay ? 'Aktiviti Mewarna' : 'Colouring Activity',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMalay
                      ? 'Lukis & warnakan gambar kegemaran kamu!'
                      : 'Draw & colour your favourite pictures!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _TeacherTag(
                  label: isMalay ? '✅ Disahkan Guru' : '✅ Teacher Approved',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherTag extends ConsumerWidget {
  const _TeacherTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ── Category card ──────────────────────────────────────────────────────────────
class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({
    required this.category,
    required this.isMalay,
    required this.onTap,
  });
  final _ColoringCategory category;
  final bool isMalay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 4,
      shadowColor: category.color.withValues(alpha: 0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isMalay ? category.labelMs : category.labelEn,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: category.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${category.subjects.length} ${isMalay ? 'gambar' : 'pictures'}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9090A8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subject picker — choose WHAT to colour
// ─────────────────────────────────────────────────────────────────────────────
class _SubjectPickerScreen extends ConsumerWidget {
  const _SubjectPickerScreen({
    required this.category,
    required this.isMalay,
  });
  final _ColoringCategory category;
  final bool isMalay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        backgroundColor: category.color,
        foregroundColor: Colors.white,
        title: Text(
          isMalay ? category.labelMs : category.labelEn,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.05,
        ),
        itemCount: category.subjects.length,
        itemBuilder: (context, i) {
          final sub = category.subjects[i];
          return _SubjectCard(
            subject: sub,
            color: category.color,
            isMalay: isMalay,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ColoringCanvasScreen(
                  subject: sub,
                  color: category.color,
                  isMalay: isMalay,
                ),
              ));
            },
          );
        },
      ),
    );
  }
}

class _SubjectCard extends ConsumerWidget {
  const _SubjectCard({
    required this.subject,
    required this.color,
    required this.isMalay,
    required this.onTap,
  });
  final _Subject subject;
  final Color color;
  final bool isMalay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: color.withValues(alpha: 0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(subject.emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 8),
            Text(
              isMalay ? subject.labelMs : subject.labelEn,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isMalay ? 'Warna sekarang!' : 'Colour now!',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Canvas — the actual finger-painting screen
// ─────────────────────────────────────────────────────────────────────────────
class ColoringCanvasScreen extends ConsumerStatefulWidget {
  const ColoringCanvasScreen({
    super.key,
    required this.subject,
    required this.color,
    required this.isMalay,
  });
  final dynamic subject; // changed to dynamic as _Subject is private
  final Color color;
  final bool isMalay;

  @override
  ConsumerState<ColoringCanvasScreen> createState() => _ColoringCanvasScreenState();
}

class _ColoringCanvasScreenState extends ConsumerState<ColoringCanvasScreen>
    with SingleTickerProviderStateMixin {
  final List<_DrawPoint?> _points = [];
  Color _selectedColor = Colors.red;
  double _strokeWidth = 18.0;
  bool _isEraser = false;
  bool _saved = false;

  late AnimationController _starController;
  late Animation<double> _starAnim;

  static const _palette = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.black,
    Colors.white,
    Color(0xFF00C9A7),
    Color(0xFF1EA7FF),
  ];

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _starAnim = CurvedAnimation(parent: _starController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    setState(() {
      final box = context.findRenderObject() as RenderBox;
      final local = box.globalToLocal(details.globalPosition);
      if (local.dx >= 0 &&
          local.dy >= 0 &&
          local.dx <= constraints.maxWidth &&
          local.dy <= constraints.maxHeight) {
        _points.add(_DrawPoint(
          offset: local,
          color: _isEraser ? Colors.white : _selectedColor,
          strokeWidth: _isEraser ? _strokeWidth * 2 : _strokeWidth,
        ));
      }
    });
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() => _points.add(null)); // separator
  }

  void _clear() {
    setState(() {
      _points.clear();
      _saved = false;
    });
  }

  void _celebrate() async {
    final ps = ref.read(progressServiceProvider);
    await ps.incrementColoringSessions();
    await ps.addStars(1);
    setState(() => _saved = true);
    _starController.forward(from: 0);
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => _CelebrationDialog(
          isMalay: widget.isMalay,
          subjectEmoji: widget.subject.emoji,
          label: widget.isMalay ? widget.subject.labelMs : widget.subject.labelEn,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMalay = widget.isMalay;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        title: Text(
          '${widget.subject.emoji} ${isMalay ? widget.subject.labelMs : widget.subject.labelEn}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: isMalay ? 'Padam Semua' : 'Clear All',
            onPressed: _clear,
          ),
          IconButton(
            icon: const Icon(Icons.star_rounded),
            tooltip: isMalay ? 'Selesai!' : 'Done!',
            onPressed: _celebrate,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Subject label ──
          Container(
            color: widget.color.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Text(widget.subject.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Text(
                  isMalay ? widget.subject.labelMs : widget.subject.labelEn,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: widget.color,
                  ),
                ),
                const Spacer(),
                Text(
                  isMalay ? '🖌 Lukis & Warna!' : '🖌 Draw & Colour!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7A7A9A),
                  ),
                ),
              ],
            ),
          ),

          // ── Canvas ──
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanUpdate: (d) => _onPanUpdate(d, constraints),
                  onPanEnd: _onPanEnd,
                  child: Stack(
                    children: [
                      // White drawing area
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.white,
                        child: CustomPaint(
                          painter: _DrawingPainter(_points),
                        ),
                      ),
                      // Faint guide illustration (subject emoji centred)
                      if (_points.isEmpty)
                        Center(
                          child: Opacity(
                            opacity: 0.08,
                            child: Text(
                              widget.subject.emoji,
                              style: const TextStyle(fontSize: 180),
                            ),
                          ),
                        ),
                      // Instruction overlay
                      if (_points.isEmpty)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 200),
                              Text(
                                isMalay
                                    ? '👆 Lukis di sini!'
                                    : '👆 Draw here!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFCCCCCC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Star burst on save
                      if (_saved)
                        IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _starAnim,
                            builder: (_, __) => _StarBurst(
                              progress: _starAnim.value,
                              color: widget.color,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Stroke size ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  isMalay ? 'Saiz: ' : 'Size: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7A7A9A),
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _strokeWidth,
                    min: 5,
                    max: 40,
                    onChanged: (v) => setState(() => _strokeWidth = v),
                    activeColor: widget.color,
                    inactiveColor: widget.color.withValues(alpha: 0.2),
                  ),
                ),
                _ToolButton(
                  icon: _isEraser ? Icons.brush_rounded : Icons.auto_fix_normal_rounded,
                  label: _isEraser
                      ? (isMalay ? 'Berus' : 'Brush')
                      : (isMalay ? 'Pemadam' : 'Eraser'),
                  color: widget.color,
                  onTap: () => setState(() => _isEraser = !_isEraser),
                ),
              ],
            ),
          ),

          // ── Colour palette ──
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _palette.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final c = _palette[i];
                final isSelected = !_isEraser && _selectedColor == c;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedColor = c;
                    _isEraser = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 50 : 42,
                    height: isSelected ? 50 : 42,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.black12,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: c.withValues(alpha: 0.5),
                                blurRadius: 10,
                              )
                            ]
                          : [],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawing painter ────────────────────────────────────────────────────────────
class _DrawingPainter extends CustomPainter {
  const _DrawingPainter(this.points);
  final List<_DrawPoint?> points;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        final paint = Paint()
          ..color = p1.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = p1.strokeWidth
          ..style = PaintingStyle.stroke;
        canvas.drawLine(p1.offset, p2.offset, paint);
      } else if (p1 != null && p2 == null) {
        final paint = Paint()
          ..color = p1.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = p1.strokeWidth
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p1.offset, p1.strokeWidth / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter old) => old.points != points;
}

// ── Star burst decoration ──────────────────────────────────────────────────────
class _StarBurst extends ConsumerWidget {
  const _StarBurst({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomPaint(
      painter: _StarBurstPainter(progress, color),
      child: const SizedBox.expand(),
    );
  }
}

class _StarBurstPainter extends CustomPainter {
  _StarBurstPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(42);
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 18; i++) {
      final angle = 2 * math.pi * i / 18;
      final dist = 80 + r.nextDouble() * 80;
      final offset = Offset(
        center.dx + math.cos(angle) * dist * t,
        center.dy + math.sin(angle) * dist * t,
      );
      paint.color = [
        Colors.yellow,
        Colors.orange,
        Colors.pink,
        color,
      ][i % 4]
          .withValues(alpha: (1.0 - t * 0.5));
      canvas.drawCircle(offset, (6 + r.nextDouble() * 6) * (1 - t * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(_StarBurstPainter old) => old.t != t;
}

// ── Tool button ────────────────────────────────────────────────────────────────
class _ToolButton extends ConsumerWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Celebration dialog ─────────────────────────────────────────────────────────
class _CelebrationDialog extends ConsumerWidget {
  const _CelebrationDialog({
    required this.isMalay,
    required this.subjectEmoji,
    required this.label,
  });
  final bool isMalay;
  final String subjectEmoji;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 10),
            Text(
              isMalay ? 'Tahniah! Bagus sekali!' : 'Great job! Well done!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF123A7A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isMalay
                  ? 'Kamu dah mewarnakan $subjectEmoji $label dengan cantik!'
                  : 'You coloured $subjectEmoji $label beautifully!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5A5A7A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '+1 ⭐',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFD21E),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(isMalay ? 'Lagi!' : 'Again!'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00C9A7),
                    ),
                    child: Text(isMalay ? 'Selesai' : 'Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColoringCategory {
  const _ColoringCategory({
    required this.id,
    required this.emoji,
    required this.labelMs,
    required this.labelEn,
    required this.color,
    required this.subjects,
  });

  final String id;
  final String emoji;
  final String labelMs;
  final String labelEn;
  final Color color;
  final List<_Subject> subjects;
}

class _Subject {
  const _Subject(this.emoji, this.labelMs, this.labelEn);
  final String emoji;
  final String labelMs;
  final String labelEn;
}
