import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../domain/caregiver/caregiver_models.dart';
import 'caregiver_controller.dart';

class CaregiverProgressInsightsScreen extends ConsumerWidget {
  final String relationshipId;
  const CaregiverProgressInsightsScreen(
      {super.key, required this.relationshipId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caregiverControllerProvider);
    final relationship =
        state.relationships.firstWhere((r) => r.id == relationshipId);
    final tasks = state.assignedTasks
        .where((task) => task.targetUserId == relationship.supportedUserId)
        .toList();
    final routines = state.assignedRoutines
        .where(
            (routine) => routine.targetUserId == relationship.supportedUserId)
        .toList();

    return PrimaryScaffold(
      title: 'Progress Insights',
      actions: [
        TextButton.icon(
          onPressed: () =>
              _exportReport(context, ref, relationship.supportedUserId),
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
          label: const Text('Export PDF'),
          style: TextButton.styleFrom(foregroundColor: Colors.teal),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _OverviewCard(
            relationship: relationship,
            tasks: tasks,
            routines: routines,
          ),
          const SizedBox(height: 24),
          const Text('Focus Heatmap (Last 7 Days)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _ProductivityHeatmap(tasks: tasks, routines: routines),
          const SizedBox(height: 24),
          _RecentActivityList(tasks: tasks, routines: routines),
        ],
      ),
    );
  }

  Future<void> _exportReport(
      BuildContext context, WidgetRef ref, String uid) async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating clinical report...')));
    await ref.read(caregiverRepositoryProvider).exportProgressReport(uid);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Report ready for download'),
        action: SnackBarAction(label: 'Download', onPressed: () {}),
      ));
    }
  }
}

class _OverviewCard extends StatelessWidget {
  final CaregiverRelationship relationship;
  final List<CaregiverAssignedTask> tasks;
  final List<CaregiverAssignedRoutine> routines;
  const _OverviewCard({
    required this.relationship,
    required this.tasks,
    required this.routines,
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks
        .where((task) => task.status == CaregiverTaskStatus.completed)
        .length;
    final completedRoutines = routines
        .where((routine) => routine.status == CaregiverRoutineStatus.completed)
        .length;
    final routinePercent = routines.isEmpty
        ? '—'
        : '${((completedRoutines / routines.length) * 100).round()}%';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              relationship.supportedName ?? 'User',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(label: 'Tasks Done', value: completedTasks.toString()),
                _Stat(label: 'Routines', value: routinePercent),
                _Stat(
                    label: 'Active Shares', value: routines.length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _ProductivityHeatmap extends StatelessWidget {
  const _ProductivityHeatmap({required this.tasks, required this.routines});

  final List<CaregiverAssignedTask> tasks;
  final List<CaregiverAssignedRoutine> routines;

  @override
  Widget build(BuildContext context) {
    final densities = _buildActivityDensities(tasks, routines);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Text(d,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 28, // 7 days * 4 time blocks
            itemBuilder: (context, index) {
              final double opacity = densities[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(opacity.clamp(0.1, 1.0)),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: TextStyle(fontSize: 10, color: Colors.grey)),
              SizedBox(width: 4),
              _HeatmapKey(),
              SizedBox(width: 4),
              Text('More', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  List<double> _buildActivityDensities(
    List<CaregiverAssignedTask> tasks,
    List<CaregiverAssignedRoutine> routines,
  ) {
    final counts = List<int>.filled(28, 0);
    final now = DateTime.now();

    void addActivity(DateTime timestamp) {
      final age = now.difference(timestamp);
      if (age.isNegative || age.inDays >= 7) return;
      final dayIndex = 6 - age.inDays;
      final blockIndex = (timestamp.hour / 6).floor().clamp(0, 3);
      counts[(blockIndex * 7) + dayIndex]++;
    }

    for (final task in tasks) {
      addActivity(task.updatedAt);
      if (task.completedAt != null) addActivity(task.completedAt!);
    }
    for (final routine in routines) {
      addActivity(routine.updatedAt);
      if (routine.completedAt != null) addActivity(routine.completedAt!);
    }

    final maxCount =
        counts.fold<int>(0, (max, value) => value > max ? value : max);
    if (maxCount == 0) return List<double>.filled(28, 0.1);
    return counts.map((count) => 0.1 + (count / maxCount) * 0.9).toList();
  }
}

class _HeatmapKey extends StatelessWidget {
  const _HeatmapKey();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [0.2, 0.5, 0.8]
          .map((o) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(o),
                    borderRadius: BorderRadius.circular(1)),
              ))
          .toList(),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.tasks, required this.routines});

  final List<CaregiverAssignedTask> tasks;
  final List<CaregiverAssignedRoutine> routines;

  @override
  Widget build(BuildContext context) {
    final activities = <_ActivitySummary>[
      ...tasks.map((task) => _ActivitySummary(
            title: task.taskTitle,
            timestamp: task.updatedAt,
            status: task.status.name,
          )),
      ...routines.map((routine) => _ActivitySummary(
            title: routine.routineTitle,
            timestamp: routine.updatedAt,
            status: routine.status.name,
          )),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Activity',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          const Text('No shared task or routine activity yet.')
        else
          ...activities.take(5).map((activity) => _ActivityItem(
                title: activity.title,
                time: _relativeTime(activity.timestamp),
                status: activity.status,
              )),
      ],
    );
  }

  String _relativeTime(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes} min ago';
    if (difference.inDays < 1) return '${difference.inHours} hr ago';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays} days ago';
  }
}

class _ActivitySummary {
  const _ActivitySummary({
    required this.title,
    required this.timestamp,
    required this.status,
  });

  final String title;
  final DateTime timestamp;
  final String status;
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final String status;

  const _ActivityItem(
      {required this.title, required this.time, required this.status});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(time),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: status == 'Completed'
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 10,
            color: status == 'Completed' ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
