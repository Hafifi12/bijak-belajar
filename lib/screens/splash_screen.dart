import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_language.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_text.dart';
import 'home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  static const routeName = '/';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _starsCtrl;

  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _mascotScale;
  late Animation<double> _float;
  late Animation<double> _pulse;

  Timer? _autoNavTimer;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );

    _fadeIn = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _slideUp = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _mascotScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
    _float = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward();

    // Disable infinite animations during tests to avoid pumpAndSettle timeouts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (const String.fromEnvironment('FLUTTER_TEST', defaultValue: 'false') ==
          'true') {
        return;
      }

      _floatCtrl.repeat(reverse: true);
      _pulseCtrl.repeat(reverse: true);
      _starsCtrl.repeat();

      // Auto-navigate after 3 seconds with countdown
      _startCountdown();
    });
  }

  void _startCountdown() {
    _autoNavTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        _goToHome();
      }
    });
  }

  @override
  void dispose() {
    _autoNavTimer?.cancel();
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _starsCtrl.dispose();
    super.dispose();
  }

  void _goToHome() {
    _autoNavTimer?.cancel();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final language = ref.watch(progressServiceProvider).language;
    return Scaffold(
      body: Semantics(
        label: 'Bijak Belajar',
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _entryCtrl,
            _floatCtrl,
            _pulseCtrl,
            _starsCtrl,
          ]),
          builder: (context, _) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1B1638),
                    Color(0xFF2A2065),
                    Color(0xFF6C5CE7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  // Floating emoji stars
                  ..._buildStars(size),
                  // Bottom hill
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CustomPaint(
                      size: Size(size.width, 200),
                      painter: _HillPainter(),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Opacity(
                      opacity: _fadeIn.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, _slideUp.value),
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: size.height),
                            child: IntrinsicHeight(
                              child: Column(
                                children: [
                                  SizedBox(height: size.height * 0.05),
                                  _BijakLogo(),
                                  const SizedBox(height: 8),
                                  _TaglinePill(
                                    text: AppText.ui('splashTagline', language),
                                  ),
                                  const Spacer(),
                                  Transform.translate(
                                    offset: Offset(0, _float.value),
                                    child: Transform.scale(
                                      scale: _mascotScale.value,
                                      child: _ZaraMascot(
                                        semanticLabel: AppText.ui(
                                          'zaraTheOwl',
                                          language,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _TrustBadgeRow(language: language),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 36,
                                    ),
                                    child: Transform.scale(
                                      scale: _pulse.value,
                                      child: _LetsLearnButton(
                                        label: AppText.ui('letsLearn', language),
                                        onTap: _goToHome,
                                        countdown: _countdown,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Bijak Belajar • ${AppText.ui('splashFooter', language)}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.65,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.05),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildStars(Size size) {
    const positions = [
      [0.08, 0.10],
      [0.88, 0.08],
      [0.15, 0.25],
      [0.80, 0.22],
      [0.05, 0.45],
      [0.92, 0.40],
      [0.20, 0.65],
      [0.75, 0.60],
      [0.45, 0.05],
      [0.55, 0.15],
    ];
    const emojis = ['⭐', '✨', '🌟', '💫', '⭐', '✨', '🌟', '💫', '⭐', '✨'];
    final t = _starsCtrl.value * 2 * math.pi;
    return List.generate(positions.length, (i) {
      final wobble = math.sin(t + i * 0.6) * 7;
      final opacity = (0.4 + 0.5 * math.sin(t + i).abs()).clamp(0.0, 1.0);
      return Positioned(
        left: positions[i][0] * size.width,
        top: positions[i][1] * size.height + wobble,
        child: Opacity(
          opacity: opacity,
          child: Text(
            emojis[i],
            style: TextStyle(fontSize: 14 + (i % 3) * 5.0),
          ),
        ),
      );
    });
  }
}

class _BijakLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [AppTheme.sunnyYellow, Color(0xFFFFE066)],
          ).createShader(b),
          child: const Text(
            'Bijak',
            style: TextStyle(
              fontSize: 58,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
              height: 1.0,
              shadows: [
                Shadow(
                  color: Color(0x66000000),
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -12),
          child: const Text(
            'Belajar',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
              height: 1.0,
              shadows: [
                Shadow(
                  color: Color(0x66000000),
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TaglinePill extends StatelessWidget {
  const _TaglinePill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.sunnyYellow,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppTheme.sunnyYellow.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        '🌟  $text  🌟',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.ink,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// Zara the owl — the same tutor the child meets on the map and in every
/// lesson, so the very first screen already introduces the companion.
class _ZaraMascot extends StatelessWidget {
  const _ZaraMascot({required this.semanticLabel});
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft aurora halo behind the owl.
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.lilac.withValues(alpha: 0.45),
                    AppTheme.violet.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.lilac, AppTheme.violet],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.violet.withValues(alpha: 0.6),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text('🦉', style: TextStyle(fontSize: 82)),
            ),
            const Positioned(
              top: 18,
              right: 24,
              child: Text('⭐', style: TextStyle(fontSize: 24)),
            ),
            const Positioned(
              top: 30,
              left: 22,
              child: Text('📚', style: TextStyle(fontSize: 22)),
            ),
            const Positioned(
              bottom: 22,
              left: 22,
              child: Text('✨', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Only factual claims: every badge here must stay true to the privacy
/// policy and the Play Data safety form.
class _TrustBadgeRow extends StatelessWidget {
  const _TrustBadgeRow({required this.language});
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final badges = [
      ('📶', AppText.ui('badgeOffline', language)),
      ('🚫', AppText.ui('badgeNoAds', language)),
      ('🔒', AppText.ui('badgeNoLogin', language)),
      ('🛡️', AppText.ui('badgeNoData', language)),
    ];
    return Semantics(
      label: badges.map((b) => b.$2).join(', '),
      child: ExcludeSemantics(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final (icon, label) in badges) _Badge(icon: icon, label: label),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});
  final String icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          // Flexible lets long Tamil/Indonesian labels wrap inside the pill
          // instead of overflowing narrow phones.
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LetsLearnButton extends StatelessWidget {
  const _LetsLearnButton({
    required this.label,
    required this.onTap,
    this.countdown = 0,
  });
  final String label;
  final VoidCallback onTap;
  final int countdown;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.sunnyYellow, Color(0xFFFFB300)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppTheme.sunnyYellow.withValues(alpha: 0.7),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  // Flexible + scaleDown: Tamil/Mandarin labels differ in
                  // width, and the countdown chip shares this row.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('🎉', style: TextStyle(fontSize: 28)),
                ],
              ),
              if (countdown > 0)
                Positioned(
                  right: 16,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.ink.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$countdown',
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
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

class _HillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE3F2FD).withValues(alpha: 0.18);
    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.1,
        size.width * 0.5,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.6,
        size.width,
        size.height * 0.3,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
