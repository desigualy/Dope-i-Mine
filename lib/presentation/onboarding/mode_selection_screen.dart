import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/state_chip_selector.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_step_scaffold.dart';

class ModeSelectionScreen extends ConsumerWidget {
  const ModeSelectionScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);

    return OnboardingStepScaffold(
      title: 'Choose support mode',
      stepNumber: 5,
      totalSteps: 12,
      onBack: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/assistant-name',
      ),
      onNext: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/accessibility',
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StateChipSelector<SupportMode>(
              label: 'Mode',
              values: SupportMode.values,
              selected: state.mode,
              getLabel: (value) => value.name,
              onSelected: (value) =>
                  ref.read(onboardingControllerProvider.notifier).setMode(value),
            ),
          ],
        ),
      ),
    );
  }
}
