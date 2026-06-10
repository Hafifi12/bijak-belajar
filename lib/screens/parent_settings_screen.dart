import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../models/app_language.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_text.dart';
import '../utils/constants.dart';
import '../widgets/bijak_scene.dart';

class ParentSettingsScreen extends ConsumerWidget {
  const ParentSettingsScreen({super.key});

  static const routeName = '/parent-settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressServiceProvider);
    final language = progress.language;
    final isMalay = language == AppLanguage.malay;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.skyBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: isMalay ? 'Kembali' : 'Back',
        ),
        title: Text(AppText.ui('parentSettings', language)),
      ),
      body: BijakScene(
        topColor: AppTheme.lightBlue,
        bottomColor: Colors.white,
        showHills: false,
        child: SafeArea(
          child: ListView(
            padding: AppConstants.pagePadding,
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: progress.backgroundMusicEnabled,
                      onChanged: progress.setBackgroundMusicEnabled,
                      title: const Text('Background Music'),
                      subtitle: const Text('Soft music toggle for local audio'),
                      secondary: const Icon(Icons.music_note_rounded),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: progress.soundEnabled,
                      onChanged: progress.setSoundEnabled,
                      title: Text(AppText.ui('sound', language)),
                      subtitle: const Text('Play challenge and reward sounds'),
                      secondary: const Icon(Icons.volume_up_rounded),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: progress.voiceEnabled,
                      onChanged: progress.setVoiceEnabled,
                      title: Text(AppText.ui('voiceInstruction', language)),
                      subtitle: Text(AppText.ui('voiceSubtitle', language)),
                      secondary: const Icon(Icons.record_voice_over_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Child-Safe App',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      const Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SafetyBadge(
                            icon: Icons.wifi_off_rounded,
                            label: '100% Offline',
                          ),
                          _SafetyBadge(
                            icon: Icons.block_rounded,
                            label: 'No Ads',
                          ),
                          _SafetyBadge(
                            icon: Icons.lock_rounded,
                            label: 'No Login',
                          ),
                          _SafetyBadge(
                            icon: Icons.shield_rounded,
                            label: 'Child-Safe',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // ── Weekly recap — the "let's do your 10 minutes" nudge ──
              _WeeklyRecapCard(progress: progress, isMalay: isMalay),
              const SizedBox(height: 14),
              // ── Parent / Teacher Progress Summary ──
              _ProgressSummaryCard(progress: progress, isMalay: isMalay),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _confirmReset(context, ref),
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: Text(isMalay ? 'Set Semula Kemajuan' : 'Reset Progress'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(AppText.ui('language', language)),
                  subtitle: Text(progress.language.nativeName),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _selectLanguage(context, ref),
                ),
              ),
              const SizedBox(height: 14),
              // Developer info card
              Card(
                color: AppTheme.cream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: AppTheme.deepBlue, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Logo / icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.deepBlue.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'ANF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ANF Studio',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF6C5CE7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Developed with ❤️ for Malaysian children',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      _DevInfoRow(
                        icon: Icons.apps_rounded,
                        label: 'App',
                        value: 'Bijak Belajar',
                      ),
                      const SizedBox(height: 6),
                      _DevInfoRow(
                        icon: Icons.business_rounded,
                        label: 'Studio',
                        value: 'ANF Studio',
                      ),
                      const SizedBox(height: 6),
                      _DevInfoRow(
                        icon: Icons.flag_rounded,
                        label: 'Negara',
                        value: 'Malaysia 🇲🇾',
                      ),
                      const SizedBox(height: 6),
                      _DevInfoRow(
                        icon: Icons.child_care_rounded,
                        label: 'Sasaran',
                        value: 'Kanak-kanak 3–8 tahun',
                      ),
                      const SizedBox(height: 6),
                      _DevInfoRow(
                        icon: Icons.verified_rounded,
                        label: 'Versi',
                        value: '1.0.0+3',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final progress = ref.read(progressServiceProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text('This clears stars, badges, and completed counts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await progress.resetProgress();
    }
  }

  Future<void> _selectLanguage(BuildContext context, WidgetRef ref) async {
    final progress = ref.read(progressServiceProvider);
    final selected = await showDialog<AppLanguage>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppText.ui('selectLanguage', progress.language)),
        content: RadioGroup<AppLanguage>(
          groupValue: progress.language,
          onChanged: (value) => Navigator.of(dialogContext).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final language in AppLanguage.values)
                RadioListTile<AppLanguage>(
                  value: language,
                  title: Text(language.nativeName),
                  subtitle: Text(language.displayName),
                ),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      await progress.setLanguage(selected);
    }
  }
}

class _ProgressSummaryCard extends ConsumerWidget {
  const _ProgressSummaryCard({
    required this.progress,
    required this.isMalay,
  });
  final ProgressService progress;
  final bool isMalay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = [
      _ModuleRow(
        emoji: '🔢',
        label: isMalay ? 'Nombor' : 'Numbers',
        done: progress.getModuleLessons('numbers'),
        total: 100,
        last: progress.getLastLesson('numbers'),
        color: const Color(0xFFFF6B6B),
      ),
      _ModuleRow(
        emoji: '🔤',
        label: isMalay ? 'Huruf' : 'Letters',
        done: progress.getModuleLessons('letters'),
        total: 26,
        last: progress.getLastLesson('letters'),
        color: const Color(0xFF1DD1A1),
      ),
      _ModuleRow(
        emoji: '🌙',
        label: isMalay ? 'Jawi' : 'Jawi',
        done: progress.getModuleLessons('jawi'),
        total: 28,
        last: progress.getLastLesson('jawi'),
        color: const Color(0xFF00B894),
      ),
      _ModuleRow(
        emoji: '🧍',
        label: isMalay ? 'Anggota Badan' : 'Body Parts',
        done: progress.getModuleLessons('bodyparts'),
        total: 14,
        last: progress.getLastLesson('bodyparts'),
        color: const Color(0xFFE84393),
      ),
      _ModuleRow(
        emoji: '🧮',
        label: isMalay ? 'Matematik' : 'Math',
        done: progress.getModuleLessons('math'),
        total: 50,
        last: progress.getLastLesson('math'),
        color: const Color(0xFF6C5CE7),
      ),
      _ModuleRow(
        emoji: '🎨',
        label: isMalay ? 'Mewarna' : 'Colouring',
        done: progress.coloringSessions,
        total: 40,
        last: '',
        color: const Color(0xFFFF9F43),
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded, color: Color(0xFF7C4DFF)),
                const SizedBox(width: 8),
                Text(
                  isMalay
                      ? '📊 Laporan Kemajuan Kanak-Kanak'
                      : '📊 Child Progress Report',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF123A7A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isMalay
                  ? 'Untuk ibu bapa & guru tadika'
                  : 'For parents & kindergarten teachers',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9090A8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            // ── Summary row ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatBubble(
                    value: '⭐ ${progress.stars}',
                    label: isMalay ? 'Bintang' : 'Stars',
                    color: const Color(0xFFFFD21E),
                  ),
                  _StatBubble(
                    value: '✅ ${progress.completedChallenges}',
                    label: isMalay ? 'Selesai' : 'Completed',
                    color: const Color(0xFF34C759),
                  ),
                  _StatBubble(
                    value: '🎨 ${progress.coloringSessions}',
                    label: isMalay ? 'Mewarna' : 'Colouring',
                    color: const Color(0xFFFF9F43),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            Text(
              isMalay ? 'Kemajuan Mengikut Modul:' : 'Progress by Module:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF123A7A),
              ),
            ),
            const SizedBox(height: 10),

            ...modules.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(m.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              m.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: m.color,
                              ),
                            ),
                          ),
                          Text(
                            '${m.done}/${m.total}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: m.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: m.total > 0
                              ? (m.done / m.total).clamp(0.0, 1.0)
                              : 0,
                          minHeight: 7,
                          backgroundColor: m.color.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(m.color),
                        ),
                      ),
                      if (m.last.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '📌 ${isMalay ? "Terakhir" : "Last"}: ${m.last}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9090A8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                )),

            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF34C759).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFF34C759),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isMalay
                          ? 'Semua data disimpan secara tempatan. Tiada internet diperlukan.'
                          : 'All data is stored locally. No internet required.',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A7A4A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleRow {
  const _ModuleRow({
    required this.emoji,
    required this.label,
    required this.done,
    required this.total,
    required this.last,
    required this.color,
  });
  final String emoji;
  final String label;
  final int done;
  final int total;
  final String last;
  final Color color;
}

