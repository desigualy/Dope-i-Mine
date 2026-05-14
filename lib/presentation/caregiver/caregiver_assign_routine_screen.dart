import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/caregiver/caregiver_models.dart';
import '../../domain/routines/routine_model.dart';
import '../routines/routine_controller.dart';
import 'caregiver_controller.dart';

class CaregiverAssignRoutineScreen extends ConsumerStatefulWidget {
  final String? initialUserId;
  const CaregiverAssignRoutineScreen({super.key, this.initialUserId});

  @override
  ConsumerState<CaregiverAssignRoutineScreen> createState() => _CaregiverAssignRoutineScreenState();
}

class _CaregiverAssignRoutineScreenState extends ConsumerState<CaregiverAssignRoutineScreen> {
  String? _selectedUserId;
  RoutineModel? _selectedRoutine;

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.initialUserId;
    // Routines are loaded by routineControllerProvider when the user is authenticated
  }

  @override
  Widget build(BuildContext context) {
    final caregiverState = ref.watch(caregiverControllerProvider);
    final routineState = ref.watch(routineControllerProvider);
    
    final acceptedRelationships = caregiverState.relationships
        .where((rel) => rel.status == CaregiverRelationshipStatus.accepted)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Routine')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Who needs support?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedUserId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select a linked user',
            ),
            items: acceptedRelationships.map((rel) {
              return DropdownMenuItem(
                value: rel.supportedUserId,
                child: Text(rel.supportedName ?? 'Linked User'),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedUserId = val),
          ),
          const SizedBox(height: 24),
          const Text(
            'Which routine should they follow?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          routineState.when(
            data: (routines) => DropdownButtonFormField<RoutineModel>(
              value: _selectedRoutine,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select a routine',
              ),
              items: routines.map((r) {
                return DropdownMenuItem(
                  value: r,
                  child: Text(r.title),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedRoutine = val),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Failed to load routines'),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: caregiverState.isLoading || _selectedUserId == null || _selectedRoutine == null
                ? null
                : () async {
                    await ref.read(caregiverControllerProvider.notifier).assignRoutine(
                          _selectedUserId!,
                          _selectedRoutine!.id,
                        );
                    if (mounted) context.pop();
                  },
            child: const Text('Assign Routine'),
          ),
          const SizedBox(height: 12),
          const Text(
            'The user will see this routine in their schedule and receive notifications at the agreed times.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
