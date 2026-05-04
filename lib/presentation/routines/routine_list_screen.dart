import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/widgets/empty_state_card.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../domain/routines/routine_model.dart';
import '../../providers.dart';
import 'routine_controller.dart';
import 'routine_run_controller.dart';

class RoutineListScreen extends ConsumerStatefulWidget {
  const RoutineListScreen({super.key});

  @override
  ConsumerState<RoutineListScreen> createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends ConsumerState<RoutineListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoutines());
  }

  void _loadRoutines() {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser != null) {
      ref.read(routineControllerProvider.notifier).load(authUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routineControllerProvider);
    return PrimaryScaffold(
      title: 'Routines',
      actions: <Widget>[
        IconButton(
          tooltip: 'Refresh routines',
          icon: const Icon(Icons.refresh),
          onPressed: _loadRoutines,
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(selectedRoutineProvider.notifier).state = null;
          ref.read(selectedRoutineStepsProvider.notifier).state = const [];
          ref.read(routineDraftTemplateProvider.notifier).state = null;
          context.push('/routines/new');
        },
        icon: const Icon(Icons.add),
        label: const Text('New routine'),
      ),
      child: state.when(
        data: (routines) {
          if (routines.isEmpty) {
            return _EmptyRoutines(onCreate: () => context.push('/routines/new'));
          }
          return ListView.separated(
            itemCount: routines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final routine = routines[index];
              return _RoutineCard(
                routine: routine,
                onOpen: () => _openRoutine(context, routine),
                onRun: () => _runRoutine(context, routine),
                onEdit: () => _editRoutine(context, routine),
                onDuplicate: () => _duplicateRoutine(context, routine),
                onDelete: () => _deleteRoutine(context, routine),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, __) => _LoadError(
          message: mapToUserFacingError(error),
          onRetry: _loadRoutines,
        ),
      ),
    );
  }

  Future<void> _openRoutine(BuildContext context, RoutineModel routine) async {
    ref.read(selectedRoutineProvider.notifier).state = routine;
    try {
      final steps = await ref
          .read(routineControllerProvider.notifier)
          .loadSteps(routine.id);
      ref.read(selectedRoutineStepsProvider.notifier).state = steps;
    } catch (_) {
      ref.read(selectedRoutineStepsProvider.notifier).state = const [];
    }
    if (context.mounted) context.push('/routines/detail');
  }

  Future<void> _editRoutine(BuildContext context, RoutineModel routine) async {
    ref.read(selectedRoutineProvider.notifier).state = routine;
    try {
      final steps = await ref
          .read(routineControllerProvider.notifier)
          .loadSteps(routine.id);
      ref.read(selectedRoutineStepsProvider.notifier).state = steps;
    } catch (error) {
      ref.read(selectedRoutineStepsProvider.notifier).state = const [];
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapToUserFacingError(error))),
        );
      }
    }
    if (context.mounted) context.push('/routines/edit');
  }

  Future<void> _runRoutine(BuildContext context, RoutineModel routine) async {
    try {
      final steps = await ref
          .read(routineControllerProvider.notifier)
          .loadSteps(routine.id);
      if (steps.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This routine has no steps yet. Add a step before running it.'),
            ),
          );
        }
        return;
      }
      ref.read(routineRunControllerProvider.notifier).start(
            routine: routine,
            steps: steps,
          );
      if (context.mounted) context.push('/routines/run');
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapToUserFacingError(error))),
        );
      }
    }
  }

  Future<void> _duplicateRoutine(
    BuildContext context,
    RoutineModel routine,
  ) async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return;
    try {
      await ref.read(routineControllerProvider.notifier).duplicate(
            userId: authUser.id,
            source: routine,
          );
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

  Future<void> _deleteRoutine(BuildContext context, RoutineModel routine) async {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine deleted.')),
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
}

class _EmptyRoutines extends StatelessWidget {
  const _EmptyRoutines({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const EmptyStateCard(
          title: 'No routines yet',
          subtitle: 'Create your first routine or start from a template.',
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: const Text('Create routine'),
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.onOpen,
    required this.onRun,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final RoutineModel routine;
  final VoidCallback onOpen;
  final VoidCallback onRun;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              const CircleAvatar(child: Icon(Icons.repeat)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      routine.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('Age band: ${routine.ageBand}'),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Run',
                onPressed: onRun,
                icon: const Icon(Icons.play_arrow_rounded),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'duplicate':
                      onDuplicate();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (_) => const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                  PopupMenuItem<String>(value: 'duplicate', child: Text('Duplicate')),
                  PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
