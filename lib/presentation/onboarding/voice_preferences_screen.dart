import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';
import 'widgets/onboarding_step_scaffold.dart';

class VoicePreferencesScreen extends ConsumerWidget {
  const VoicePreferencesScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingStepScaffold(
      title: 'Voice preferences',
      stepNumber: 7,
      totalSteps: 9,
      onBack: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/permissions',
      ),
      onNext: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/voice-setup',
      ),
      nextLabel: returnToSummary ? 'Done' : 'Next',
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SwitchListTile(
              value: state.voiceEnabled,
              onChanged: controller.setVoiceEnabled,
              title: const Text('Enable voice support'),
            ),
          ],
        ),
      ),
    );
  }
}
