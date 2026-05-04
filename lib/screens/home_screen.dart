import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../utils/app_text.dart';
import '../utils/constants.dart';
import '../widgets/big_mode_button.dart';
import '../widgets/star_counter.dart';
import '../models/train_mode.dart';
import '../models/app_language.dart';
import 'jawi_asas_screen.dart';
import 'learn_body_parts_screen.dart';
import 'learn_letters_screen.dart';
import 'learn_numbers_screen.dart';
import 'math_practice_screen.dart';
import 'memory_category_screen.dart';
import 'puzzle_screen.dart';
import 'parent_settings_screen.dart';
import 'progress_screen.dart';
import 'train_sort_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final language = context.watch<ProgressService>().language;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.ui('appName', language)),
        actions: [
          IconButton(
            tooltip: 'Progress',
            onPressed: () =>
                Navigator.of(context).pushNamed(ProgressScreen.routeName),
            icon: const Icon(Icons.insights_rounded),
          ),
          IconButton(
            tooltip: 'Parent settings',
            onPressed: () =>
                Navigator.of(context).pushNamed(ParentSettingsScreen.routeName),
            icon: const Icon(Icons.settings_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppConstants.pagePadding,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    AppText.ui('homeQuestion', language),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                const SizedBox(width: 16),
                const StarCounter(large: true),
              ],
            ),
            const SizedBox(height: 10),

            // ─── SECTION: Belajar / Learn ───
            _SectionHeader(
              emoji: '📖',
              label: language == AppLanguage.malay ? 'Belajar' : 'Learn',
            ),
            const SizedBox(height: 10),
            BigModeButton(
              title: language == AppLanguage.malay ? 'Nombor 1–10' : 'Numbers 1–10',
              subtitle: language == AppLanguage.malay
                  ? 'Kenal nombor dengan titik & perkataan'
                  : 'Learn numbers with dots & words',
              icon: Icons.looks_one_rounded,
              color: const Color(0xFFFF6B6B),
              onTap: () => Navigator.of(context).pushNamed(LearnNumbersScreen.routeName),
            ),
            const SizedBox(height: 10),
            BigModeButton(
              title: language == AppLanguage.malay ? 'Huruf A–Z' : 'Letters A–Z',
              subtitle: language == AppLanguage.malay
                  ? 'Kenal semua 26 huruf dengan contoh'
                  : 'All 26 letters with Malay examples',
              icon: Icons.abc_rounded,
              color: const Color(0xFF1DD1A1),
              onTap: () => Navigator.of(context).pushNamed(LearnLettersScreen.routeName),
            ),
            const SizedBox(height: 10),
            BigModeButton(
              title: language == AppLanguage.malay ? 'Jawi Asas حروف' : 'Jawi Letters حروف',
              subtitle: language == AppLanguage.malay
                  ? 'Kenal 28 huruf Jawi — khas untuk anak Muslim'
                  : '28 Jawi letters for Muslim children',
              icon: Icons.auto_stories_rounded,
              color: const Color(0xFF00897B),
              onTap: () => Navigator.of(context).pushNamed(JawiAsasScreen.routeName),
            ),
            const SizedBox(height: 10),
            BigModeButton(
              title: language == AppLanguage.malay ? 'Anggota Badan 🧍' : 'Body Parts 🧍',
              subtitle: language == AppLanguage.malay
                  ? 'Kenal kepala, tangan, kaki dan lain-lain'
                  : 'Learn head, hands, legs and more',
              icon: Icons.accessibility_new_rounded,
              color: const Color(0xFFE84393),
              onTap: () => Navigator.of(context).pushNamed(LearnBodyPartsScreen.routeName),
            ),

            const SizedBox(height: 16),

            // ─── SECTION: Latihan / Practice ───
            _SectionHeader(
              emoji: '🚂',
              label: language == AppLanguage.malay ? 'Latihan Susun' : 'Sort & Train',
            ),
            const SizedBox(height: 10),
            BigModeButton(
              title: AppText.trainTitle(TrainMode.numbers, language),
              subtitle: language == AppLanguage.malay
                  ? 'Susun nombor mengikut turutan yang betul'
                  : 'Sort number cars in the right order',
              icon: Icons.filter_1_rounded,
              color: TrainMode.numbers.color,
              onTap: () => Navigator.of(context).pushNamed(
                TrainSortScreen.routeName,
                arguments: const TrainSortArgs(mode: TrainMode.numbers),
              ),
            ),
            const SizedBox(height: 10),
            BigModeButton(
              title: AppText.trainTitle(TrainMode.letters, language),
              subtitle: language == AppLanguage.malay
                  ? 'Susun huruf mengikut susunan A–Z'
                  : 'Sort letter cars in A–Z order',
              icon: Icons.sort_by_alpha_rounded,
              color: TrainMode.letters.color,
              onTap: () => Navigator.of(context).pushNamed(
                TrainSortScreen.routeName,
                arguments: const TrainSortArgs(mode: TrainMode.letters),
              ),
            ),
            const SizedBox(height: 10),
            BigModeButton(
              title: language == AppLanguage.malay ? 'Matematik 🧮' : 'Maths 🧮',
              subtitle: language == AppLanguage.malay
                  ? 'Tambah, tolak, darab & bahagi'
                  : 'Addition, subtraction, multiply & divide',
              icon: Icons.calculate_rounded,
              color: const Color(0xFF6C5CE7),
              onTap: () => Navigator.of(context).pushNamed(MathPracticeScreen.routeName),
            ),

            const SizedBox(height: 16),

            // ─── SECTION: Permainan / Games ───
            _SectionHeader(
              emoji: '🎮',
              label: language == AppLanguage.malay ? 'Permainan' : 'Games',
            ),
            const SizedBox(height: 10),
            BigModeButton(
              title: AppText.ui('memoryGame', language),
              subtitle: AppText.ui('memorySubtitle', language),
              icon: Icons.grid_view_rounded,
              color: const Color(0xFF7E57C2),
              onTap: () => Navigator.of(context).pushNamed(MemoryCategoryScreen.routeName),
            ),
            const SizedBox(height: 10),
            BigModeButton(
              title: language == AppLanguage.malay ? 'Teka-Teki Gambar' : 'Picture Puzzle',
              subtitle: language == AppLanguage.malay
                  ? 'Susun kepingan gambar dengan betul!'
                  : 'Slide tiles to complete the picture!',
              icon: Icons.extension_rounded,
              color: const Color(0xFF00897B),
              onTap: () => Navigator.of(context).pushNamed(PuzzleScreen.routeName),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.emoji,
    required this.label,
  });

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$emoji  ${label.toUpperCase()}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ],
    );
  }
}
