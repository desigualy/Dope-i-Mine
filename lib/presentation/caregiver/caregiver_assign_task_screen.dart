import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/caregiver/caregiver_models.dart';
import 'caregiver_controller.dart';

class CaregiverAssignTaskScreen extends ConsumerStatefulWidget {
  final String? initialUserId;
  const CaregiverAssignTaskScreen({super.key, this.initialUserId});

  @override
  ConsumerState<CaregiverAssignTaskScreen> createState() => _CaregiverAssignTaskScreenState();
}

class _CaregiverAssignTaskScreenState extends ConsumerState<CaregiverAssignTaskScreen> {
  final _titleController = TextEditingController();
  final List<TextEditingController> _stepControllers = [];
  String? _selectedUserId;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.initialUserId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() => _stepControllers.add(TextEditingController()));
  }

  void _removeStep(int index) {
    _stepControllers[index].dispose();
    setState(() => _stepControllers.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caregiverControllerProvider);
    final acceptedRelationships = state.relationships
        .where((rel) => rel.status == CaregiverRelationshipStatus.accepted)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Task')),
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
            'What is the task?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(),
              hintText: 'e.g. Unpack the dishwasher',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Task Steps (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Step'),
              ),
            ],
          ),
          ..._stepControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Step ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () => _removeStep(index),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          const Text(
            'When should it be done?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: Text(_dueDate == null ? 'Set a deadline (Optional)' : _dueDate.toString()),
            trailing: const Icon(Icons.calendar_today_rounded),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade700),
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _dueDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            },
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: state.isLoading || _selectedUserId == null || _titleController.text.isEmpty
                ? null
                : () async {
                    final steps = _stepControllers
                        .map((c) => c.text.trim())
                        .where((t) => t.isNotEmpty)
                        .toList();
                    await ref.read(caregiverControllerProvider.notifier).assignTask(
                          _selectedUserId!,
                          _titleController.text.trim(),
                          steps: steps.isEmpty ? null : steps,
                          due: _dueDate,
                        );
                    if (mounted) context.pop();
                  },
            child: const Text('Send Task Suggestion'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Adults will receive this as a suggestion. They can choose to accept or snooze it.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
