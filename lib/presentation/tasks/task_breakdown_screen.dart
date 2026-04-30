import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/tasks/task_state_snapshot.dart';
import '../../domain/tasks/task_step_model.dart';
import '../../providers.dart';
import '../core/controllers/avatar_controller.dart';
import '../core/widgets/dopei_avatar.dart';
import '../overwhelm/overwhelm_controller.dart';
import '../overwhelm/overwhelm_support_sheet.dart';
import '../rewards/reward_controller.dart';
import '../rewards/widgets/xp_bar.dart';
import '../sidequests/side_quest_panel.dart';
import 'task_controller.dart';
import 'task_session_controller.dart';
import 'widgets/minimum_version_toggle.dart';
import 'widgets/step_card.dart';

class TaskBreakdownScreen extends ConsumerWidget {
  const TaskBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskControllerProvider);
    final session = ref.watch(taskSessionControllerProvider);
    final rewardState = ref.watch(rewardControllerProvider);
    final avatarState = ref.watch(avatarControllerProvider);
    final overwhelm = ref.watch(overwhelmControllerProvider);
    final isMinimumMode =
        state.showMinimumVersion || overwhelm.useMinimumVersion;
    final sections = state.steps.where((step) => step.depthLevel == 0).toList()
      ..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
    final focusedSection = state.focusedSectionId == null
        ? null
        : _firstWhereOrNull(
            sections, (step) => step.id == state.focusedSectionId);
    var visibleSteps = _visibleSteps(
      allSteps: state.steps,
      focusedSectionId: state.focusedSectionId,
      minimumSteps: state.minimumVersion,
      minimumMode: isMinimumMode,
    );

    if ((session.showOnlyCurrentStep || overwhelm.showOnlyCurrentStep) &&
        visibleSteps.isNotEmpty) {
      final index = session.currentStepIndex.clamp(0, visibleSteps.length - 1);
      visibleSteps = <TaskStepModel>[visibleSteps[index]];
    }

    final completableSteps = isMinimumMode
        ? state.minimumVersion
        : state.steps.where((step) => step.depthLevel > 0).toList();
    final allStepsCompleted = completableSteps.isNotEmpty &&
        completableSteps.every((step) => step.status == StepStatus.completed);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser != null && rewardState is AsyncLoading) {
        ref.read(rewardControllerProvider.notifier).loadStats(authUser.id);
      }
      if (avatarState.mood == DopeiMood.neutral) {
        ref.read(avatarControllerProvider.notifier).setMood(DopeiMood.focused);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(state.task?.normalizedTitle ?? 'Task breakdown'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FloatingDopeiAvatar(
              mood:
                  allStepsCompleted ? DopeiMood.celebration : avatarState.mood,
              size: 40,
            ),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (_) => const OverwhelmSupportSheet(),
              );
            },
            icon: const Icon(Icons.warning_amber_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              rewardState.when(
                data: (stats) => XPBar(
                  level: stats.level,
                  progress: stats.progressToNextLevel,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              _TaskHeader(
                title: state.task?.normalizedTitle ?? 'Today’s Task',
                sectionCount: sections.length,
                totalStepCount:
                    state.steps.where((step) => step.depthLevel == 1).length,
                focusedSection: focusedSection,
                onBack: state.focusedSectionId == null
                    ? null
                    : () => ref
                        .read(taskControllerProvider.notifier)
                        .clearFocusedSection(),
              ),
              if (overwhelm.isActive) ...<Widget>[
                const SizedBox(height: 12),
                _OverwhelmBanner(
                  message: overwhelm.supportiveAction ??
                      'Calm mode is active. One tiny thing at a time.',
                  onExit: () {
                    ref
                        .read(overwhelmControllerProvider.notifier)
                        .exitOverwhelmMode();
                    ref
                        .read(avatarControllerProvider.notifier)
                        .setMood(DopeiMood.focused);
                  },
                ),
              ],
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: MinimumVersionToggle(
                      value: isMinimumMode,
                      onChanged: overwhelm.isActive
                          ? null
                          : (value) => ref
                              .read(taskControllerProvider.notifier)
                              .toggleMinimumVersion(value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _SideQuestToggle(
                    value: state.showSideQuests,
                    onChanged: (value) => ref
                        .read(taskControllerProvider.notifier)
                        .toggleSideQuests(value),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () => ref
                        .read(taskSessionControllerProvider.notifier)
                        .pause(),
                    child: const Text('Pause'),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(taskSessionControllerProvider.notifier)
                        .resume(),
                    child: const Text('Resume'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (visibleSteps.isEmpty)
                const _EmptyBreakdownCard()
              else if (state.focusedSectionId == null && !isMinimumMode)
                ...visibleSteps.map(
                  (section) => _SectionCard(
                    section: section,
                    stepCount: _childrenOf(state.steps, section.id).length,
                    completedCount: _childrenOf(state.steps, section.id)
                        .where((step) => step.status == StepStatus.completed)
                        .length,
                    onOpen: () => ref
                        .read(taskControllerProvider.notifier)
                        .setFocusedSection(section.id),
                    onBreakDown: () async {
                      final substeps = await _breakDownStep(ref, section);
                      ref
                          .read(taskControllerProvider.notifier)
                          .replaceStepWithSubsteps(
                            stepId: section.id,
                            substeps: substeps,
                            isMinimumVersion: false,
                          );
                      ref
                          .read(taskControllerProvider.notifier)
                          .setFocusedSection(section.id);
                    },
                  ),
                )
              else
                _StepProcessList(
                  parentSteps: visibleSteps,
                  allSteps: isMinimumMode ? state.minimumVersion : state.steps,
                  onBreakDownMore: (step) async {
                    final substeps = await _breakDownStep(ref, step);
                    ref
                        .read(taskControllerProvider.notifier)
                        .replaceStepWithSubsteps(
                          stepId: step.id,
                          substeps: substeps,
                          isMinimumVersion: isMinimumMode,
                        );
                  },
                  onComplete: (step) => _completeStep(context, ref, step),
                ),
              const SizedBox(height: 16),
              if (allStepsCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/tasks/summary'),
                    child: const Text('View Summary & Continue'),
                  ),
                ),
              if (state.task?.id != null) ...<Widget>[
                const SizedBox(height: 24),
                if (state.showSideQuests)
                  Text(
                    'Side Quest Available:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const SizedBox(height: 8),
                SideQuestPanel(taskId: state.task!.id),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

List<TaskStepModel> _visibleSteps({
  required List<TaskStepModel> allSteps,
  required String? focusedSectionId,
  required List<TaskStepModel> minimumSteps,
  required bool minimumMode,
}) {
  if (minimumMode) {
    return minimumSteps.where((step) => step.parentStepId == null).toList()
      ..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
  }
  final visible = focusedSectionId == null
      ? allSteps.where((step) => step.depthLevel == 0).toList()
      : allSteps
          .where((step) => step.parentStepId == focusedSectionId)
          .toList();
  visible.sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
  return visible;
}

List<TaskStepModel> _childrenOf(List<TaskStepModel> allSteps, String parentId) {
  final children =
      allSteps.where((step) => step.parentStepId == parentId).toList();
  children.sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
  return children;
}

TaskStepModel? _firstWhereOrNull(
  List<TaskStepModel> steps,
  bool Function(TaskStepModel step) test,
) {
  for (final step in steps) {
    if (test(step)) return step;
  }
  return null;
}

Future<List<TaskStepModel>> _breakDownStep(WidgetRef ref, TaskStepModel step) {
  return ref.read(taskRepositoryProvider).breakDownStep(
        stepId: step.id,
        snapshot: const TaskStateSnapshot(
          mode: SupportMode.audhd,
          energyLevel: EnergyLevel.medium,
          stressLevel: StressLevel.friction,
          timeAvailable: TimeAvailable.fifteenMinutes,
        ),
        stepText: step.text,
      );
}

Future<void> _completeStep(
  BuildContext context,
  WidgetRef ref,
  TaskStepModel step,
) async {
  final authUser = ref.read(authRepositoryProvider).getCurrentUser();
  if (authUser == null) return;
  await ref.read(taskRepositoryProvider).completeStep(
        userId: authUser.id,
        stepId: step.id,
      );
  ref
      .read(taskControllerProvider.notifier)
      .updateStepCompletion(step.id, 'completed');
  await _rewardOverwhelmSectionIfComplete(context, ref, step, authUser.id);
  ref.read(rewardControllerProvider.notifier).refreshStats(authUser.id);
  ref.read(avatarControllerProvider.notifier).setMood(DopeiMood.happy);
  ref.read(taskSessionControllerProvider.notifier).nextStep();
}

Future<void> _rewardOverwhelmSectionIfComplete(
  BuildContext context,
  WidgetRef ref,
  TaskStepModel completedStep,
  String userId,
) async {
  if (!ref.read(overwhelmControllerProvider).isActive ||
      completedStep.parentStepId == null) {
    return;
  }

  final updatedSteps = ref.read(taskControllerProvider).steps;
  final siblingSteps = _childrenOf(updatedSteps, completedStep.parentStepId!);
  final wholeBreakdownSectionComplete = siblingSteps.isNotEmpty &&
      siblingSteps.every((step) => step.status == StepStatus.completed);
  if (!wholeBreakdownSectionComplete) return;

  await ref.read(rewardRepositoryProvider).awardXp(
        userId: userId,
        amount: 25,
        key: 'overwhelm_breakdown_section_complete',
        sourceType: 'task_step',
        sourceId: completedStep.parentStepId,
      );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Breakdown section complete — +25 XP for getting through overwhelm.',
        ),
      ),
    );
  }
}

class _TaskHeader extends StatelessWidget {
  const _TaskHeader({
    required this.title,
    required this.sectionCount,
    required this.totalStepCount,
    required this.focusedSection,
    required this.onBack,
  });

  final String title;
  final int sectionCount;
  final int totalStepCount;
  final TaskStepModel? focusedSection;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (onBack != null)
              IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            Expanded(
              child: Text(
                focusedSection == null
                    ? 'Today’s Task: $title'
                    : focusedSection!.text,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          focusedSection == null
              ? '$sectionCount sections • $totalStepCount bitesize steps'
              : 'Bitesize steps for this section',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.stepCount,
    required this.completedCount,
    required this.onOpen,
    required this.onBreakDown,
  });

  final TaskStepModel section;
  final int stepCount;
  final int completedCount;
  final VoidCallback onOpen;
  final VoidCallback onBreakDown;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Checkbox(
                  value: stepCount > 0 && completedCount == stepCount,
                  onChanged: null),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${section.sequenceNo}. ${section.text}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('$stepCount steps'),
                    if (stepCount > 0) Text('$completedCount completed'),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Break into bitesize steps',
                onPressed: onBreakDown,
                icon: const Icon(Icons.auto_fix_high),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepProcessList extends StatelessWidget {
  const _StepProcessList({
    required this.parentSteps,
    required this.allSteps,
    required this.onBreakDownMore,
    required this.onComplete,
  });

  final List<TaskStepModel> parentSteps;
  final List<TaskStepModel> allSteps;
  final Future<void> Function(TaskStepModel step) onBreakDownMore;
  final Future<void> Function(TaskStepModel step) onComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parentSteps
          .expand((step) => <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: StepCard(
                    step: step,
                    onBreakDownMore: step.depthLevel < 2
                        ? () => onBreakDownMore(step)
                        : null,
                    onComplete: () => onComplete(step),
                  ),
                ),
                ..._nestedStepCards(step, 1),
              ])
          .toList(),
    );
  }

  List<Widget> _nestedStepCards(TaskStepModel parent, int depth) {
    return _childrenOf(allSteps, parent.id)
        .expand(
          (child) => <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StepCard(
                step: child,
                depthIndent: depth,
                onBreakDownMore: child.depthLevel < 2
                    ? () => onBreakDownMore(child)
                    : null,
                onComplete: () => onComplete(child),
              ),
            ),
            ..._nestedStepCards(child, depth + 1),
          ],
        )
        .toList();
  }
}

class _SideQuestToggle extends StatelessWidget {
  const _SideQuestToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Side Quests: ${value ? 'ON' : 'OFF'}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _OverwhelmBanner extends StatelessWidget {
  const _OverwhelmBanner({required this.message, required this.onExit});

  final String message;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.spa),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
          TextButton(onPressed: onExit, child: const Text('Exit')),
        ],
      ),
    );
  }
}

class _EmptyBreakdownCard extends StatelessWidget {
  const _EmptyBreakdownCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('No breakdown steps yet.'),
      ),
    );
  }
}
