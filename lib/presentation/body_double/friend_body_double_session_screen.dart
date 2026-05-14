import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/body_double/body_double_session.dart';
import '../../providers.dart';
import 'body_double_controller.dart';
import 'report_participant_dialog.dart';

class FriendBodyDoubleSessionScreen extends ConsumerStatefulWidget {
  const FriendBodyDoubleSessionScreen({super.key});

  @override
  ConsumerState<FriendBodyDoubleSessionScreen> createState() =>
      _FriendBodyDoubleSessionScreenState();
}

class _FriendBodyDoubleSessionScreenState
    extends ConsumerState<FriendBodyDoubleSessionScreen> {
  Timer? _timer;
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(bodyDoubleControllerProvider.notifier).restore();
      await ref
          .read(bodyDoubleControllerProvider.notifier)
          .refreshSessionClock();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(bodyDoubleControllerProvider.notifier).refreshSessionClock();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bodyDoubleControllerProvider);
    final session = state.activeSession;

    if (session == null ||
        (session.mode != BodyDoubleMode.friend &&
            session.mode != BodyDoubleMode.random)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shared session')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/body-double/start'),
            child: const Text('Start body double'),
          ),
        ),
      );
    }

    final isWaiting = session.status == BodyDoubleStatus.waiting;
    final isRandom = session.mode == BodyDoubleMode.random;
    final randomTextEnabled = isRandom &&
        session.communicationMode == BodyDoubleCommunicationMode.textOnly;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRandom ? 'Random body double' : 'Friend body double'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'remove') {
                await ref
                    .read(bodyDoubleControllerProvider.notifier)
                    .removeParticipant();
                if (context.mounted) context.go('/body-double/summary');
              } else if (val == 'report') {
                await ref
                    .read(bodyDoubleControllerProvider.notifier)
                    .reportParticipant(
                        'Safety concern', 'Reported from session menu');
                if (context.mounted) context.go('/body-double/summary');
              } else if (val == 'leave') {
                if (isRandom && isWaiting) {
                  await ref
                      .read(bodyDoubleControllerProvider.notifier)
                      .cancelRandomQueue();
                } else {
                  await ref
                      .read(bodyDoubleControllerProvider.notifier)
                      .emergencyExit();
                }
                if (context.mounted) context.go('/body-double/summary');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'leave', child: Text('Leave Session')),
              const PopupMenuItem(
                  value: 'remove', child: Text('Remove Participant (Block)')),
              if (isRandom)
                const PopupMenuItem(
                    value: 'report',
                    child: Text('Report Participant',
                        style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (isWaiting) ...<Widget>[
            const Icon(Icons.hourglass_empty_rounded,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isRandom
                  ? 'Waiting for a safe match...'
                  : 'Waiting for friend to join...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.gentlePrompt,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 24),
            if (isRandom) ...<Widget>[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Safety while you wait:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              const _SafetyTip(text: 'Never share your real name or contact info.'),
              const _SafetyTip(text: 'This session is anonymous and adult-only.'),
              const _SafetyTip(text: 'You can leave or report anytime from the menu.'),
              if (state.randomSafetyNotice != null) ...<Widget>[
                const SizedBox(height: 12),
                _RandomSafetyNotice(text: state.randomSafetyNotice!),
              ],
            ],
          ] else ...<Widget>[
            const Icon(Icons.people_alt_rounded, size: 64, color: Colors.teal),
            const SizedBox(height: 16),
            Text(
              state.participants.length > 1
                  ? '${state.participants.length} doubles working together'
                  : 'Your partner is here with you.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.gentlePrompt,
              textAlign: TextAlign.center,
            ),
            if (isRandom) ...<Widget>[
              const SizedBox(height: 12),
              _RandomSafetyNotice(
                text: state.randomSafetyNotice ??
                    'Anonymous preset-signal mode only. No free chat, voice, video, profiles, or contact exchange.',
              ),
            ],
            const SizedBox(height: 24),
            _ParticipantsList(
              participants: state.participants,
              presences: state.participantPresences,
              steps: state.participantSteps,
              currentUserId:
                  ref.watch(authRepositoryProvider).getCurrentUser()?.id,
            ),
            const SizedBox(height: 24),
            _FriendSessionTimingCard(
              remainingSeconds: state.remainingSeconds,
              checkInDue: state.checkInDue,
              status: session.status,
              onAcknowledge: () {
                ref
                    .read(bodyDoubleControllerProvider.notifier)
                    .acknowledgeCheckIn();
                if (isRandom) {
                  ref
                      .read(bodyDoubleControllerProvider.notifier)
                      .sendPresetSignal(BodyDoubleSignalType.stillHere);
                } else {
                  ref
                      .read(bodyDoubleControllerProvider.notifier)
                      .sendChatMessage('Shared "still here"');
                }
              },
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(bodyDoubleControllerProvider.notifier)
                        .markStepCompleted();
                    if (!isRandom) {
                      ref
                          .read(bodyDoubleControllerProvider.notifier)
                          .sendChatMessage('Completed a step!');
                    }
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Step done'),
                ),
                OutlinedButton.icon(
                  onPressed: () => ref
                      .read(bodyDoubleControllerProvider.notifier)
                      .recordOverwhelm(),
                  icon: const Icon(Icons.spa_rounded),
                  label: const Text('Overwhelmed'),
                ),
              ],
            ),
            if (session.communicationMode == BodyDoubleCommunicationMode.voice) ...<Widget>[
              const SizedBox(height: 24),
              _VoiceActivityCard(),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            if (isRandom) ...<Widget>[
              _RandomPresetSignals(
                textEnabled: randomTextEnabled,
                onSignal: (signalType) => ref
                    .read(bodyDoubleControllerProvider.notifier)
                    .sendPresetSignal(signalType),
              ),
              if (randomTextEnabled) ...<Widget>[
                const SizedBox(height: 16),
                _SessionChatPanel(
                  title: 'Limited random text',
                  hintText: 'Short, task-focused message…',
                  messages: state.messages,
                  currentUserId:
                      ref.watch(authRepositoryProvider).getCurrentUser()?.id,
                  controller: _chatController,
                  safetyCopy:
                      'Adult-only filtered text. No links, contact details, locations, medical/sexual/abusive content, or social handles. Reports keep an audit trail.',
                  retentionCopy:
                      'Short message previews may be retained for safety moderation. This is not a social chat or DM.',
                  onSend: (value) => ref
                      .read(bodyDoubleControllerProvider.notifier)
                      .sendChatMessage(value),
                ),
              ],
            ] else ...<Widget>[
              _SessionChatPanel(
                title: 'Session Chat',
                hintText: 'Quiet message...',
                messages: state.messages,
                currentUserId:
                    ref.watch(authRepositoryProvider).getCurrentUser()?.id,
                controller: _chatController,
                onSend: (value) => ref
                    .read(bodyDoubleControllerProvider.notifier)
                    .sendChatMessage(value),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _RandomSafetyNotice extends StatelessWidget {
  const _RandomSafetyNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.shield_rounded),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _RandomPresetSignals extends StatelessWidget {
  const _RandomPresetSignals({
    required this.onSignal,
    this.textEnabled = false,
  });

  final ValueChanged<BodyDoubleSignalType> onSignal;
  final bool textEnabled;

  @override
  Widget build(BuildContext context) {
    const signals = <BodyDoubleSignalType, String>{
      BodyDoubleSignalType.started: 'I’m starting',
      BodyDoubleSignalType.stillHere: 'Still here',
      BodyDoubleSignalType.breakStart: 'Taking a short break',
      BodyDoubleSignalType.breakEnd: 'Back now',
      BodyDoubleSignalType.stepDone: 'Step done',
      BodyDoubleSignalType.wrappingUp: 'Wrapping up',
      BodyDoubleSignalType.thanks: 'Thanks',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Preset signals only',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Random sessions stay anonymous and low-pressure. Preset signals are always the safest option.',
        ),
        if (textEnabled) ...<Widget>[
          const SizedBox(height: 6),
          const Text(
              'Limited adult-only text is enabled below and remains filtered.'),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final entry in signals.entries)
              OutlinedButton(
                onPressed: () => onSignal(entry.key),
                child: Text(entry.value),
              ),
          ],
        ),
      ],
    );
  }
}

class _SessionChatPanel extends StatelessWidget {
  const _SessionChatPanel({
    required this.title,
    required this.hintText,
    required this.messages,
    required this.controller,
    required this.onSend,
    this.currentUserId,
    this.safetyCopy,
    this.retentionCopy,
  });

  final String title;
  final String hintText;
  final List<BodyDoubleMessage> messages;
  final String? currentUserId;
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final String? safetyCopy;
  final String? retentionCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (safetyCopy != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(safetyCopy!),
        ],
        if (retentionCopy != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(retentionCopy!),
        ],
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade800),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMe = msg.senderId == currentUserId;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(msg.body),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                maxLength: 160,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (value) => _send(value),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded),
              onPressed: () => _send(controller.text),
            ),
          ],
        ),
      ],
    );
  }

  void _send(String value) {
    if (value.trim().isEmpty) return;
    onSend(value);
    controller.clear();
  }
}

