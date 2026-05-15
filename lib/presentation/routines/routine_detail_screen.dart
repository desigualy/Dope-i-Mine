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
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          _RoutineSummary(routine: routine, stepCount: steps.length),
          const SizedBox(height: 16),
          _RoutineActionDock(
            onRun: () => _run(context, ref, routine, steps),
            onDuplicate: () => _duplicate(context, ref, routine),
            onDelete: () => _delete(context, ref, routine),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Step-by-step path',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${steps.length} ${steps.length == 1 ? 'step' : 'steps'}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (steps.isEmpty)
            const EmptyStateCard(
              title: 'No steps yet',
              subtitle: 'Edit this routine and add at least one step.',
            )
          else
            ...steps.map(
              (step) => _RoutineStepPreview(
                step: step,
                isLast: step.sequenceNo == steps.length,
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
          content: Text(
              'This routine has no steps yet. Add a step before running it.'),
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
      final duplicate =
          await ref.read(routineControllerProvider.notifier).duplicate(
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            scheme.primary,
            scheme.tertiary.withOpacity(0.86),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.primary.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -24,
            top: -28,
            child: Icon(Icons.route_rounded,
                size: 132, color: Colors.white.withOpacity(0.11)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: const Text(
                  'Ready when you are',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                routine.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Run it gently, duplicate it for another day, or remix the steps when life changes shape.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _SummaryPill(
                      icon: Icons.checklist_rtl_rounded,
                      label: '$stepCount ${stepCount == 1 ? 'step' : 'steps'}'),
                  _SummaryPill(
                      icon: Icons.face_retouching_natural_rounded,
                      label: routine.ageBand),
                  if (routine.category != null)
                    _SummaryPill(
                        icon: Icons.category_rounded, label: routine.category!),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _RoutineActionDock extends StatelessWidget {
  const _RoutineActionDock({
    required this.onRun,
    required this.onDuplicate,
    required this.onDelete,
  });

  final VoidCallback onRun;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.62)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: FilledButton.icon(
              onPressed: onRun,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Run routine'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Duplicate',
            onPressed: onDuplicate,
            icon: const Icon(Icons.copy_rounded),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _RoutineStepPreview extends StatelessWidget {
  const _RoutineStepPreview({required this.step, required this.isLast});

  final RoutineStepModel step;
  final bool isLast;

  static const List<Color> _colors = <Color>[
    Color(0xFF7C4DFF),
    Color(0xFF00ACC1),
    Color(0xFFFF8A65),
    Color(0xFF66BB6A),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _colors[(step.sequenceNo - 1) % _colors.length];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: accent.withOpacity(0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                '${step.sequenceNo}',
                style: TextStyle(color: accent, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step.stepText,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLast ? Icons.celebration_rounded : Icons.arrow_downward_rounded,
              color: isLast ? const Color(0xFFFF8A65) : scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
