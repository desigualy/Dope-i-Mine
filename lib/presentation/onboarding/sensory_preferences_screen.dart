import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';
import 'widgets/onboarding_step_scaffold.dart';

class SensoryPreferencesScreen extends ConsumerWidget {
  const SensoryPreferencesScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingStepScaffold(
      title: 'Sensory preferences',
      stepNumber: 6,
      totalSteps: 9,
      onBack: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/mode',
      ),
      onNext: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/accessibility',
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SwitchListTile(
              value: state.reducedAnimation,
              onChanged: controller.setReducedAnimation,
              title: const Text('Reduce animation'),
            ),
            SwitchListTile(
              value: state.largeText,
              onChanged: controller.setLargeText,
              title: const Text('Large text'),
            ),
            SwitchListTile(
              value: state.soundEnabled,
              onChanged: controller.setSoundEnabled,
              title: const Text('Allow sound'),
            ),
          ],
        ),
      ),
    );
  }
}