class _FriendSessionTimingCard extends StatelessWidget {
  const _FriendSessionTimingCard({
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
                      ? 'Open-ended session'
                      : 'Timer: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isOpenEnded ? 'No countdown pressure.' : 'You can leave anytime.',
            ),
            if (checkInDue) ...<Widget>[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: onAcknowledge,
                icon: const Icon(Icons.waving_hand_rounded),
                label: const Text('Shared "still here"'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
class _ParticipantsList extends ConsumerWidget {
  const _ParticipantsList({
    required this.participants,
    required this.presences,
    required this.steps,
    this.currentUserId,
  });

  final List<BodyDoubleParticipant> participants;
  final Map<String, String> presences;
  final Map<String, int> steps;
  final String? currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final others = participants.where((p) => p.userId != currentUserId).toList();
    if (others.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Doubles in session',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final p in others)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: presences[p.userId] == 'online'
                    ? Colors.green
                    : Colors.grey.shade700,
                child: const Icon(Icons.person_rounded, color: Colors.white),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(p.anonymousLabel ?? p.displayNameSnapshot ?? 'Double')),
                  if (others.isNotEmpty) // Safety check
                    IconButton(
                      icon: const Icon(Icons.report_problem_outlined, color: Colors.redAccent, size: 18),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => ReportParticipantDialog(
                          participantUserId: p.userId,
                          sessionId: ref.watch(bodyDoubleControllerProvider).session?.id ?? '',
                          displayName: p.anonymousLabel ?? p.displayNameSnapshot ?? 'Double',
                        ),
                      ),
                    ),
                  if (ref.watch(bodyDoubleControllerProvider).speakingParticipantIds.contains(p.userId))
                    const _VoiceIndicator(),
                ],
              ),
              subtitle: Text(presences[p.userId] ?? 'offline'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('${steps[p.userId] ?? 0}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Text('steps', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _VoiceActivityCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_VoiceActivityCard> createState() => _VoiceActivityCardState();
}

class _VoiceActivityCardState extends ConsumerState<_VoiceActivityCard> {
  bool _isSpeaking = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _isSpeaking
          ? Colors.blue.shade900.withOpacity(0.3)
          : Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.mic_rounded,
                  color: _isSpeaking ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isSpeaking ? 'You are speaking...' : 'Voice active (Adult-only)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (_isSpeaking)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Push-to-talk is the default for random sessions. Keep it brief and task-focused.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onLongPressStart: (_) {
                setState(() => _isSpeaking = true);
                ref.read(bodyDoubleControllerProvider.notifier).setSpeaking(true);
              },
              onLongPressEnd: (_) {
                setState(() => _isSpeaking = false);
                ref.read(bodyDoubleControllerProvider.notifier).setSpeaking(false);
              },
              child: ElevatedButton.icon(
                onPressed: () {}, // Handled by long press
                icon: Icon(_isSpeaking ? Icons.mic_rounded : Icons.mic_none_rounded),
                label: Text(_isSpeaking ? 'RELEASE TO STOP' : 'HOLD TO SPEAK'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: _isSpeaking ? Colors.blue : null,
                  foregroundColor: _isSpeaking ? Colors.white : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _SafetyTip extends StatelessWidget {
  final String text;
  const _SafetyTip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _VoiceIndicator extends StatelessWidget {
  const _VoiceIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic, size: 12, color: Colors.teal.shade700),
          const SizedBox(width: 4),
          Text(
            'Speaking...',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
