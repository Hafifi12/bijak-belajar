import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_language.dart';
import '../models/memory_item.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_text.dart';
import '../utils/constants.dart';
import 'memory_game_screen.dart';

class MemoryCategoryScreen extends StatelessWidget {
  const MemoryCategoryScreen({super.key});

  static const routeName = '/memory';

  @override
  Widget build(BuildContext context) {
    final language = context.watch<ProgressService>().language;

    return Scaffold(
      appBar: AppBar(title: Text(AppText.ui('memoryGame', language))),
      body: SafeArea(
        child: ListView(
          padding: AppConstants.pagePadding,
          children: [
            Text(
              AppText.ui('pickMemoryGame', language),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 22),
            for (final category in MemoryCategory.values) ...[
              _MemoryCategoryStageCard(category: category, language: language),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _MemoryCategoryStageCard extends StatelessWidget {
  const _MemoryCategoryStageCard({
    required this.category,
    required this.language,
  });

  final MemoryCategory category;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final isMalay = language == AppLanguage.malay;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, AppTheme.cream],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: category.color.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: Icon(category.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.categoryTitle(category, language),
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppText.categorySubtitle(category, language),
                      style: const TextStyle(
                        color: Color(0xFF5E6FA3),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isMalay ? 'Pilih tahap:' : 'Choose a stage:',
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final stage in MemoryStage.values)
                _StageButton(
                  category: category,
                  stage: stage,
                  isMalay: isMalay,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StageButton extends StatelessWidget {
  const _StageButton({
    required this.category,
    required this.stage,
    required this.isMalay,
  });

  final MemoryCategory category;
  final MemoryStage stage;
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: category.color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => Navigator.of(context).pushNamed(
          MemoryGameScreen.routeName,
          arguments: MemoryGameArgs(category: category, stage: stage),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: category.color.withValues(alpha: 0.32)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.grid_view_rounded, color: category.color, size: 16),
              const SizedBox(width: 6),
              Text(
                stage.boardLabel(isMalay: isMalay),
                style: TextStyle(
                  color: category.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
