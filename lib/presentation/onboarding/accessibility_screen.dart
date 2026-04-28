import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';
import 'widgets/onboarding_step_scaffold.dart';

class AccessibilityScreen extends ConsumerWidget {
  const AccessibilityScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

  static const _praiseLevels = <String>['low', 'medium', 'high'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingStepScaffold(
      title: 'Accessibility & comfort',
      stepNumber: 6,
      totalSteps: 12,
      onBack: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/mode',
      ),
      onNext: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/sensory',
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
              value: state.softColors,
              onChanged: controller.setSoftColors,
              title: const Text('Soft colors'),
            ),
            SwitchListTile(
              value: state.iconMode,
              onChanged: controller.setIconMode,
              title: const Text('Icon-friendly mode'),
            ),
            SwitchListTile(
              value: state.reduceSurprises,
              onChanged: controller.setReduceSurprises,
              title: const Text('Reduce surprises'),
            ),
            SwitchListTile(
              value: state.soundEnabled,
              onChanged: controller.setSoundEnabled,
              title: const Text('Allow sound'),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Praise level'),
              subtitle: const Text('How much encouragement should Dope-i use?'),
              trailing: DropdownButton<String>(
                value: _praiseLevels.contains(state.praiseLevel)
                    ? state.praiseLevel
                    : 'medium',
                items: _praiseLevels
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) controller.setPraiseLevel(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
