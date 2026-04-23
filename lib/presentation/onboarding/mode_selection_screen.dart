import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../core/widgets/state_chip_selector.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import 'onboarding_controller.dart';

class ModeSelectionScreen extends ConsumerWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    return PrimaryScaffold(
      title: 'Choose support mode',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StateChipSelector<SupportMode>(
            label: 'Mode',
            values: SupportMode.values,
            selected: state.mode,
            getLabel: (value) => value.name,
            onSelected: (value) => ref.read(onboardingControllerProvider.notifier).setMode(value),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/onboarding/sensory'),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
