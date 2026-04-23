import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state_card.dart';
import '../../providers.dart';
import '../tasks/widgets/side_quest_card.dart';
import 'side_quest_controller.dart';

class SideQuestPanel extends ConsumerStatefulWidget {
  const SideQuestPanel({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<SideQuestPanel> createState() => _SideQuestPanelState();
}

class _SideQuestPanelState extends ConsumerState<SideQuestPanel> {
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
    final state = ref.watch(sideQuestControllerProvider);
    final repo = ref.read(sideQuestRepositoryProvider);
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();

    return state.when(
      data: (quests) {
        if (quests.isEmpty) {
          return const EmptyStateCard(
            title: 'No side quests right now',
            subtitle: 'The main task is enough. Keep going.',
          );
        }
        return Column(
          children: quests.map((quest) {
            return Card(
              child: Column(
                children: <Widget>[
                  SideQuestCard(
                    title: quest.title,
                    rewardText: '+${quest.rewardXp} XP',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'accept') {
                        await repo.accept(quest.id);
                      }
                      if (value == 'dismiss') {
                        await repo.dismiss(quest.id);
                      }
                      if (value == 'complete' && authUser != null) {
                        await repo.complete(
                          userId: authUser.id,
                          sideQuestId: quest.id,
                        );
                      }
                      if (authUser != null) {
                        await ref.read(sideQuestControllerProvider.notifier).loadForTask(
                              userId: authUser.id,
                              taskId: widget.taskId,
                            );
                      }
                    },
                    itemBuilder: (_) => const <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(value: 'accept', child: Text('Accept')),
                      PopupMenuItem<String>(value: 'complete', child: Text('Complete')),
                      PopupMenuItem<String>(value: 'dismiss', child: Text('Dismiss')),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const EmptyStateCard(
        title: 'Could not load side quests',
        subtitle: 'You can continue without them.',
      ),
    );
  }
}
