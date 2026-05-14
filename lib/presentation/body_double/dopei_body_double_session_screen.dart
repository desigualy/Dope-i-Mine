import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/body_double/body_double_session.dart';
import '../core/widgets/dopei_avatar.dart';
import '../tasks/task_controller.dart';
import '../voice/voice_controller.dart';
import 'body_double_controller.dart';

class DopeiBodyDoubleSessionScreen extends ConsumerStatefulWidget {
  const DopeiBodyDoubleSessionScreen({super.key});

  @override
  ConsumerState<DopeiBodyDoubleSessionScreen> createState() =>
      _DopeiBodyDoubleSessionScreenState();
}

class _DopeiBodyDoubleSessionScreenState
    extends ConsumerState<DopeiBodyDoubleSessionScreen> {
  Timer? _timer;
  bool _lastCheckInDue = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(bodyDoubleControllerProvider.notifier).restore();
      await ref.read(bodyDoubleControllerProvider.notifier).refreshSessionClock();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(bodyDoubleControllerProvider.notifier).refreshSessionClock();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bodyDoubleControllerProvider);
    final session = state.activeSession;

    // Automatic voice check-in
    if (state.checkInDue && !_lastCheckInDue && (session?.voiceEnabled ?? false)) {
      Future.microtask(() {
        ref.read(voiceControllerProvider).speakStep(state.gentlePrompt);
      });
    }
    _lastCheckInDue = state.checkInDue;
    final taskState = ref.watch(taskControllerProvider);
    final currentStep = state.currentStepText ??
        taskState.steps
            .where((step) => step.depthLevel > 0)
            .map((step) => step.text)
            .firstWhere(
              (text) => text.trim().isNotEmpty,
              orElse: () => 'Choose one tiny next step.',
            );

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Body double')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/body-double/start'),
            child: const Text('Start body double'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dope-i body double'),
        actions: <Widget>[
          TextButton(
            key: const ValueKey<String>('body-double-emergency-exit-button'),
            onPressed: () async {
              await ref
                  .read(bodyDoubleControllerProvider.notifier)
                  .emergencyExit();
              if (context.mounted) context.go('/body-double/summary');
            },
            child: const Text('Leave'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Center(
            child: FloatingDopeiAvatar(
              mood: session.overwhelmEvents > 0
                  ? DopeiMood.calm
                  : DopeiMood.focused,
              size: 96,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.gentlePrompt,
            key: const ValueKey<String>('body-double-gentle-prompt'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _SessionTimingCard(
            remainingSeconds: state.remainingSeconds,
            checkInDue: state.checkInDue,
            status: session.status,
            onAcknowledge: () => ref
                .read(bodyDoubleControllerProvider.notifier)
                .acknowledgeCheckIn(),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Current tiny step'),
                  const SizedBox(height: 8),
                  Text(
                    currentStep,
                    key: const ValueKey<String>('body-double-current-step'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      FilledButton.icon(
                        key: const ValueKey<String>(
                            'body-double-step-done-button'),
                        onPressed: () => ref
                            .read(bodyDoubleControllerProvider.notifier)
                            .markStepCompleted(),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Step done'),
                      ),
                      if (session.voiceEnabled)
                        OutlinedButton.icon(
                          key: const ValueKey<String>(
                              'body-double-speak-step-button'),
                          onPressed: () => ref
                              .read(voiceControllerProvider)
                              .speakStep(currentStep),
                          icon: const Icon(Icons.volume_up_rounded),
                          label: const Text('Speak step'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey<String>('body-double-overwhelmed-button'),
            onPressed: () => ref
                .read(bodyDoubleControllerProvider.notifier)
                .recordOverwhelm(),
            icon: const Icon(Icons.spa_rounded),
            label: const Text('I’m overwhelmed'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey<String>('body-double-pause-resume-button'),
            onPressed: () async {
              final controller = ref.read(bodyDoubleControllerProvider.notifier);
              if (session.status == BodyDoubleStatus.paused) {
                await controller.resumeSession();
              } else {
                await controller.pauseSession();
              }
            },
            icon: Icon(session.status == BodyDoubleStatus.paused
                ? Icons.play_arrow_rounded
                : Icons.pause_rounded),
            label: Text(session.status == BodyDoubleStatus.paused
                ? 'Resume session'
                : 'Pause session'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey<String>('body-double-finish-button'),
            onPressed: () async {
              await ref
                  .read(bodyDoubleControllerProvider.notifier)
                  .endSession();
              if (context.mounted) context.go('/body-double/summary');
            },
            icon: const Icon(Icons.flag_rounded),
            label: const Text('Finish session'),
          ),
        ],
      ),
    );
  }
}

class _SessionTimingCard extends StatelessWidget {
  const _SessionTimingCard({
    required this.remainingSeconds,
    required this.checkInDue,
    required this.status,
    required this.onAcknowledge,
  });

  final int? remainingSeconds;
  final bool checkInDue;
  final BodyDoubleStatus status;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final isOpenEnded = remainingSeconds == null;
    final minutes = remainingSeconds == null ? 0 : remainingSeconds! ~/ 60;
    final seconds = remainingSeconds == null ? 0 : remainingSeconds! % 60;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              status == BodyDoubleStatus.paused
                  ? 'Paused'
                  : isOpenEnded
                      ? 'Open-ended calm support'
                      : 'Timer: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              key: const ValueKey<String>('body-double-timer-label'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isOpenEnded
                  ? 'No countdown pressure. Leave whenever you need to.'
                  : 'Dope-i will keep the container. You can pause or leave anytime.',
            ),
            if (checkInDue) ...<Widget>[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                key: const ValueKey<String>('body-double-check-in-button'),
                onPressed: onAcknowledge,
                icon: const Icon(Icons.waving_hand_rounded),
                label: const Text('Still here'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
