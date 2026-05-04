import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_language.dart';
import '../services/progress_service.dart';
import '../utils/app_text.dart';
import '../utils/constants.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  static const routeName = '/parent-settings';

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final language = progress.language;

    return Scaffold(
      appBar: AppBar(title: Text(AppText.ui('parentSettings', language))),
      body: SafeArea(
        child: ListView(
          padding: AppConstants.pagePadding,
          children: [
            Card(
              child: Column(
                children: [
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
                      'Progress',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${progress.stars} stars and '
                      '${progress.completedChallenges} completed challenges',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _confirmReset(context),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset Progress'),
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
                onTap: () => _selectLanguage(context),
              ),
            ),
            const SizedBox(height: 14),
            // Developer info card
            Card(
              color: const Color(0xFFF3F0FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF6C5CE7), width: 1.5),
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
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('ANF', style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        )),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ANF Studio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF6C5CE7),
                        letterSpacing: 0.5,
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
                    _DevInfoRow(icon: Icons.apps_rounded, label: 'App', value: 'Bijak Belajar'),
                    const SizedBox(height: 6),
                    _DevInfoRow(icon: Icons.business_rounded, label: 'Studio', value: 'ANF Studio'),
                    const SizedBox(height: 6),
                    _DevInfoRow(icon: Icons.flag_rounded, label: 'Negara', value: 'Malaysia 🇲🇾'),
                    const SizedBox(height: 6),
                    _DevInfoRow(icon: Icons.child_care_rounded, label: 'Sasaran', value: 'Kanak-kanak 3–8 tahun'),
                    const SizedBox(height: 6),
                    _DevInfoRow(icon: Icons.verified_rounded, label: 'Versi', value: '1.0.0'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final progress = context.read<ProgressService>();
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

  Future<void> _selectLanguage(BuildContext context) async {
    final progress = context.read<ProgressService>();
    final selected = await showDialog<AppLanguage>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppText.ui('selectLanguage', progress.language)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final language in AppLanguage.values)
              RadioListTile<AppLanguage>(
                value: language,
                groupValue: progress.language,
                onChanged: (value) => Navigator.of(dialogContext).pop(value),
                title: Text(language.nativeName),
                subtitle: Text(language.displayName),
              ),
          ],
        ),
      ),
    );

    if (selected != null) {
      await progress.setLanguage(selected);
    }
  }
}

class _DevInfoRow extends StatelessWidget {
  const _DevInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
