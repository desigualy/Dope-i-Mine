import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state_card.dart';
import '../../domain/sidequests/side_quest_model.dart';
import '../../providers.dart';
import '../core/controllers/avatar_controller.dart';
import '../core/widgets/dopei_avatar.dart';
import '../overwhelm/overwhelm_controller.dart';
import '../rewards/reward_controller.dart';
import '../tasks/task_controller.dart';
import '../tasks/widgets/side_quest_card.dart';
import 'side_quest_controller.dart';

class SideQuestPanel extends ConsumerStatefulWidget {
  const SideQuestPanel({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<SideQuestPanel> createState() => _SideQuestPanelState();
}

class _SideQuestPanelState extends ConsumerState<SideQuestPanel> {
  final Map<String, DateTime> _countdownDeadlines = <String, DateTime>{};
  final Set<String> _shownPopupKeys = <String>{};
  bool _popupOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser != null) {
        ref.read(sideQuestControllerProvider.notifier).loadForTask(
              userId: authUser.id,
              taskId: widget.taskId,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskControllerProvider);
    final sideQuestState = ref.watch(sideQuestControllerProvider);
    final overwhelmState = ref.watch(overwhelmControllerProvider);

    if (!taskState.showSideQuests) {
      return const SizedBox.shrink();
    }

    // Prioritize side quests from the task creation result if the ID matches
    final List<SideQuestModel> questsToShow =
        (taskState.task?.id == widget.taskId && taskState.sideQuests.isNotEmpty)
            ? taskState.sideQuests
            : sideQuestState.maybeWhen(
                data: (quests) => quests,
                orElse: () => <SideQuestModel>[],
              );

    if (questsToShow.isEmpty) {
      return sideQuestState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyStateCard(
          title: 'No side quests right now',
          subtitle: 'The main task is enough. Keep going.',
        ),
        data: (_) => const EmptyStateCard(
          title: 'No side quests right now',
          subtitle: 'The main task is enough. Keep going.',
        ),
      );
    }

    _maybeShowSideQuestPopup(
      context: context,
      quest: _selectPopupQuest(
        questsToShow,
        taskState: taskState,
        isOverwhelmed: overwhelmState.isActive,
      ),
      taskState: taskState,
      isOverwhelmed: overwhelmState.isActive,
    );

    return Column(
      children: questsToShow.map((quest) {
        final isCompleted = quest.status == 'completed';
        final deadline = _deadlineFor(
          quest,
          taskState: taskState,
          isOverwhelmed: overwhelmState.isActive,
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SideQuestCard(
            title: quest.title,
            rewardText: '+${quest.rewardXp} XP',
            isCompleted: isCompleted,
            countdownEndsAt: isCompleted ? null : deadline,
            contextLabel: _contextLabelFor(
              quest,
              taskState: taskState,
              isOverwhelmed: overwhelmState.isActive,
            ),
            onComplete: isCompleted
                ? null
                : () => _completeQuest(quest),
          ),
        );
      }).toList(),
    );
  }

