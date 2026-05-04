import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/memory_item.dart';
import '../services/progress_service.dart';
import '../utils/app_text.dart';
import '../utils/constants.dart';
import '../widgets/big_mode_button.dart';
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
              BigModeButton(
                title: AppText.categoryTitle(category, language),
                subtitle: AppText.categorySubtitle(category, language),
                icon: category.icon,
                color: category.color,
                onTap: () => Navigator.of(context).pushNamed(
                  MemoryGameScreen.routeName,
                  arguments: MemoryGameArgs(category: category),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
