import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../core/widgets/state_chip_selector.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import 'onboarding_controller.dart';

class AgeBandScreen extends ConsumerWidget {
  const AgeBandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    return PrimaryScaffold(
      title: 'Choose age band',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StateChipSelector<AgeBand>(
            label: 'Age band',
            values: AgeBand.values,
            selected: state.ageBand,
            getLabel: (value) => value.name,
            onSelected: (value) => ref.read(onboardingControllerProvider.notifier).setAgeBand(value),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/onboarding/assistant-name'),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