  void _maybeShowSideQuestPopup({
    required BuildContext context,
    required SideQuestModel? quest,
    required TaskViewState taskState,
    required bool isOverwhelmed,
  }) {
    if (quest == null || quest.status == 'completed' || _popupOpen) return;

    final popupKey = _popupKey(quest, taskState, isOverwhelmed);
    if (_shownPopupKeys.contains(popupKey)) return;

    _shownPopupKeys.add(popupKey);
    _popupOpen = true;

    final deadline = _deadlineFor(
      quest,
      taskState: taskState,
      isOverwhelmed: isOverwhelmed,
    );
    final contextLabel = _contextLabelFor(
      quest,
      taskState: taskState,
      isOverwhelmed: isOverwhelmed,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !context.mounted) {
        _popupOpen = false;
        return;
      }

      showDialog<void>(
        context: context,
        builder: (dialogContext) => _SideQuestPopup(
          quest: quest,
          countdownEndsAt: deadline,
          contextLabel: contextLabel,
          onComplete: () async {
            await _completeQuest(quest);
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
        ),
      ).whenComplete(() {
        if (mounted) {
          setState(() => _popupOpen = false);
        } else {
          _popupOpen = false;
        }
      });
    });
  }

  Future<void> _completeQuest(SideQuestModel quest) async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return;

    ref.read(avatarControllerProvider.notifier).setMood(DopeiMood.happy);

    try {
      await ref.read(sideQuestRepositoryProvider).complete(
            userId: authUser.id,
            sideQuestId: quest.id,
          );
    } catch (error) {
      debugPrint('Warning: Could not complete side quest remotely: $error');
    }

    ref
        .read(taskControllerProvider.notifier)
        .updateSideQuestStatus(quest.id, 'completed');
    ref.read(rewardControllerProvider.notifier).refreshStats(authUser.id);
    await ref.read(sideQuestControllerProvider.notifier).loadForTask(
          userId: authUser.id,
          taskId: widget.taskId,
        );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (ref.read(avatarControllerProvider).mood == DopeiMood.happy) {
        ref.read(avatarControllerProvider.notifier).setMood(DopeiMood.focused);
      }
    });
  }

  SideQuestModel? _selectPopupQuest(
    List<SideQuestModel> quests, {
    required TaskViewState taskState,
    required bool isOverwhelmed,
  }) {
    final available = quests
        .where((quest) => quest.status != 'completed')
        .toList(growable: false);
    if (available.isEmpty) return null;

    if (isOverwhelmed) {
      return _firstQuestOfType(
            available,
            <String>['care', 'sensory', 'reset', 'momentum'],
          ) ??
          available.first;
    }

    switch (_intensityFor(taskState)) {
      case _TaskIntensity.high:
        return _firstQuestOfType(
              available,
              <String>['momentum', 'reset', 'future_you', 'care'],
            ) ??
            available.first;
      case _TaskIntensity.medium:
        return available.length > 1 ? available[1] : available.first;
      case _TaskIntensity.low:
        return available.first;
    }
  }

  SideQuestModel? _firstQuestOfType(
    List<SideQuestModel> quests,
    List<String> preferredTypes,
  ) {
    for (final type in preferredTypes) {
      for (final quest in quests) {
        if (quest.questType == type) return quest;
      }
    }
    return null;
  }

  DateTime _deadlineFor(
    SideQuestModel quest, {
    required TaskViewState taskState,
    required bool isOverwhelmed,
  }) {
    final key = '${widget.taskId}:${quest.id}:${_intensityFor(taskState).name}:$isOverwhelmed';
    return _countdownDeadlines.putIfAbsent(
      key,
      () => DateTime.now().add(_countdownDurationFor(taskState, isOverwhelmed)),
    );
  }

  Duration _countdownDurationFor(
    TaskViewState taskState,
    bool isOverwhelmed,
  ) {
    if (isOverwhelmed) return const Duration(minutes: 2);
    switch (_intensityFor(taskState)) {
      case _TaskIntensity.high:
        return const Duration(minutes: 4);
      case _TaskIntensity.medium:
        return const Duration(minutes: 3);
      case _TaskIntensity.low:
        return const Duration(minutes: 2);
    }
  }

  String _contextLabelFor(
    SideQuestModel quest, {
    required TaskViewState taskState,
    required bool isOverwhelmed,
  }) {
    if (isOverwhelmed) {
      return 'Overwhelm boost: tiny optional win after a breakdown chunk';
    }
    switch (_intensityFor(taskState)) {
      case _TaskIntensity.high:
        return 'High-intensity task: quick momentum side quest';
      case _TaskIntensity.medium:
        return 'Medium task: bonus focus boost';
      case _TaskIntensity.low:
        return 'Light task: tiny extra sparkle';
    }
  }

  String _popupKey(
    SideQuestModel quest,
    TaskViewState taskState,
    bool isOverwhelmed,
  ) {
    return '${widget.taskId}:${quest.id}:${_intensityFor(taskState).name}:$isOverwhelmed';
  }

  _TaskIntensity _intensityFor(TaskViewState taskState) {
    final effortBand = taskState.task?.effortBand.toLowerCase();
    final estimatedMinutes = taskState.task?.estimatedMinutes ?? 0;
    final stepCount = taskState.steps.where((step) => step.depthLevel > 0).length;

    if (effortBand == 'high' || estimatedMinutes >= 45 || stepCount > 24) {
      return _TaskIntensity.high;
    }
    if (effortBand == 'medium' || estimatedMinutes >= 15 || stepCount > 8) {
      return _TaskIntensity.medium;
    }
    return _TaskIntensity.low;
  }
}

enum _TaskIntensity { low, medium, high }

class _SideQuestPopup extends StatelessWidget {
  const _SideQuestPopup({
    required this.quest,
    required this.countdownEndsAt,
    required this.contextLabel,
    required this.onComplete,
  });

  final SideQuestModel quest;
  final DateTime countdownEndsAt;
  final String contextLabel;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.bolt_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('Side quest popped up'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Optional tiny win. It is timed to add momentum, not pressure.',
          ),
          const SizedBox(height: 12),
          SideQuestCard(
            title: quest.title,
            rewardText: '+${quest.rewardXp} XP',
            countdownEndsAt: countdownEndsAt,
            contextLabel: contextLabel,
            onComplete: onComplete,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Not now'),
        ),
      ],
    );
  }
}
