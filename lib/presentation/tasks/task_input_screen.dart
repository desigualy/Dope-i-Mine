import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/validators/task_validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../core/widgets/state_chip_selector.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import '../../providers.dart';
import 'task_controller.dart';

class TaskInputScreen extends ConsumerStatefulWidget {
  const TaskInputScreen({super.key});

  @override
  ConsumerState<TaskInputScreen> createState() => _TaskInputScreenState();
}

class _TaskInputScreenState extends ConsumerState<TaskInputScreen> {
  final _taskController = TextEditingController();
  SupportMode _mode = SupportMode.audhd;
  EnergyLevel _energy = EnergyLevel.medium;
  StressLevel _stress = StressLevel.friction;
  TimeAvailable _time = TimeAvailable.fifteenMinutes;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskControllerProvider);

    return PrimaryScaffold(
      title: 'New task',
      child: ListView(
        children: <Widget>[
          if (_errorText != null) ...<Widget>[
            ErrorBanner(message: _errorText!),
            const SizedBox(height: 12),
          ],
          AppTextField(
            controller: _taskController,
            hintText: 'What do you need to do?',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          StateChipSelector<SupportMode>(
            label: 'Mode',
            values: SupportMode.values,
            selected: _mode,
            getLabel: (value) => value.name,
            onSelected: (value) => setState(() => _mode = value),
          ),
          const SizedBox(height: 16),
          StateChipSelector<EnergyLevel>(
            label: 'Energy',
            values: EnergyLevel.values,
            selected: _energy,
            getLabel: (value) => value.name,
            onSelected: (value) => setState(() => _energy = value),
          ),
          const SizedBox(height: 16),
          StateChipSelector<StressLevel>(
            label: 'Stress',
            values: StressLevel.values,
            selected: _stress,
            getLabel: (value) => value.name,
            onSelected: (value) => setState(() => _stress = value),
          ),
          const SizedBox(height: 16),
          StateChipSelector<TimeAvailable>(
            label: 'Time available',
            values: TimeAvailable.values,
            selected: _time,
            getLabel: (value) => value.name,
            onSelected: (value) => setState(() => _time = value),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.loading
                  ? null
                  : () async {
                      setState(() => _errorText = null);
                      try {
                        validateTaskText(_taskController.text);
                        final authUser =
                            ref.read(authRepositoryProvider).getCurrentUser();
                        debugPrint('Current user: $authUser');
                        if (authUser == null) {
                          throw Exception('Not authenticated');
                        }
                        await ref.read(taskControllerProvider.notifier).createTask(
                              userId: authUser.id,
                              sourceText: _taskController.text.trim(),
                              snapshot: TaskStateSnapshot(
                                mode: _mode,
                                energyLevel: _energy,
                                stressLevel: _stress,
                                timeAvailable: _time,
                              ),
                            );
                        if (mounted) context.go('/tasks/breakdown');
                      } catch (error) {
                        debugPrint('Task creation error: $error');
                        setState(() {
                          _errorText = mapToUserFacingError(error);
                        });
                      }
                    },
              child: Text(state.loading ? 'Creating...' : 'Break task down'),
            ),
          ),
        ],
      ),
    );
  }
}
