import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// ── Mascot animation states ───────────────────────────────────────────────

enum MascotState {
  idle,
  celebrate,
  encourage,
}

/// Lottie mascot widget that reacts to game events.
///
/// Usage:
/// ```dart
/// final _mascotKey = GlobalKey<MascotWidgetState>();
///
/// MascotWidget(key: _mascotKey)
///
/// // Trigger from anywhere:
/// _mascotKey.currentState?.celebrate();
/// _mascotKey.currentState?.encourage();
/// ```
class MascotWidget extends StatefulWidget {
  const MascotWidget({
    super.key,
    this.size = 120.0,
    this.initialState = MascotState.idle,
  });

  final double size;
  final MascotState initialState;

  @override
  State<MascotWidget> createState() => MascotWidgetState();
}

class MascotWidgetState extends State<MascotWidget> {
  MascotState _state = MascotState.idle;

  /// Switch the mascot into celebrate mode for [duration], then return to idle.
  void celebrate({Duration duration = const Duration(seconds: 2)}) {
    if (!mounted) return;
    setState(() => _state = MascotState.celebrate);
    Future.delayed(duration, () {
      if (mounted) setState(() => _state = MascotState.idle);
    });
  }

  /// Switch the mascot into encourage mode for [duration], then return to idle.
  void encourage({Duration duration = const Duration(seconds: 2)}) {
    if (!mounted) return;
    setState(() => _state = MascotState.encourage);
    Future.delayed(duration, () {
      if (mounted) setState(() => _state = MascotState.idle);
    });
  }

  void _reset() {
    if (mounted) setState(() => _state = MascotState.idle);
  }

  String get _assetPath {
    switch (_state) {
      case MascotState.idle:
        return 'assets/animations/mascot_idle.json';
      case MascotState.celebrate:
        return 'assets/animations/mascot_celebrate.json';
      case MascotState.encourage:
        return 'assets/animations/mascot_encourage.json';
    }
  }

  bool get _shouldLoop => _state == MascotState.idle;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _LottiePlayer(
          key: ValueKey(_state),
          assetPath: _assetPath,
          size: widget.size,
          loop: _shouldLoop,
          onComplete: _state != MascotState.idle ? _reset : null,
        ),
      ),
    );
  }
}

// ── Internal stateful Lottie player ──────────────────────────────────────

class _LottiePlayer extends StatefulWidget {
  const _LottiePlayer({
    super.key,
    required this.assetPath,
    required this.size,
    required this.loop,
    this.onComplete,
  });

  final String assetPath;
  final double size;
  final bool loop;
  final VoidCallback? onComplete;

  @override
  State<_LottiePlayer> createState() => _LottiePlayerState();
}

class _LottiePlayerState extends State<_LottiePlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    if (!widget.loop) {
      _ctrl.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.assetPath,
      controller: _ctrl,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      repeat: widget.loop,
      onLoaded: (composition) {
        _ctrl.duration = composition.duration;
        if (widget.loop) {
          _ctrl.repeat();
        } else {
          _ctrl.forward();
        }
      },
      errorBuilder: (_, __, ___) => _FallbackMascot(size: widget.size),
    );
  }
}

// ── Fallback mascot (shown if Lottie fails to load) ──────────────────────

class _FallbackMascot extends StatelessWidget {
  const _FallbackMascot({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const Center(
        child: Text('📚', style: TextStyle(fontSize: 60)),
      ),
    );
  }
}
