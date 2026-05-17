import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/validators/task_validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../core/widgets/state_chip_selector.dart';
import '../../domain/auth/auth_user.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import '../../providers.dart';
import '../voice/voice_input_button.dart';
import '../voice/voice_controller.dart';
import 'task_controller.dart';
import 'task_session_controller.dart';

const String _localTaskUserId = 'local_user';

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
      actions: <Widget>[
        IconButton(
          tooltip: 'Read screen aloud',
          icon: const Icon(Icons.volume_up_rounded),
          onPressed: () {
            final text = _taskController.text.trim().isNotEmpty
                ? 'Your currently typed task is: ${_taskController.text}'
                : 'What do you need to do? Type it or tap the microphone to say it, then choose your mode, energy, stress level, and available time to break it down.';
            ref.read(voiceControllerProvider).speakStep(text);
          },
        ),
      ],
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
            suffixIcon: VoiceInputButton(
              onTextChanged: (text) => _taskController.text = text,
            ),
          ),
          const SizedBox(height: 16),
          StateChipSelector<SupportMode>(
            label: 'Mode',
            values: SupportMode.values,
            selected: _mode,
            getLabel: (value) => switch (value) {
              SupportMode.adhd => 'ADHD',
              SupportMode.autism => 'Autism',
              SupportMode.audhd => 'AuDHD',
              SupportMode.executiveDysfunction => 'Executive Dysfunction',
              SupportMode.burnout => 'Burnout',
            },
            onSelected: (value) => setState(() => _mode = value),
          ),
          const SizedBox(height: 16),
          StateChipSelector<EnergyLevel>(
            label: 'Energy',
            values: EnergyLevel.values,
            selected: _energy,
            getLabel: (value) => value.name[0].toUpperCase() + value.name.substring(1),
            onSelected: (value) => setState(() => _energy = value),
          ),
          const SizedBox(height: 16),
          StateChipSelector<StressLevel>(
            label: 'Stress',
            values: StressLevel.values,
            selected: _stress,
            getLabel: (value) => value.name[0].toUpperCase() + value.name.substring(1),
            onSelected: (value) => setState(() => _stress = value),
          ),
          const SizedBox(height: 16),
          StateChipSelector<TimeAvailable>(
            label: 'Time available',
            values: TimeAvailable.values,
            selected: _time,
            getLabel: (value) => switch (value) {
              TimeAvailable.twoMinutes => '2 minutes',
              TimeAvailable.fiveMinutes => '5 minutes',
              TimeAvailable.fifteenMinutes => '15 minutes',
              TimeAvailable.thirtyPlus => '30+ minutes',
            },
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
                        ref
                            .read(taskSessionControllerProvider.notifier)
                            .reset();
                        ref
                            .read(taskControllerProvider.notifier)
                            .toggleMinimumVersion(false);
                        final userId = _resolveTaskUserId(ref);
                        await ref
                            .read(taskControllerProvider.notifier)
                            .createTask(
                              userId: userId,
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

String _resolveTaskUserId(WidgetRef ref) {
  try {
    final AuthUser? authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser != null && authUser.id.trim().isNotEmpty) {
      return authUser.id;
    }
  } catch (_) {}

  return _localTaskUserId;
}
