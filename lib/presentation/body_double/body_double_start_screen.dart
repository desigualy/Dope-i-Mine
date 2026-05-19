import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_back_button.dart';
import '../../domain/body_double/body_double_session.dart';
import '../tasks/task_controller.dart';
import '../voice/voice_controller.dart';
import 'body_double_controller.dart';

class BodyDoubleStartScreen extends ConsumerStatefulWidget {
  const BodyDoubleStartScreen({super.key});

  @override
  ConsumerState<BodyDoubleStartScreen> createState() =>
      _BodyDoubleStartScreenState();
}

class _BodyDoubleStartScreenState extends ConsumerState<BodyDoubleStartScreen> {
  BodyDoubleSessionType _type = BodyDoubleSessionType.quickStart;
  bool _quietMode = true;
  bool _textOnlyMode = false;
  bool _voiceEnabled = false;

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskControllerProvider);
    final taskTitle = taskState.task?.normalizedTitle ?? 'your task';
    final firstStep = taskState.steps
        .where((step) => step.depthLevel > 0)
        .map((step) => step.text)
        .cast<String?>()
        .firstWhere((text) => text != null, orElse: () => null);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Start body double'),
        actions: [
          IconButton(
            tooltip: 'Read screen aloud',
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () {
              final text = 'Start body double. Work alongside Dope-i quietly. '
                  'No pressure. No performance. Just presence for $taskTitle. '
                  'Phase 3A is Dope-i only: no friend or random matching yet.';
              ref.read(voiceControllerProvider).speakStep(text);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Work alongside Dope-i, quietly.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pressure. No performance. Just presence for $taskTitle.',
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Phase 3A supports Dope-i body doubling only. Friend invites '
                'and random matching stay hidden until later safety and consent '
                'phases are ready.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...BodyDoubleSessionType.values.map(
            (type) => RadioListTile<BodyDoubleSessionType>(
              value: type,
              groupValue: _type,
              title: Text(type.label),
              subtitle: Text(type.description),
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Quiet mode'),
            subtitle: const Text('Dope-i stays calm and low-interruption.'),
            value: _quietMode,
            onChanged: (value) => setState(() => _quietMode = value),
          ),
          SwitchListTile(
            title: const Text('Text-only mode'),
            subtitle: const Text('No voice prompts during this session.'),
            value: _textOnlyMode,
            onChanged: (value) => setState(() => _textOnlyMode = value),
          ),
          SwitchListTile(
            title: const Text('Voice read-aloud available'),
            subtitle: const Text('You can tap Speak step during the session.'),
            value: _voiceEnabled,
            onChanged: _textOnlyMode
                ? null
                : (value) => setState(() => _voiceEnabled = value),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey<String>('start-dopei-body-double-button'),
            onPressed: () async {
              await ref
                  .read(bodyDoubleControllerProvider.notifier)
                  .startDopeiSession(
                    sessionType: _type,
                    taskId: taskState.task?.id,
                    taskTitle: taskState.task?.normalizedTitle,
                    goal: 'Stay alongside the next step calmly.',
                    quietMode: _quietMode,
                    textOnlyMode: _textOnlyMode,
                    voiceEnabled: _voiceEnabled && !_textOnlyMode,
                    currentStepText: firstStep,
                  );
              if (mounted) context.go('/body-double/session');
            },
            icon: const Icon(Icons.self_improvement_rounded),
            label: const Text('Start with Dope-i'),
          ),
        ],
      ),
    );
  }
}
