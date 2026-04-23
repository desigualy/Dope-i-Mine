import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state_card.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';

class CaregiverAssignedRoutinesScreen extends ConsumerStatefulWidget {
  const CaregiverAssignedRoutinesScreen({super.key});

  @override
  ConsumerState<CaregiverAssignedRoutinesScreen> createState() =>
      _CaregiverAssignedRoutinesScreenState();
}

class _CaregiverAssignedRoutinesScreenState
    extends ConsumerState<CaregiverAssignedRoutinesScreen> {
  bool loading = true;
  List<Map<String, dynamic>> assigned = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser == null) return;
      final rows = await ref
          .read(caregiverAssignmentsRepositoryProvider)
          .getAssignedToUser(authUser.id);
      if (!mounted) return;
      setState(() {
        assigned = rows.map((dynamic r) {
          return <String, dynamic>{
            'id': r.id,
            'routineId': r.routineId,
            'status': r.status,
            'caregiverUserId': r.caregiverUserId,
          };
        }).toList();
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Assigned routines',
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : assigned.isEmpty
              ? const EmptyStateCard(
                  title: 'No assigned routines',
                  subtitle: 'Nothing has been assigned to you right now.',
                )
              : ListView.builder(
                  itemCount: assigned.length,
                  itemBuilder: (context, index) {
                    final item = assigned[index];
                    return ListTile(
                      title: Text('Routine ${item['routineId']}'),
                      subtitle: Text(
                        'From ${item['caregiverUserId']} · ${item['status']}',
                      ),
                    );
                  },
                ),
    );
  }
}
