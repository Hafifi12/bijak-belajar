import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_language.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import 'parent_settings_screen.dart';

class ParentGateScreen extends ConsumerStatefulWidget {
  const ParentGateScreen({super.key, this.forSharing = false});
  static const routeName = '/parent-gate';

  /// When true the gate guards sharing a picture outside the app: it pops
  /// `true` on success instead of opening Parent Settings.
  final bool forSharing;

  @override
  ConsumerState<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends ConsumerState<ParentGateScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  String? _error;
  late int _a, _b, _answer;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _generateChallenge();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  void _generateChallenge() {
    final rng = Random();
    // Times tables are taught around Year 2 (age 8), beyond this app's
    // 3–7 audience, so a 3–9 × 3–9 product keeps the gate for grown-ups.
    _a = rng.nextInt(7) + 3;
    _b = rng.nextInt(7) + 3;
    _answer = _a * _b;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _check() {
    final language = ref.read(progressServiceProvider).language;
    if (_ctrl.text.trim() == '$_answer') {
      HapticFeedback.lightImpact();
      if (widget.forSharing) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(
          context,
        ).pushReplacementNamed(ParentSettingsScreen.routeName);
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(
        () => _error = language.copy(ms: 'Kurang tepat — cuba lagi! 🤔', en: 'Not quite — try again! 🤔', zh: '不太对——再试一次！🤔', ta: 'சரியில்லை — மீண்டும் முயற்சி செய்! 🤔'),
      );
      _ctrl.clear();
      _shakeCtrl.forward(from: 0);
      _generateChallenge();
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(progressServiceProvider).language;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: language.copy(ms: 'Kembali', en: 'Back', zh: '返回', ta: 'பின்செல்'),
        ),
        title: Text(
          language.copy(ms: 'Untuk Orang Dewasa', en: 'Grown-Ups Only', zh: '仅限成人', ta: 'பெரியவர்களுக்கு மட்டும்'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: BijakScene(
        topColor: AppTheme.nightTop,
        bottomColor: AppTheme.nightBottom,
        showHills: false,
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // ── Hero ────────────────────────────────────────────
                    const Spacer(),
                    const _ShieldBadge(),
                    const SizedBox(height: 12),
                    Text(
                      language.copy(ms: 'Akses Ibu Bapa & Guru', en: 'Parent & Teacher Access', zh: '家长与老师入口', ta: 'பெற்றோர் & ஆசிரியர் அணுகல்'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.forSharing
                          ? (language.copy(ms: 'Jawab soalan matematik untuk berkongsi gambar', en: 'Answer the maths question to share the picture', zh: '回答数学题即可分享图片', ta: 'படத்தைப் பகிர கணிதக் கேள்விக்கு விடையளி'))
                          : (language.copy(ms: 'Jawab soalan matematik untuk buka tetapan', en: 'Answer the maths question to unlock settings', zh: '回答数学题即可打开设置', ta: 'அமைப்புகளைத் திறக்க கணிதக் கேள்விக்கு விடையளி')),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),

                    // ── Card ────────────────────────────────────────────
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(_shakeAnim.value, 0),
                        child: child,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Math challenge display
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 22),
                              decoration: BoxDecoration(
                                color: AppTheme.sunnyYellow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '$_a × $_b = ?',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.ink,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    language.copy(ms: 'Berapakah jawapannya?', en: 'What is the answer?', zh: '答案是什么？', ta: 'விடை என்ன?'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.ink.withValues(
                                        alpha: 0.55,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Input
                            TextField(
                              controller: _ctrl,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.ink,
                              ),
                              decoration: InputDecoration(
                                hintText: '—',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 32,
                                ),
                                errorText: _error,
                                errorStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: AppTheme.skyBlue,
                                    width: 2.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: AppTheme.appleRed,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: AppTheme.appleRed,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                              onSubmitted: (_) => _check(),
                            ),
                            const SizedBox(height: 20),

                            // CTA button
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _check,
                                icon: const Icon(
                                  Icons.lock_open_rounded,
                                  size: 22,
                                ),
                                label: Text(
                                  widget.forSharing
                                      ? (language.copy(ms: 'Teruskan', en: 'Continue', zh: '继续', ta: 'தொடர்'))
                                      : (language.copy(ms: 'Buka Tetapan', en: 'Unlock Settings', zh: '打开设置', ta: 'அமைப்புகளைத் திற')),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.deepBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),

                    // ── Footer note ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                      child: Text(
                        widget.forSharing
                            ? (language.copy(ms: 'Semakan matematik mudah ini memastikan orang dewasa yang memilih untuk berkongsi 🧒', en: 'This simple maths check makes sure a grown-up chooses to share 🧒', zh: '这个简单的数学题确保是成人选择分享 🧒', ta: 'இந்த எளிய கணிதச் சோதனை பெரியவர் தேர்ந்தெடுத்துப் பகிர்வதை உறுதி செய்கிறது 🧒'))
                            : (language.copy(ms: 'Semakan matematik mudah ini memastikan tetapan selamat daripada si kecil 🧒', en: 'This simple maths check keeps settings safe from little fingers 🧒', zh: '这个简单的数学题可防止小手误改设置 🧒', ta: 'இந்த எளிய கணிதச் சோதனை சிறு விரல்களிடமிருந்து அமைப்புகளைப் பாதுகாக்கிறது 🧒')),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldBadge extends StatefulWidget {
  const _ShieldBadge();

  @override
  State<_ShieldBadge> createState() => _ShieldBadgeState();
}

class _ShieldBadgeState extends State<_ShieldBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.92,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 3,
          ),
        ),
        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 56),
      ),
    );
  }
}
