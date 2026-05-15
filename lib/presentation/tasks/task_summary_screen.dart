import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../data/repositories/routine_templates.dart';
import '../../domain/tasks/task_step_model.dart';
import '../routines/routine_controller.dart';
import 'task_controller.dart';

class TaskSummaryScreen extends ConsumerWidget {
  const TaskSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskControllerProvider);
    final completedSteps =
        state.steps.where((step) => step.status == StepStatus.completed).length;
    final totalSteps = state.steps.length;
    final taskTitle = state.task?.normalizedTitle.trim().isNotEmpty == true
        ? state.task!.normalizedTitle
        : 'your task';

    return PrimaryScaffold(
      title: 'Task complete',
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
            'Task complete',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            taskTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Steps completed: $completedSteps / $totalSteps',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'XP earned for completed steps.',
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: state.task == null
                ? null
                : () {
                    final template = _templateFromTaskState(state);
                    final existing = ref.read(savedTaskRoutineTemplatesProvider);
                    ref.read(savedTaskRoutineTemplatesProvider.notifier).state =
                        <RoutineTemplate>[
                      template,
                      ...existing.where((item) => item.id != template.id),
                    ];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saved "${template.title}" as a template.'),
                      ),
                    );
                  },
            icon: const Icon(Icons.bookmark_add_rounded),
            label: const Text('Save task as template'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.go('/tasks/new'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Start another task'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }
}

RoutineTemplate _templateFromTaskState(TaskViewState state) {
  final title = state.task?.normalizedTitle.trim().isNotEmpty == true
      ? state.task!.normalizedTitle.trim()
      : 'Saved task template';
  final steps = state.steps
      .where((step) => step.depthLevel > 0)
      .map((step) => step.text.trim())
      .where((step) => step.isNotEmpty)
      .toList();
  final fallbackSteps = state.steps
      .map((step) => step.text.trim())
      .where((step) => step.isNotEmpty)
      .toList();

  return RoutineTemplate(
    id: 'saved_task_${state.task?.id ?? DateTime.now().microsecondsSinceEpoch}',
    title: title,
    category: 'saved_task',
    ageBand: 'all',
    steps: steps.isEmpty ? fallbackSteps : steps,
  );
}
