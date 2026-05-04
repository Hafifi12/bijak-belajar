import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'parent_settings_screen.dart';

class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({super.key});

  static const routeName = '/parent-gate';

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  final TextEditingController _answerController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Check')),
      body: SafeArea(
        child: ListView(
          padding: AppConstants.pagePadding,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'For grown-ups',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the answer to open parent settings.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'What is 4 + 3?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _answerController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Answer',
                        errorText: _error,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onSubmitted: (_) => _checkAnswer(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _checkAnswer,
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('Open Settings'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnswer() {
    if (_answerController.text.trim() == '7') {
      Navigator.of(
        context,
      ).pushReplacementNamed(ParentSettingsScreen.routeName);
      return;
    }

    setState(() {
      _error = 'Try again';
    });
  }
}
