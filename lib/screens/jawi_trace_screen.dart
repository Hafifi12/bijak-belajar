import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_language.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/xp_popup.dart';

/// Jawi letter tracing — Jawi v2's first piece.
///
/// The child traces over a large grey letterform with their finger. Tracing
/// is the canonical early-literacy exercise for Arabic-script letterforms:
/// it builds the motor memory that recognition alone can't.
class JawiTraceScreen extends ConsumerStatefulWidget {
  const JawiTraceScreen({
    super.key,
    required this.letter,
    required this.letterName,
    required this.color,
  });

  final String letter;
  final String letterName;
  final Color color;

  @override
  ConsumerState<JawiTraceScreen> createState() => _JawiTraceScreenState();
}

class _JawiTraceScreenState extends ConsumerState<JawiTraceScreen> {
  final List<Offset?> _points = [];
  bool _rewarded = false;

  /// Enough drawn points to plausibly cover a letterform — gates the star so
  /// a single dot doesn't pay out.
  bool get _traceSubstantial => _points.where((p) => p != null).length >= 60;

  void _clear() => setState(() {
    _points.clear();
    _rewarded = false;
  });

  Future<void> _finish() async {
    if (_rewarded || !_traceSubstantial) return;
    setState(() => _rewarded = true);
    final ps = ref.read(progressServiceProvider);
    final language = ps.language;
    await ps.addStars(1);
    if (!mounted) return;
    XpPopup.show(context, amount: 1);
    await ref
        .read(audioServiceProvider)
        .speakLocale(
          language.copy(ms: 'Cantik! Kamu jejak huruf ${widget.letterName}!', en: 'Beautiful! You traced ${widget.letterName}!', zh: '太棒了！你描出了 ${widget.letterName}！', ta: 'அருமை! நீ ${widget.letterName}-ஐ வரைந்தாய்!'),
          enabled: ps.voiceEnabled,
          locale: language.ttsLocale,
        );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(progressServiceProvider).language;
    final color = widget.color;

    return Scaffold(
      backgroundColor: AppTheme.nightMid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: NightBar(color),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: language.copy(ms: 'Kembali', en: 'Back', zh: '返回', ta: 'பின்செல்'),
        ),
        title: Text(
          language.copy(ms: '✍️ Jejak: ${widget.letterName}', en: '✍️ Trace: ${widget.letterName}', zh: '✍️ 描写：${widget.letterName}', ta: '✍️ வரை: ${widget.letterName}'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _clear,
            icon: const Icon(Icons.replay_rounded),
            tooltip: language.copy(ms: 'Padam & cuba lagi', en: 'Clear & retry', zh: '清除并重试', ta: 'அழித்துவிட்டு மீண்டும்'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                language.copy(ms: 'Jejak huruf kelabu dengan jari kamu!', en: 'Trace the grey letter with your finger!', zh: '用手指描出灰色的字母！', ta: 'சாம்பல் நிற எழுத்தை உன் விரலால் வரை!'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.onNight,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: GestureDetector(
                    onPanUpdate: (d) =>
                        setState(() => _points.add(d.localPosition)),
                    onPanEnd: (_) => setState(() => _points.add(null)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Grey guide letterform
                        Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                widget.letter,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: 280,
                                  height: 1.1,
                                  fontFamily: 'serif',
                                  color: Colors.grey.withValues(alpha: 0.30),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // The child's strokes
                        CustomPaint(
                          painter: _TracePainter(_points, color),
                          child: const SizedBox.expand(),
                        ),
                        if (_points.isEmpty)
                          Align(
                            alignment: const Alignment(0, 0.8),
                            child: Text(
                              language.copy(ms: '👆 Mula di sini!', en: '👆 Start here!', zh: '👆 从这里开始！', ta: '👆 இங்கே தொடங்கு!'),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFBBBBBB),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _traceSubstantial && !_rewarded ? _finish : null,
                icon: Text(
                  _rewarded ? '🎉' : '⭐',
                  style: const TextStyle(fontSize: 22),
                ),
                label: Text(
                  _rewarded
                      ? (language.copy(ms: 'Hebat!', en: 'Amazing!', zh: '太棒了！', ta: 'அற்புதம்!'))
                      : (language.copy(ms: 'Siap!', en: 'Done!', zh: '完成！', ta: 'முடிந்தது!')),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _rewarded
                      ? AppTheme.leafGreen
                      : AppTheme.sunnyYellow,
                  foregroundColor: AppTheme.ink,
                  minimumSize: const Size.fromHeight(AppTheme.kidTarget),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  side: const BorderSide(color: Colors.white, width: 2.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter(this.points, this.color);
  final List<Offset?> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (a != null && b != null) {
        canvas.drawLine(a, b, paint);
      } else if (a != null) {
        canvas.drawPoints(PointMode.points, [a], paint);
      }
    }
  }

  @override
  bool shouldRepaint(_TracePainter oldDelegate) => true;
}
