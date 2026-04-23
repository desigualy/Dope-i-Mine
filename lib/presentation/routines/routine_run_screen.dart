import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state_card.dart';
import '../../core/widgets/primary_scaffold.dart';
import 'routine_run_controller.dart';

class RoutineRunScreen extends ConsumerWidget {
  const RoutineRunScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routineRunControllerProvider);

    if (state.steps.isEmpty) {
      return const PrimaryScaffold(
        title: 'Run routine',
        child: EmptyStateCard(
          title: 'No routine loaded',
          subtitle: 'Choose a routine first.',
        ),
      );
    }

    final step = state.steps[state.currentIndex];
    final progress = '${state.currentIndex + 1} / ${state.steps.length}';

    return PrimaryScaffold(
      title: 'Run routine',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Step $progress',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                step.stepText,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(routineRunControllerProvider.notifier).goBack();
                  },
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(routineRunControllerProvider.notifier).completeCurrent();
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
