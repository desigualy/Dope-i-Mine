import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/widgets/empty_state_card.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../domain/routines/routine_model.dart';
import '../../domain/routines/routine_step_model.dart';
import '../../providers.dart';
import 'routine_controller.dart';
import 'routine_run_controller.dart';

class RoutineDetailScreen extends ConsumerWidget {
  const RoutineDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routine = ref.watch(selectedRoutineProvider);
    final steps = ref.watch(selectedRoutineStepsProvider);

    if (routine == null) {
      return PrimaryScaffold(
        title: 'Routine detail',
        child: EmptyStateCard(
          title: 'No routine selected',
          subtitle: 'Go back to Routines and choose one to open.',
        ),
      );
    }

    return PrimaryScaffold(
      title: routine.title,
      actions: <Widget>[
        IconButton(
          tooltip: 'Edit routine',
          icon: const Icon(Icons.edit),
          onPressed: () => context.push('/routines/edit'),
        ),
      ],
      child: ListView(
        children: <Widget>[
          _RoutineSummary(routine: routine, stepCount: steps.length),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _run(context, ref, routine, steps),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Run routine'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Duplicate',
                onPressed: () => _duplicate(context, ref, routine),
                icon: const Icon(Icons.copy),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Delete',
                onPressed: () => _delete(context, ref, routine),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Steps', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (steps.isEmpty)
            const EmptyStateCard(
              title: 'No steps yet',
              subtitle: 'Edit this routine and add at least one step.',
            )
          else
            ...steps.map(
              (step) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${step.sequenceNo}')),
                  title: Text(step.stepText),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _run(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
    List<RoutineStepModel> cachedSteps,
  ) {
    if (cachedSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This routine has no steps yet. Add a step before running it.'),
        ),
      );
      return;
    }
    ref.read(routineRunControllerProvider.notifier).start(
          routine: routine,
          steps: cachedSteps,
        );
    context.push('/routines/run');
  }

  Future<void> _duplicate(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
  ) async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return;
    try {
      final duplicate = await ref.read(routineControllerProvider.notifier).duplicate(
            userId: authUser.id,
            source: routine,
          );
      ref.read(selectedRoutineProvider.notifier).state = duplicate;
      final steps = await ref
          .read(routineControllerProvider.notifier)
          .loadSteps(duplicate.id);
      ref.read(selectedRoutineStepsProvider.notifier).state = steps;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine duplicated.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapToUserFacingError(error))),
        );
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete routine?'),
        content: Text('Delete “${routine.title}”? This cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return;
    try {
      await ref.read(routineControllerProvider.notifier).delete(
            userId: authUser.id,
            routineId: routine.id,
          );
      ref.read(selectedRoutineProvider.notifier).state = null;
      ref.read(selectedRoutineStepsProvider.notifier).state = const [];
      if (context.mounted) context.go('/routines');
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapToUserFacingError(error))),
        );
      }
    }
  }
}

class _RoutineSummary extends StatelessWidget {
  const _RoutineSummary({required this.routine, required this.stepCount});

  final RoutineModel routine;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(routine.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('$stepCount steps'),
            Text('Age band: ${routine.ageBand}'),
            if (routine.category != null) Text('Category: ${routine.category}'),
          ],
        ),
      ),
    );
  }
}
