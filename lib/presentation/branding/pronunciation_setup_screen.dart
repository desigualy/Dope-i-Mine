import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/branding/pronunciation_option.dart';
import '../../providers.dart';
import '../onboarding/onboarding_controller.dart';
import '../onboarding/widgets/onboarding_step_scaffold.dart';

class PronunciationSetupScreen extends ConsumerStatefulWidget {
  const PronunciationSetupScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

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
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Pick the pronunciation you prefer.'),
        const SizedBox(height: 12),
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
      ],
    );

    return OnboardingStepScaffold(
      title: 'How should Dope-i sound?',
      stepNumber: 2,
      totalSteps: 12,
      onBack: () => context.go(
        widget.returnToSummary ? '/onboarding/summary' : '/branding/intro',
      ),
      onNext: () {
        ref.read(onboardingControllerProvider.notifier).setPronunciation(_selected);
        context.go(
          widget.returnToSummary
              ? '/onboarding/summary'
              : '/onboarding/age-band',
        );
      },
      nextLabel: 'Continue',
      child: SingleChildScrollView(child: content),
    );
  }
}
