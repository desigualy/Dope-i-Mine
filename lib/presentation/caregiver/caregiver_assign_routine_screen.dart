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
  ConsumerState<CaregiverAssignRoutineScreen> createState() =>
      _CaregiverAssignRoutineScreenState();
}

class _CaregiverAssignRoutineScreenState
    extends ConsumerState<CaregiverAssignRoutineScreen> {
  String? _selectedUserId;
  RoutineModel? _selectedRoutine;
  final _titleController = TextEditingController();
  final _scheduleController = TextEditingController(text: 'Flexible');

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.initialUserId;
    // Routines are loaded by routineControllerProvider when the user is authenticated
  }

  @override
  void dispose() {
    _titleController.dispose();
    _scheduleController.dispose();
    super.dispose();
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
            'Which shared routine should they follow?',
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
              onChanged: (val) {
                setState(() {
                  _selectedRoutine = val;
                  if (val != null && _titleController.text.trim().isEmpty) {
                    _titleController.text = val.title;
                  }
                });
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Failed to load routines'),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey<String>('caregiver-routine-title-field'),
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Routine title',
              border: OutlineInputBorder(),
              hintText: 'e.g. Gentle morning reset',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey<String>('caregiver-routine-schedule-field'),
            controller: _scheduleController,
            decoration: const InputDecoration(
              labelText: 'Schedule',
              border: OutlineInputBorder(),
              hintText: 'e.g. Weekdays after breakfast',
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            key: const ValueKey<String>('caregiver-submit-routine-assignment'),
            onPressed: caregiverState.isLoading ||
                    _selectedUserId == null ||
                    (_selectedRoutine == null &&
                        _titleController.text.trim().isEmpty)
                ? null
                : () async {
                    final title = _titleController.text.trim().isEmpty
                        ? _selectedRoutine!.title
                        : _titleController.text.trim();
                    await ref
                        .read(caregiverControllerProvider.notifier)
                        .assignRoutine(
                          _selectedUserId!,
                          routineId: _selectedRoutine?.id,
                          routineTitle: title,
                          schedule: _scheduleController.text.trim(),
                        );
                    if (mounted) context.pop();
                  },
            child: const Text('Assign shared routine'),
          ),
          const SizedBox(height: 12),
          const Text(
            'The supported user will see this as a shared routine. They can start, pause, or complete it when ready.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
