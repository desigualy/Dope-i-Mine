import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/list_utils.dart';
import '../../core/utils/step_utils.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import '../../domain/tasks/task_step_model.dart';
import '../../providers.dart';
import '../overwhelm/overwhelm_support_sheet.dart';
import 'task_controller.dart';
import 'task_session_controller.dart';
import 'widgets/minimum_version_toggle.dart';
import 'widgets/step_card.dart';
import '../sidequests/side_quest_panel.dart';
import '../rewards/reward_controller.dart';
import '../rewards/widgets/xp_bar.dart';

class TaskBreakdownScreen extends ConsumerWidget {
  const TaskBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskControllerProvider);
    final session = ref.watch(taskSessionControllerProvider);
    final rewardState = ref.watch(rewardControllerProvider);

    // Load stats once if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser != null && rewardState is AsyncLoading) {
        ref.read(rewardControllerProvider.notifier).loadStats(authUser.id);
      }
    });

    List<TaskStepModel> visibleSteps =
        state.showMinimumVersion ? state.minimumVersion : state.steps;

    if (session.showOnlyCurrentStep && visibleSteps.isNotEmpty) {
      final idx = safeStepIndex(session.currentStepIndex, visibleSteps.length);
      visibleSteps = <TaskStepModel>[visibleSteps[idx]];
    }

    // Check if all steps are completed (check against full list, not filtered visible steps)
    final allStepsCompletedSteps = state.showMinimumVersion ? state.minimumVersion : state.steps;
    final allStepsCompleted = allStepsCompletedSteps.isNotEmpty &&
        allStepsCompletedSteps.every((step) => step.status == StepStatus.completed);
    
    debugPrint('>>> TaskBreakdownScreen: allStepsCompleted=$allStepsCompleted, totalSteps=${allStepsCompletedSteps.length}, completed=${allStepsCompletedSteps.where((s) => s.status == StepStatus.completed).length}');
    debugPrint('>>> TaskBreakdownScreen: steps=${state.steps.map((s) => s.text).toList()}');
    debugPrint('>>> TaskBreakdownScreen: minimumVersion=${state.minimumVersion.map((s) => s.text).toList()}');

    return Scaffold(
      appBar: AppBar(
        title: Text(state.task?.normalizedTitle ?? 'Task breakdown'),
        actions: <Widget>[
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
              MinimumVersionToggle(
                value: state.showMinimumVersion,
                onChanged: (value) {
                  ref.read(taskControllerProvider.notifier).toggleMinimumVersion(value);
                },
              ),
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () =>
                        ref.read(taskSessionControllerProvider.notifier).pause(),
                    child: const Text('Pause'),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(taskSessionControllerProvider.notifier).resume(),
                    child: const Text('Resume'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: visibleSteps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final step = visibleSteps[index];
                    return StepCard(
                      step: step,
                      onBreakDownMore: () async {
                        final snapshot = state.task?.stateSnapshot ??
                            TaskStateSnapshot(
                              mode: SupportMode.audhd,
                              energyLevel: EnergyLevel.medium,
                              stressLevel: StressLevel.friction,
                              timeAvailable: TimeAvailable.fifteenMinutes,
                            );

                        final substeps =
                            await ref.read(taskRepositoryProvider).breakDownStep(
                                  stepId: step.id,
                                  snapshot: snapshot,
                                  stepText: step.text,
                                );

                        ref.read(taskControllerProvider.notifier).replaceStepWithSubsteps(
                              stepId: step.id,
                              substeps: substeps,
                              isMinimumVersion: state.showMinimumVersion,
                            );
                      },
                      onComplete: () async {
                        debugPrint('>>> Completing step: ${step.id}, current status: ${step.status}');
                        final authUser =
                            ref.read(authRepositoryProvider).getCurrentUser();
                        if (authUser == null) return;
                        await ref.read(taskRepositoryProvider).completeStep(
                              userId: authUser.id,
                              stepId: step.id,
                            );
                        // Update local state to reflect completion
                        ref.read(taskControllerProvider.notifier).updateStepCompletion(
                              step.id,
                              'completed',
                            );
                        
                        // Refresh rewards
                        ref.read(rewardControllerProvider.notifier).refreshStats(authUser.id);

                        final updatedState = ref.read(taskControllerProvider);
                        debugPrint('>>> After completion, step status: ${updatedState.steps.firstWhere((s) => s.id == step.id, orElse: () => step).status}');
                        debugPrint('>>> Total steps: ${updatedState.steps.length}, Completed: ${updatedState.steps.where((s) => s.status == StepStatus.completed).length}');
                        ref.read(taskSessionControllerProvider.notifier).nextStep();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Manual button to finish and move to summary (only if all steps complete)
              if (allStepsCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/tasks/summary'),
                    child: const Text('View Summary & Continue'),
                  ),
                ),
              const SizedBox(height: 24),
              if (state.task?.id != null) ...<Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.auto_awesome, size: 18, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Side Quests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SideQuestPanel(taskId: state.task!.id),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