class _StatBubble extends ConsumerWidget {
  const _StatBubble({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF123A7A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SafetyBadge extends ConsumerWidget {
  const _SafetyBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.deepBlue.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.leafGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DevInfoRow extends ConsumerWidget {
  const _DevInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6C5CE7)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6C5CE7),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}

// ── Weekly recap card ────────────────────────────────────────────────────────
class _WeeklyRecapCard extends StatelessWidget {
  const _WeeklyRecapCard({required this.progress, required this.isMalay});
  final ProgressService progress;
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        '⭐',
        isMalay ? 'Bintang minggu ini' : 'Stars this week',
        '${progress.starsThisWeek}',
      ),
      (
        '🎮',
        isMalay ? 'Permainan selesai' : 'Games completed',
        '${progress.gamesThisWeek}',
      ),
      (
        '🎨',
        isMalay ? 'Sesi mewarna' : 'Colouring sessions',
        '${progress.coloringThisWeek}',
      ),
      (
        '🔥',
        isMalay ? 'Streak semasa' : 'Current streak',
        isMalay
            ? '${progress.currentStreak} hari'
            : '${progress.currentStreak} days',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isMalay ? '📅 Ringkasan Minggu Ini' : '📅 This Week\'s Recap',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              isMalay
                  ? 'Sejak Isnin — gunakan untuk sesi 10 minit bersama anak.'
                  : 'Since Monday — use it to plan a 10-minute session together.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            for (final (emoji, label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
