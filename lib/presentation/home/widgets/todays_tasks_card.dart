import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<List>(
          future: _tasksFuture,
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? <dynamic>[];
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(height: 72, child: Center(child: CircularProgressIndicator()));
            }

            if (tasks.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Today\'s tasks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('No tasks yet. Start with one small thing.'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => context.go('/tasks/new'), child: const Text('Add a task')),
                ],
              );
            }

            final preview = tasks.take(3).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today\'s tasks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...preview.map((t) => ListTile(
                      title: Text(t['normalizedTitle'] as String? ?? 'Task'),
                      subtitle: Text('Est. ${t['estimatedMinutes'] ?? 15} min'),
                      onTap: () => context.go('/tasks/summary'),
                    )),
                const SizedBox(height: 8),
                Text('${tasks.length} total', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                TextButton(onPressed: () => context.go('/tasks/summary'), child: const Text('View all tasks')),
              ],
            );
          },
        ),
      ),
    );
  }
}
