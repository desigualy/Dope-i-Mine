import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/color_tokens.dart';
import '../../../data/local/local_task_store.dart';

class TodaysTasksCard extends ConsumerStatefulWidget {
  const TodaysTasksCard({super.key});

  @override
  ConsumerState<TodaysTasksCard> createState() => _TodaysTasksCardState();
}

class _TodaysTasksCardState extends ConsumerState<TodaysTasksCard> {
  late Future<List> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = ref.read(localTaskStoreProvider).loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey<String>('home-today-summary'),
      elevation: 0,
      color: ColorTokens.homeSurface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: ColorTokens.homePromptCard),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: FutureBuilder<List>(
          future: _tasksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 36,
                child: Center(child: LinearProgressIndicator()),
              );
            }

            final tasks = snapshot.data ?? <dynamic>[];
            final count = tasks.length;
            final previewTitle = count == 0
                ? 'No tasks yet'
                : tasks.first['normalizedTitle'] as String? ?? 'Task';

            return Row(
              children: <Widget>[
                const Icon(
                  Icons.today_rounded,
                  color: ColorTokens.homeSubtext,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Today',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: ColorTokens.homeText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count == 0
                            ? previewTitle
                            : '$previewTitle + $count total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ColorTokens.homeSubtext,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (count > 0)
                  TextButton(
                    onPressed: () => context.go('/tasks/summary'),
                    child: const Text(
                      'View',
                      style: TextStyle(color: ColorTokens.homeSubtext),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
