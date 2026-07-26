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
    final isMalay = ps.language == AppLanguage.malay;
    await ps.addStars(1);
    if (!mounted) return;
    XpPopup.show(context, amount: 1);
    await ref
        .read(audioServiceProvider)
        .speakLocale(
          isMalay
              ? 'Cantik! Kamu jejak huruf ${widget.letterName}!'
              : 'Beautiful! You traced ${widget.letterName}!',
          enabled: ps.voiceEnabled,
          locale: isMalay ? 'ms-MY' : 'en-US',
        );
  }

  @override
  Widget build(BuildContext context) {
    final isMalay =
        ref.watch(progressServiceProvider).language == AppLanguage.malay;
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
          tooltip: isMalay ? 'Kembali' : 'Back',
        ),
        title: Text(
          isMalay
              ? '✍️ Jejak: ${widget.letterName}'
              : '✍️ Trace: ${widget.letterName}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _clear,
            icon: const Icon(Icons.replay_rounded),
            tooltip: isMalay ? 'Padam & cuba lagi' : 'Clear & retry',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                isMalay
                    ? 'Jejak huruf kelabu dengan jari kamu!'
                    : 'Trace the grey letter with your finger!',
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
                              isMalay ? '👆 Mula di sini!' : '👆 Start here!',
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
                      ? (isMalay ? 'Hebat!' : 'Amazing!')
                      : (isMalay ? 'Siap!' : 'Done!'),
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
