import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.title,
    required this.prompt,
    required this.child,
    required this.onFound,
    required this.onNext,
    this.onSpeak,
    this.foundLabel = 'Found It',
    this.tryAnotherLabel = 'Try Another',
    this.speakLabel = 'Hear Word',
  });

  final String title;
  final String prompt;
  final Widget child;
  final VoidCallback onFound;
  final VoidCallback onNext;
  final VoidCallback? onSpeak;
  final String foundLabel;
  final String tryAnotherLabel;
  final String speakLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(prompt, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 22),
            Center(child: child),
            const SizedBox(height: 18),
            if (onSpeak != null) ...[
              OutlinedButton.icon(
                onPressed: onSpeak,
                icon: const Icon(Icons.volume_up_rounded),
                label: Text(speakLabel),
              ),
              const SizedBox(height: 14),
            ],
            SizedBox(
              height: 82,
              child: Center(
                child: _MovingFoundButton(
                  label: foundLabel,
                  onPressed: onFound,
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.shuffle_rounded),
              label: Text(tryAnotherLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovingFoundButton extends StatefulWidget {
  const _MovingFoundButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_MovingFoundButton> createState() => _MovingFoundButtonState();
}

class _MovingFoundButtonState extends State<_MovingFoundButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset((offset - 0.5) * 22, -6 + offset * 12),
          child: Transform.scale(scale: 1 + offset * 0.06, child: child),
        );
      },
      child: FilledButton.icon(
        onPressed: widget.onPressed,
        icon: const Icon(Icons.stars_rounded, size: 30),
        label: Text(widget.label),
        style: FilledButton.styleFrom(
          minimumSize: const Size(168, 58),
          backgroundColor: const Color(0xFFFF7058),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
