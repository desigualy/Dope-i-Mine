import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../domain/reminders/reminder_model.dart';
import 'reminder_controller.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState
    extends ConsumerState<ReminderSettingsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Reminders',
      child: ListView(
        children: <Widget>[
          AppTextField(
            controller: _titleController,
            hintText: 'Reminder title',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _bodyController,
            hintText: 'Reminder body',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final reminder = ReminderModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text.trim(),
                body: _bodyController.text.trim(),
                scheduledAtIso: DateTime.now().toIso8601String(),
                enabled: true,
              );
              await ref.read(reminderControllerProvider.notifier).add(reminder);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save reminder'),
          ),
        ],
      ),
    );
  }
}
