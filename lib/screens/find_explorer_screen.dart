import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/find_explorer_data.dart';
import '../models/challenge.dart';
import '../models/explorer_item.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import '../utils/app_text.dart';
import '../utils/random_helper.dart';
import '../widgets/challenge_card.dart';
import '../widgets/star_counter.dart';
import 'reward_screen.dart';

class FindExplorerScreen extends StatefulWidget {
  const FindExplorerScreen({super.key});

  static const routeName = '/find-explorer';

  @override
  State<FindExplorerScreen> createState() => _FindExplorerScreenState();
}

class _FindExplorerScreenState extends State<FindExplorerScreen> {
  final RandomHelper _randomHelper = RandomHelper();
  ExplorerItem? _item;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _item ??= _randomHelper.item(explorerItems);
    _speakPrompt();
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final language = context.watch<ProgressService>().language;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.ui('findExplorer', language)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: StarCounter()),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (item == null)
              const Center(child: CircularProgressIndicator())
            else
              ChallengeCard(
                title: AppText.explorerLabel(item, language),
                prompt: AppText.findExplorerPrompt(item, language),
                onFound: _completeMission,
                onNext: _nextMission,
                onSpeak: _speakTarget,
                foundLabel: AppText.ui('foundIt', language),
                tryAnotherLabel: AppText.ui('newMission', language),
                speakLabel: AppText.ui('hearWord', language),
                child: _ExplorerItemDisplay(item: item),
              ),
          ],
        ),
      ),
    );
  }

  void _nextMission() {
    setState(() {
      _item = _randomHelper.item(explorerItems);
    });
    _speakPrompt();
  }

  Future<void> _completeMission() async {
    final progressService = context.read<ProgressService>();
    final audioService = context.read<AudioService>();
    final badge = await progressService.completeChallenge(
      ChallengeMode.findExplorer,
    );
    await audioService.playCelebration(enabled: progressService.soundEnabled);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamed(
      RewardScreen.routeName,
      arguments: RewardArgs(
        modeLabel: AppText.ui('findExplorer', progressService.language),
        nextRoute: FindExplorerScreen.routeName,
        badge: badge,
      ),
    );
  }

  void _speakTarget() {
    final item = _item;
    if (item == null) {
      return;
    }

    final progressService = context.read<ProgressService>();
    context.read<AudioService>().speak(
      AppText.explorerLabel(item, progressService.language),
      enabled: progressService.voiceEnabled,
      language: progressService.language,
    );
  }

  void _speakPrompt() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final item = _item;
      if (!mounted || item == null) {
        return;
      }

      final progressService = context.read<ProgressService>();
      context.read<AudioService>().speak(
        AppText.findExplorerPrompt(item, progressService.language),
        enabled: progressService.voiceEnabled,
        language: progressService.language,
      );
    });
  }
}

class _ExplorerItemDisplay extends StatelessWidget {
  const _ExplorerItemDisplay({required this.item});

  final ExplorerItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 188,
      height: 188,
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: item.color, width: 5),
      ),
      child: Icon(item.icon, color: item.color, size: 94),
    );
  }
}
