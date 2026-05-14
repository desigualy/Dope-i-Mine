import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../domain/caregiver/caregiver_models.dart';
import 'caregiver_controller.dart';

class CaregiverProgressInsightsScreen extends ConsumerWidget {
  final String relationshipId;
  const CaregiverProgressInsightsScreen({super.key, required this.relationshipId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caregiverControllerProvider);
    final relationship = state.relationships.firstWhere((r) => r.id == relationshipId);

    return PrimaryScaffold(
      title: 'Progress Insights',
      actions: [
        TextButton.icon(
          onPressed: () => _exportReport(context, ref, relationship.supportedUserId),
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
          label: const Text('Export PDF'),
          style: TextButton.styleFrom(foregroundColor: Colors.teal),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _OverviewCard(relationship: relationship),
          const SizedBox(height: 24),
          const Text('Focus Heatmap (Last 7 Days)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _ProductivityHeatmap(),
          const SizedBox(height: 24),
          _RecentActivityList(userId: relationship.supportedUserId),
        ],
      ),
    );
  }

  Future<void> _exportReport(BuildContext context, WidgetRef ref, String uid) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating clinical report...')));
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
  const _OverviewCard({required this.relationship});

  @override
  Widget build(BuildContext context) {
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
              children: const [
                _Stat(label: 'Tasks Done', value: '12'),
                _Stat(label: 'Routines', value: '85%'),
                _Stat(label: 'Body Doubles', value: '5'),
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
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _ProductivityHeatmap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                .map((d) => Text(d, style: const TextStyle(fontSize: 10, color: Colors.grey)))
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
              // Mock activity density
              final double opacity = (index * 3) % 10 / 10.0;
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
                decoration: BoxDecoration(color: Colors.teal.withOpacity(o), borderRadius: BorderRadius.circular(1)),
              ))
          .toList(),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  final String userId;
  const _RecentActivityList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(height: 12),
        _ActivityItem(title: 'Morning Routine', time: 'Today, 8:15 AM', status: 'Completed'),
        _ActivityItem(title: 'Unpack Dishwasher', time: 'Yesterday, 6:00 PM', status: 'Snoozed'),
        _ActivityItem(title: 'Deep Focus Session', time: 'Yesterday, 2:00 PM', status: 'Completed'),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final String status;

  const _ActivityItem({required this.title, required this.time, required this.status});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(time),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: status == 'Completed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
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
