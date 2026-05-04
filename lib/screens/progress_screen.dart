import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/badge_data.dart';
import '../models/app_language.dart';
import '../models/challenge.dart';
import '../services/progress_service.dart';
import '../utils/app_text.dart';
import '../utils/constants.dart';
import '../widgets/badge_card.dart';
import '../widgets/star_counter.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const routeName = '/progress';

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final language = progress.language;

    return Scaffold(
      appBar: AppBar(title: Text(AppText.ui('progress', language))),
      body: SafeArea(
        child: ListView(
          padding: AppConstants.pagePadding,
          children: [
            const Center(child: StarCounter(large: true)),
            const SizedBox(height: 20),
            _ProgressSummary(
              completedChallenges: progress.completedChallenges,
              language: language,
              numberTrainCount: progress.countFor(ChallengeMode.numberTrain),
              letterTrainCount: progress.countFor(ChallengeMode.letterTrain),
              memoryCount: progress.countFor(ChallengeMode.memory),
            ),
            const SizedBox(height: 22),
            Text(
              AppText.ui('badges', language),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            ...badges.map(
              (badge) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BadgeCard(
                  badge: badge,
                  earned: progress.hasBadge(badge.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.completedChallenges,
    required this.language,
    required this.numberTrainCount,
    required this.letterTrainCount,
    required this.memoryCount,
  });

  final int completedChallenges;
  final AppLanguage language;
  final int numberTrainCount;
  final int letterTrainCount;
  final int memoryCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$completedChallenges challenges completed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _CountRow(
              label: AppText.ui('numberTrain', language),
              count: numberTrainCount,
            ),
            _CountRow(
              label: AppText.ui('letterTrain', language),
              count: letterTrainCount,
            ),
            _CountRow(
              label: AppText.ui('memoryGame', language),
              count: memoryCount,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
