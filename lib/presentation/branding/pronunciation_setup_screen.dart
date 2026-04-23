import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/branding/pronunciation_option.dart';
import '../../providers.dart';
import '../onboarding/onboarding_controller.dart';

class PronunciationSetupScreen extends ConsumerStatefulWidget {
  const PronunciationSetupScreen({super.key});

  @override
  ConsumerState<PronunciationSetupScreen> createState() => _PronunciationSetupScreenState();
}

class _PronunciationSetupScreenState extends ConsumerState<PronunciationSetupScreen> {
  late PronunciationOption _selected;

  @override
  void initState() {
    super.initState();
    final locale = PlatformDispatcher.instance.locale;
    final detected = ref.read(brandingRepositoryProvider).detectRegionalDefault(locale);
    _selected = detected.defaultOption;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How should Dope-i sound?')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            ...PronunciationOption.values.where((e) => e != PronunciationOption.custom).map(
              (option) => RadioListTile<PronunciationOption>(
                value: option,
                groupValue: _selected,
                title: Text(option.label),
                onChanged: (value) {
                  if (value != null) setState(() => _selected = value);
                },
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(onboardingControllerProvider.notifier).setPronunciation(_selected);
                  context.go('/onboarding/age-band');
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
