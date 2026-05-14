import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
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

  void _createRoutine() {
    ref.read(selectedRoutineProvider.notifier).state = null;
    ref.read(selectedRoutineStepsProvider.notifier).state = const [];
    ref.read(routineDraftTemplateProvider.notifier).state = null;
    context.push('/routines/new');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routineControllerProvider);
    return PrimaryScaffold(
      title: 'My routines',
      actions: <Widget>[
        IconButton(
          tooltip: 'Refresh routines',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _loadRoutines,
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRoutine,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New routine'),
      ),
      child: state.when(
        data: (routines) => RefreshIndicator(
          onRefresh: () async => _loadRoutines(),
          child: routines.isEmpty
              ? _EmptyRoutines(onCreate: _createRoutine)
              : _RoutineListView(
                  routines: routines,
                  onCreate: _createRoutine,
                  onOpen: (routine) => _openRoutine(context, routine),
                  onRun: (routine) => _runRoutine(context, routine),
                  onEdit: (routine) => _editRoutine(context, routine),
                  onDuplicate: (routine) => _duplicateRoutine(context, routine),
                  onDelete: (routine) => _deleteRoutine(context, routine),
                ),
        ),
        loading: () => const _RoutineLoadingView(),
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
                content: Text(
                    'This routine has no steps yet. Add a step before running it.')),
          );
        }
        return;
      }
      ref
          .read(routineRunControllerProvider.notifier)
          .start(routine: routine, steps: steps);
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
      BuildContext context, RoutineModel routine) async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return;
    try {
      await ref
          .read(routineControllerProvider.notifier)
          .duplicate(userId: authUser.id, source: routine);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Routine duplicated.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapToUserFacingError(error))),
        );
      }
    }
  }

  Future<void> _deleteRoutine(
      BuildContext context, RoutineModel routine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete routine?'),
        content: Text('Delete "${routine.title}"? This cannot be undone.'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return;
    try {
      await ref
          .read(routineControllerProvider.notifier)
          .delete(userId: authUser.id, routineId: routine.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Routine deleted.')));
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

class _RoutineListView extends StatelessWidget {
  const _RoutineListView({
    required this.routines,
    required this.onCreate,
    required this.onOpen,
    required this.onRun,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final List<RoutineModel> routines;
  final VoidCallback onCreate;
  final ValueChanged<RoutineModel> onOpen;
  final ValueChanged<RoutineModel> onRun;
  final ValueChanged<RoutineModel> onEdit;
  final ValueChanged<RoutineModel> onDuplicate;
  final ValueChanged<RoutineModel> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: routines.length + 3,
      separatorBuilder: (_, index) => SizedBox(height: index < 2 ? 16 : 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _RoutineHero(count: routines.length, onCreate: onCreate);
        }
        if (index == 1) return _RoutineMoodStrip(routines: routines);
        if (index == 2) return const _RoutineSectionHeader();

        final routine = routines[index - 3];
        return _RoutineCard(
          routine: routine,
          index: index - 3,
          onOpen: () => onOpen(routine),
          onRun: () => onRun(routine),
          onEdit: () => onEdit(routine),
          onDuplicate: () => onDuplicate(routine),
          onDelete: () => onDelete(routine),
        );
      },
    );
  }
}

class _RoutineHero extends StatelessWidget {
  const _RoutineHero({required this.count, required this.onCreate});

  final int count;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[scheme.primary, scheme.tertiary.withOpacity(0.86)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.primary.withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -20,
            top: -28,
            child: Icon(Icons.auto_awesome_rounded,
                size: 120, color: Colors.white.withOpacity(0.11)),
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
                  'Gentle structure, your way',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                count == 1
                    ? 'You have 1 routine ready.'
                    : 'You have $count routines ready.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a repeatable rhythm, run it step-by-step, or remix it when today needs a different pace.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _HeroStat(
                      icon: Icons.view_list_rounded,
                      label: 'Saved',
                      value: '$count'),
                  const _HeroStat(
                      icon: Icons.play_circle_fill_rounded,
                      label: 'Tap',
                      value: 'Run'),
                  const _HeroStat(
                      icon: Icons.edit_note_rounded,
                      label: 'Remix',
                      value: 'Anytime'),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: scheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create a routine'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(value,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900)),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.82), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutineMoodStrip extends StatelessWidget {
  const _RoutineMoodStrip({required this.routines});

  final List<RoutineModel> routines;

  @override
  Widget build(BuildContext context) {
    final categories = routines
        .map((routine) => routine.category?.trim())
        .whereType<String>()
        .where((category) => category.isNotEmpty)
        .toSet()
        .take(3)
        .toList();
    final chips = categories.isEmpty
        ? <String>['Morning', 'Focus', 'Wind-down']
        : categories;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < chips.length; i++) ...<Widget>[
            _MoodChip(label: chips[i], index: i),
            if (i != chips.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.label, required this.index});

  final String label;
  final int index;

  static const List<Color> _colors = <Color>[
    Color(0xFFFFE0B2),
    Color(0xFFC8E6C9),
    Color(0xFFBBDEFB),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.bubble_chart_rounded,
              size: 16, color: Colors.grey.shade800),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _RoutineSectionHeader extends StatelessWidget {
  const _RoutineSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Choose your rhythm',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Text(
          'Swipe down to refresh',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.index,
    required this.onOpen,
    required this.onRun,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final RoutineModel routine;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onRun;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  static const List<Color> _accentColors = <Color>[
    Color(0xFF7C4DFF),
    Color(0xFF00ACC1),
    Color(0xFFFF8A65),
    Color(0xFF66BB6A),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _accentColors[index % _accentColors.length];
    final category = _formatNullable(routine.category) ?? 'Routine';
    final mode = _formatNullable(routine.modeTarget) ?? 'Flexible pace';

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withOpacity(0.48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.72)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(Icons.route_rounded, color: accent, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          routine.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            _RoutineTag(
                                icon: Icons.category_rounded, label: category),
                            _RoutineTag(
                                icon: Icons.face_retouching_natural_rounded,
                                label: routine.ageBand),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_RoutineMenuAction>(
                    tooltip: 'Routine actions',
                    onSelected: (action) {
                      switch (action) {
                        case _RoutineMenuAction.edit:
                          onEdit();
                          break;
                        case _RoutineMenuAction.duplicate:
                          onDuplicate();
                          break;
                        case _RoutineMenuAction.delete:
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) =>
                        const <PopupMenuEntry<_RoutineMenuAction>>[
                      PopupMenuItem(
                          value: _RoutineMenuAction.edit, child: Text('Edit')),
                      PopupMenuItem(
                          value: _RoutineMenuAction.duplicate,
                          child: Text('Duplicate')),
                      PopupMenuDivider(),
                      PopupMenuItem(
                          value: _RoutineMenuAction.delete,
                          child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.speed_rounded, color: accent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        mode,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onRun,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Run'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _formatNullable(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

enum _RoutineMenuAction { edit, duplicate, delete }

class _RoutineTag extends StatelessWidget {
  const _RoutineTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: scheme.primary),
          const SizedBox(width: 6),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _EmptyRoutines extends StatelessWidget {
  const _EmptyRoutines({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 96),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withOpacity(0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.primary.withOpacity(0.16)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle),
                child:
                    Icon(Icons.route_rounded, size: 42, color: scheme.primary),
              ),
              const SizedBox(height: 18),
              Text(
                'Build your first rhythm',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(
                'Create a gentle sequence for mornings, focus blocks, bedtime, or any moment that needs less friction.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create routine'),
              ),
              const SizedBox(height: 12),
              Text(
                'Tip: keep it tiny. Three clear steps can be enough.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoutineLoadingView extends StatelessWidget {
  const _RoutineLoadingView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Container(
        height: index == 0 ? 190 : 132,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withOpacity(0.46),
          borderRadius: BorderRadius.circular(index == 0 ? 28 : 24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SkeletonBar(widthFactor: index == 0 ? 0.42 : 0.64),
            const SizedBox(height: 14),
            _SkeletonBar(widthFactor: index == 0 ? 0.88 : 0.82),
            const SizedBox(height: 10),
            _SkeletonBar(widthFactor: index == 0 ? 0.68 : 0.48),
            const Spacer(),
            const Row(
              children: <Widget>[
                _SkeletonPill(),
                SizedBox(width: 10),
                _SkeletonPill(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 14,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.86),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SkeletonPill extends StatelessWidget {
  const _SkeletonPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.86),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: scheme.errorContainer.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: <Widget>[
              Icon(Icons.cloud_off_rounded, color: scheme.error, size: 46),
              const SizedBox(height: 12),
              Text(
                'Routines did not load',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onErrorContainer)),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
