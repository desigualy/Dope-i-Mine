import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/widgets/empty_state_card.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../voice/voice_controller.dart';
import 'routine_run_controller.dart';

class RoutineRunScreen extends ConsumerWidget {
  const RoutineRunScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routineRunControllerProvider);

    if (state.steps.isEmpty) {
      return PrimaryScaffold(
        title: 'Run routine',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const EmptyStateCard(
              title: 'No routine loaded',
              subtitle: 'Choose a routine first.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/routines'),
              child: const Text('Back to routines'),
            ),
          ],
        ),
      );
    }

    if (state.isComplete) {
      return _RoutineCompleteView(
        title: state.routine?.title ?? 'Routine',
        completedCount: state.completedStepIds.length,
        totalCount: state.steps.length,
        onRunAgain: () => ref
            .read(routineRunControllerProvider.notifier)
            .resetCurrentRun(),
        onBackToRoutines: () => context.go('/routines'),
      );
    }

    final step = state.currentStep!;
    final progress = '${state.currentIndex + 1} / ${state.steps.length}';

    return PrimaryScaffold(
      title: state.routine?.title ?? 'Run routine',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Step $progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text('${state.completedStepIds.length} done'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.steps.isEmpty
                ? 0
                : state.completedStepIds.length / state.steps.length,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      step.stepText,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Speak step',
                    icon: const Icon(Icons.volume_up_rounded, size: 28),
                    onPressed: () => ref.read(voiceControllerProvider).speakStep(step.stepText),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.currentIndex == 0
                      ? null
                      : () => ref
                          .read(routineRunControllerProvider.notifier)
                          .goBack(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(routineRunControllerProvider.notifier)
                          .completeCurrent();
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(mapToUserFacingError(error))),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutineCompleteView extends StatelessWidget {
  const _RoutineCompleteView({
    required this.title,
    required this.completedCount,
    required this.totalCount,
    required this.onRunAgain,
    required this.onBackToRoutines,
  });

  final String title;
  final int completedCount;
  final int totalCount;
  final VoidCallback onRunAgain;
  final VoidCallback onBackToRoutines;

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Routine complete',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Spacer(),
          Icon(
            Icons.celebration_rounded,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Routine complete',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Steps completed: $completedCount / $totalCount',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'XP earned for completed steps.',
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onRunAgain,
            icon: const Icon(Icons.replay),
            label: const Text('Run again'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onBackToRoutines,
            child: const Text('Back to routines'),
          ),
        ],
      ),
    );
  }
}
