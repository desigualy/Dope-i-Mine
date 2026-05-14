import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_back_button.dart';
import '../../domain/body_double/body_double_session.dart';
import '../../providers.dart';
import '../tasks/task_controller.dart';
import 'body_double_controller.dart';

class BodyDoubleStartScreen extends ConsumerStatefulWidget {
  const BodyDoubleStartScreen({super.key});

  @override
  ConsumerState<BodyDoubleStartScreen> createState() =>
      _BodyDoubleStartScreenState();
}

class _BodyDoubleStartScreenState extends ConsumerState<BodyDoubleStartScreen> {
  final _friendIdController = TextEditingController();
  BodyDoubleSessionType _type = BodyDoubleSessionType.quickStart;
  BodyDoublePrivacyLevel _friendPrivacyLevel = BodyDoublePrivacyLevel.titleOnly;
  BodyDoubleCommunicationMode _randomCommunicationMode =
      BodyDoubleCommunicationMode.presetSignals;
  bool _quietMode = true;
  bool _textOnlyMode = false;
  bool _voiceEnabled = false;
  String _taskCategory = 'general';
  String _language = 'en';
  BodyDoublePrivacyLevel _randomPrivacyLevel = BodyDoublePrivacyLevel.private;

  @override
  void dispose() {
    _friendIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bodyDoubleControllerProvider);
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
                'MVP safety note: Dope-i is available now. Friend invites and '
                'safer anonymous body doubling are coming later, with consent, '
                'privacy controls, age gates, block/report, and no adult/minor '
                'random matching.',
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
          const SizedBox(height: 24),
          _PendingFriendInvites(invites: state.friendInvites),
          const SizedBox(height: 24),
          Text(
            'Invite a trusted person',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Friend body doubling only starts after they accept. You control '
            'what they can see, and either person can leave anytime.',
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey<String>('friend-body-double-user-id-field'),
            controller: _friendIdController,
            decoration: const InputDecoration(
              labelText: 'Invite friends (IDs or Emails, comma-separated)',
              border: OutlineInputBorder(),
              hintText: 'user1@example.com, friend_id_123',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<BodyDoublePrivacyLevel>(
            key: const ValueKey<String>('friend-body-double-privacy-field'),
            value: _friendPrivacyLevel,
            decoration: const InputDecoration(
              labelText: 'What they can see',
              border: OutlineInputBorder(),
            ),
            items: const <DropdownMenuItem<BodyDoublePrivacyLevel>>[
              DropdownMenuItem(
                value: BodyDoublePrivacyLevel.private,
                child: Text('Nothing — just presence'),
              ),
              DropdownMenuItem(
                value: BodyDoublePrivacyLevel.titleOnly,
                child: Text('Task title only'),
              ),
              DropdownMenuItem(
                value: BodyDoublePrivacyLevel.progressOnly,
                child: Text('Progress only'),
              ),
              DropdownMenuItem(
                value: BodyDoublePrivacyLevel.fullSteps,
                child: Text('Full task steps'),
              ),
            ],
            onChanged: (value) => setState(
              () => _friendPrivacyLevel = value ?? _friendPrivacyLevel,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey<String>('start-friend-body-double-button'),
            onPressed: () async {
              final authUser = ref.read(authRepositoryProvider).getCurrentUser();
              final input = _friendIdController.text.trim();
              if (authUser == null || input.isEmpty) return;

              final receiverIds = input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              
              for (final receiverId in receiverIds) {
                await ref
                    .read(bodyDoubleControllerProvider.notifier)
                    .createFriendInvite(
                      senderId: authUser.id,
                      receiverId: receiverId,
                      taskId: taskState.task?.id,
                      taskTitle: taskState.task?.normalizedTitle,
                      privacyLevel: _friendPrivacyLevel,
                    );
              }
              if (mounted) context.go('/body-double/session');
            },
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Send invitations'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            'Random body double',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Phase 3B safe mode: anonymous co-presence with preset signals only. '
            'No free chat, voice, video, profiles, location sharing, or contact exchange.',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<BodyDoublePrivacyLevel>(
            key: const ValueKey<String>('random-body-double-privacy-field'),
            value: _randomPrivacyLevel,
            decoration: const InputDecoration(
              labelText: 'What they can see',
              border: OutlineInputBorder(),
            ),
            items: const <DropdownMenuItem<BodyDoublePrivacyLevel>>[
              DropdownMenuItem(
                value: BodyDoublePrivacyLevel.private,
                child: Text('Nothing — just presence'),
              ),
              DropdownMenuItem(
                value: BodyDoublePrivacyLevel.titleOnly,
                child: Text('Task title only'),
              ),
            ],
            onChanged: (value) => setState(
              () => _randomPrivacyLevel = value ?? _randomPrivacyLevel,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<BodyDoubleCommunicationMode>(
            key: const ValueKey<String>('random-body-double-communication-field'),
            value: _randomCommunicationMode,
            decoration: const InputDecoration(
              labelText: 'Communication mode',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: BodyDoubleCommunicationMode.presetSignals,
                child: Text('Preset signals only'),
              ),
              const DropdownMenuItem(
                value: BodyDoubleCommunicationMode.quiet,
                child: Text('Silent presence only'),
              ),
              if (state.eligibility?.textAllowed ?? false)
                const DropdownMenuItem(
                  value: BodyDoubleCommunicationMode.textOnly,
                  child: Text('Limited text (Adults)'),
                ),
              if (state.eligibility?.voiceAllowed ?? false)
                const DropdownMenuItem(
                  value: BodyDoubleCommunicationMode.voice,
                  child: Text('Voice (Adults)'),
                ),
            ],
            onChanged: (value) => setState(
              () => _randomCommunicationMode = value ?? _randomCommunicationMode,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _taskCategory,
            decoration: const InputDecoration(
              labelText: 'Task category',
              border: OutlineInputBorder(),
            ),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'general', child: Text('General productivity')),
              DropdownMenuItem(value: 'study', child: Text('Study / Homework')),
              DropdownMenuItem(value: 'cleaning', child: Text('Cleaning / Chores')),
              DropdownMenuItem(value: 'admin', child: Text('Admin / Inbox')),
              DropdownMenuItem(value: 'creative', child: Text('Creative / Hobby')),
            ],
            onChanged: (value) => setState(() => _taskCategory = value ?? 'general'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _language,
            decoration: const InputDecoration(
              labelText: 'Preferred language',
              border: OutlineInputBorder(),
            ),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'es', child: Text('Spanish')),
              DropdownMenuItem(value: 'fr', child: Text('French')),
              DropdownMenuItem(value: 'de', child: Text('German')),
            ],
            onChanged: (value) => setState(() => _language = value ?? 'en'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey<String>('enter-random-queue-button'),
            onPressed: () async {
              await ref
                  .read(bodyDoubleControllerProvider.notifier)
                  .enterRandomQueue(
                    sessionType: _type,
                    privacyLevel: _randomPrivacyLevel,
                    communicationMode: _randomCommunicationMode,
                    taskCategory: _taskCategory,
                    language: _language,
                  );
              if (mounted) context.go('/body-double/session'); // We'll show a waiting screen
            },
            icon: const Icon(Icons.group_rounded),
            label: const Text('Find a partner'),
          ),
        ],
      ),
    );
  }
}

class _PendingFriendInvites extends ConsumerWidget {
  const _PendingFriendInvites({required this.invites});

  final List<BodyDoubleInvite> invites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return const SizedBox.shrink();

    final pending = invites.where((invite) =>
        invite.receiverId == authUser.id &&
        invite.status == BodyDoubleInviteStatus.pending).toList();

    if (pending.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Pending invites',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        ...pending.map((invite) => Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Invite from ${invite.senderId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => ref
                              .read(bodyDoubleControllerProvider.notifier)
                              .respondToFriendInvite(
                                inviteId: invite.id,
                                accept: false,
                              ),
                          child: const Text('Decline'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () async {
                            await ref
                                .read(bodyDoubleControllerProvider.notifier)
                                .respondToFriendInvite(
                                  inviteId: invite.id,
                                  accept: true,
                                );
                            if (context.mounted) {
                              context.go('/body-double/session');
                            }
                          },
                          child: const Text('Accept'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}




