import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/caregiver_repository.dart';
import '../../domain/body_double/body_double_session.dart';
import '../../domain/caregiver/caregiver_models.dart';
import 'caregiver_controller.dart';

class LinkedUserDetailScreen extends ConsumerWidget {
  final String relationshipId;
  const LinkedUserDetailScreen({super.key, required this.relationshipId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caregiverControllerProvider);
    final relationship = state.relationships.firstWhere((r) => r.id == relationshipId);
    
    final tasks = state.assignedTasks.where((t) => t.targetUserId == relationship.supportedUserId).toList();
    final routines = state.assignedRoutines.where((r) => r.targetUserId == relationship.supportedUserId).toList();
    
    // We'll assume alerts are part of the state or we fetch them here
    // For now, I'll add a placeholder or a separate provider
    
    return Scaffold(
      appBar: AppBar(
        title: Text(relationship.supportedName ?? 'User Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            onPressed: () => context.push('/caregiver/insights/$relationshipId'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/caregiver/permissions/$relationshipId'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _UserSummaryHeader(relationship: relationship),
          const SizedBox(height: 24),
          _ActionGrid(relationship: relationship),
          const SizedBox(height: 32),
          Text('Recent Alerts', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.orange)),
          const SizedBox(height: 12),
          _AlertList(relationshipId: relationshipId),
          const SizedBox(height: 32),
          Text('Body Double History', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _BodyDoubleHistoryList(userId: relationship.supportedUserId),
          const SizedBox(height: 32),
          Text('Active Assignments', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (tasks.isEmpty && routines.isEmpty)
            const Text('No active assignments for this user.', style: TextStyle(color: Colors.grey)),
          ...tasks.map((t) => _AssignmentTile(title: t.taskTitle ?? 'Task', status: t.status.name, icon: Icons.task_alt_rounded)),
          ...routines.map((r) => _AssignmentTile(title: r.routineTitle ?? 'Routine', status: r.status, icon: Icons.repeat_rounded)),
        ],
      ),
    );
  }
}

class _UserSummaryHeader extends StatelessWidget {
  final CaregiverRelationship relationship;
  const _UserSummaryHeader({required this.relationship});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, child: Icon(Icons.person_rounded, size: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  relationship.supportedName ?? 'Unknown User',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Role: ${relationship.role.name.toUpperCase()}',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends ConsumerWidget {
  final CaregiverRelationship relationship;
  const _ActionGrid({required this.relationship});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _ActionButton(
          label: 'Assign Task',
          icon: Icons.add_task_rounded,
          color: Colors.blue,
          onTap: () => context.push('/caregiver/assign-task?uid=${relationship.supportedUserId}'),
        ),
        _ActionButton(
          label: 'Assign Routine',
          icon: Icons.playlist_add_rounded,
          color: Colors.teal,
          onTap: () => context.push('/caregiver/assign-routine?uid=${relationship.supportedUserId}'),
        ),
        _ActionButton(
          label: 'Suggest Side Quest',
          icon: Icons.auto_awesome_rounded,
          color: Colors.pink,
          onTap: () => _showSideQuestDialog(context, ref, relationship.supportedUserId),
        ),
        _ActionButton(
          label: 'Body Double',
          icon: Icons.people_rounded,
          color: Colors.purple,
          onTap: () => _showBodyDoubleInviteDialog(context, ref, relationship.supportedUserId),
        ),
        _ActionButton(
          label: 'Send Nudge',
          icon: Icons.waving_hand_rounded,
          color: Colors.orange,
          onTap: () => _showNudgeDialog(context, ref, relationship.id, relationship.supportedUserId),
        ),
      ],
    );
  }

  void _showBodyDoubleInviteDialog(BuildContext context, WidgetRef ref, String uid) {
    final categories = ['Chores', 'Admin', 'Work', 'Study', 'Personal'];
    String selectedCategory = categories.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Invite to Body Double'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Start a shared focus session.'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setDialogState(() => selectedCategory = val!),
                decoration: const InputDecoration(labelText: 'Task Category'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                ref.read(caregiverControllerProvider.notifier).inviteToBodyDouble(uid, selectedCategory);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Body double invitation sent!')));
              },
              child: const Text('Invite'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSideQuestDialog(BuildContext context, WidgetRef ref, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suggest Side Quest'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Try a 5-min stretch'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(caregiverControllerProvider.notifier).suggestSideQuest(uid, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Suggest'),
          ),
        ],
      ),
    );
  }

  void _showNudgeDialog(BuildContext context, WidgetRef ref, String relId, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Nudge'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. You got this!'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(caregiverControllerProvider.notifier).sendNudge(relId, uid, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;

  const _AssignmentTile({required this.title, required this.status, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title),
      subtitle: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 16),
    );
  }
}

class _AlertList extends ConsumerWidget {
  final String relationshipId;
  const _AlertList({required this.relationshipId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<CaregiverAlert>>(
      future: ref.read(caregiverRepositoryProvider).loadAlerts(relationshipId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }
        final alerts = snapshot.data ?? [];
        if (alerts.isEmpty) {
          return Card(
            color: Colors.orange.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.orange.withOpacity(0.2)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.notification_important_rounded, color: Colors.orange),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'No critical alerts in the last 24 hours.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: alerts.map((alert) => _AlertTile(alert: alert)).toList(),
        );
      },
    );
  }
}

class _AlertTile extends StatelessWidget {
  final CaregiverAlert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final severity = alert.severity;
    final alertType = alert.alertType;
    final color = severity == 'critical' ? Colors.red : Colors.orange;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: Icon(
          alertType == 'safety_report' ? Icons.shield_rounded : Icons.warning_rounded,
          color: color,
        ),
        title: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: alert.body != null ? Text(alert.body!, style: const TextStyle(fontSize: 12)) : null,
        trailing: Text(
          '${DateTime.now().difference(alert.createdAt).inMinutes}m ago',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ),
    );
  }
}

class _BodyDoubleHistoryList extends ConsumerWidget {
  final String userId;
  const _BodyDoubleHistoryList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<BodyDoubleSession>>(
      future: ref.read(caregiverRepositoryProvider).loadBodyDoubleSummaries(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        final sessions = snapshot.data ?? [];
        if (sessions.isEmpty) {
          return const Text('No recent session history.', style: TextStyle(fontSize: 12, color: Colors.grey));
        }
        return Column(
          children: sessions.map((s) => _HistoryTile(session: s)).toList(),
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final BodyDoubleSession session;
  const _HistoryTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history_rounded, size: 20),
      title: Text(session.taskTitle ?? session.sessionType.label),
      subtitle: Text('Completed on ${session.startedAt.day}/${session.startedAt.month}'),
      trailing: const Icon(Icons.chevron_right_rounded, size: 16),
    );
  }
}
