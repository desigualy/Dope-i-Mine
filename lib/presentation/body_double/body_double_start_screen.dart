import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_back_button.dart';
import '../../domain/body_double/body_double_session.dart';
import '../../domain/caregiver/caregiver_models.dart';
import '../../providers.dart';
import '../caregiver/caregiver_controller.dart';
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
  // Mode Selection: 'dopei', 'friend', 'knownGroup', or 'randomGroup'
  String _mode = 'dopei';

  // Config options for Dope-i
  BodyDoubleSessionType _type = BodyDoubleSessionType.quickStart;
  bool _quietMode = true;
  bool _textOnlyMode = false;
  bool _voiceEnabled = false;

  // Config options for Known-Person
  String? _selectedReceiverId;
  BodyDoubleSessionType _friendType = BodyDoubleSessionType.focusSprint;
  int? _sessionLengthMinutes = 25;
  BodyDoublePrivacyLevel _privacyLevel = BodyDoublePrivacyLevel.titleOnly;
  BodyDoubleCommunicationMode _communicationMode =
      BodyDoubleCommunicationMode.quiet;
  final Set<String> _selectedGroupReceiverIds = <String>{};

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(bodyDoubleControllerProvider.notifier).restore();
      await ref.read(caregiverControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskControllerProvider);
    final taskTitle = taskState.task?.normalizedTitle ?? 'your task';
    final firstStep = taskState.steps
        .where((step) => step.depthLevel > 0)
        .map((step) => step.text)
        .cast<String?>()
        .firstWhere((text) => text != null, orElse: () => null);

    final currentUserId = ref.watch(supabaseProvider)?.auth.currentUser?.id;
    final bdState = ref.watch(bodyDoubleControllerProvider);
    final caregiverState = ref.watch(caregiverControllerProvider);

    // Filter pending invites sent to me
    final pendingInvites = bdState.friendInvites.where((invite) {
      return invite.receiverId == currentUserId &&
          invite.status == BodyDoubleInviteStatus.pending;
    }).toList();

    // Map accepted relationships
    final knownPersons = caregiverState.relationships
        .where((rel) => rel.status == CaregiverRelationshipStatus.accepted)
        .map((rel) {
      final isCaregiver = rel.caregiverUserId == currentUserId;
      final id = isCaregiver ? rel.supportedUserId : rel.caregiverUserId;
      final name = isCaregiver
          ? (rel.supportedName ?? 'Supported User')
          : (rel.caregiverName ?? 'Caregiver');
      final roleLabel = isCaregiver ? 'Supported User' : 'Caregiver';
      return _KnownPerson(id: id, name: name, label: '$name ($roleLabel)');
    }).toList();
    final knownPersonIds = knownPersons.map((person) => person.id).toSet();

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Co-Working Support'),
        actions: [
          IconButton(
            tooltip: 'Read screen aloud',
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () {
              final text = _mode == 'dopei'
                  ? 'Start co-working with Dope-i. Work alongside Dope-i quietly. '
                      'No pressure. No performance. Just presence for $taskTitle.'
                  : 'Start co-working with someone you trust. Invite them to quietly '
                      'work alongside you. The session starts only if they accept.';
              ref.read(voiceControllerProvider).speakStep(text);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: <Widget>[
          // Pending Invites Section
          if (pendingInvites.isNotEmpty) ...[
            Text(
              'Pending Invites (${pendingInvites.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
            ),
            const SizedBox(height: 8),
            ...pendingInvites.map((invite) {
              // Lookup sender name
              String senderName = 'Someone you trust';
              for (final rel in caregiverState.relationships) {
                if (rel.status == CaregiverRelationshipStatus.accepted) {
                  if (rel.caregiverUserId == invite.senderId) {
                    senderName = rel.caregiverName ?? 'Caregiver';
                    break;
                  }
                  if (rel.supportedUserId == invite.senderId) {
                    senderName = rel.supportedName ?? 'Supported User';
                    break;
                  }
                }
              }

              return Card(
                elevation: 2,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.amber.shade600, width: 1.5),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.mark_email_unread_rounded,
                              color: Colors.amber.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Invitation from $senderName',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Would you like to join them for a quiet co-working session?',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(bodyDoubleControllerProvider.notifier)
                                  .respondToFriendInvite(
                                    inviteId: invite.id,
                                    accept: false,
                                  );
                            },
                            child: const Text('Decline',
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              await ref
                                  .read(bodyDoubleControllerProvider.notifier)
                                  .respondToFriendInvite(
                                    inviteId: invite.id,
                                    accept: true,
                                  );
                              if (mounted) {
                                context.go('/body-double/session');
                              }
                            },
                            child: const Text('Accept & Join'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Divider(height: 24),
          ],

          // Title / Subtitle
          Text(
            'Co-Working Presence',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Get gentle co-working presence to help you stay focused on $taskTitle.',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),

          // Mode Selector
          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(
                value: 'dopei',
                label: Text('Dope-i body double'),
                icon: Icon(Icons.psychology_rounded),
              ),
              ButtonSegment<String>(
                value: 'friend',
                label: Text('Body double with someone I know'),
                icon: Icon(Icons.people_rounded),
              ),
              ButtonSegment<String>(
                value: 'knownGroup',
                label: Text('Small group body double'),
                icon: Icon(Icons.groups_2_rounded),
              ),
              ButtonSegment<String>(
                value: 'randomGroup',
                label: Text('Quiet support group'),
                icon: Icon(Icons.diversity_3_rounded),
              ),
            ],
            selected: <String>{_mode},
            onSelectionChanged: (Set<String> selection) {
              setState(() {
                _mode = selection.first;
              });
            },
          ),
          const SizedBox(height: 20),

          // Render options based on selection
          if (_mode == 'dopei') ...[
            // Dope-i Mode Options
            Card(
              elevation: 0,
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade800),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Presence',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Work quietly alongside Dope-i. Safe, local-first, always available.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ...BodyDoubleSessionType.values.map(
                      (type) => RadioListTile<BodyDoubleSessionType>(
                        value: type,
                        groupValue: _type,
                        title: Text(type.label),
                        subtitle: Text(type.description),
                        activeColor: Colors.teal,
                        onChanged: (value) =>
                            setState(() => _type = value ?? _type),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Quiet mode'),
              subtitle: const Text('Dope-i stays calm and low-interruption.'),
              value: _quietMode,
              activeColor: Colors.teal,
              onChanged: (value) => setState(() => _quietMode = value),
            ),
            SwitchListTile(
              title: const Text('Text-only mode'),
              subtitle: const Text('No voice prompts during this session.'),
              value: _textOnlyMode,
              activeColor: Colors.teal,
              onChanged: (value) => setState(() => _textOnlyMode = value),
            ),
            SwitchListTile(
              title: const Text('Voice read-aloud available'),
              subtitle:
                  const Text('You can tap Speak step during the session.'),
              value: _voiceEnabled,
              activeColor: Colors.teal,
              onChanged: _textOnlyMode
                  ? null
                  : (value) => setState(() => _voiceEnabled = value),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const ValueKey<String>('start-dopei-body-double-button'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
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
          ] else if (_mode == 'randomGroup') ...[
            Card(
              key: const ValueKey<String>('random-group-body-double-card'),
              elevation: 0,
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade800),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Small group body double',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quiet support group for adult users only. Max 3 people, anonymous labels, preset signals only by default, and you can leave at any time.',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 12),
                    _calmBullet(Icons.shield_rounded,
                        'No public rooms, profile browsing, voice, video, or contact exchange.'),
                    const SizedBox(height: 4),
                    _calmBullet(Icons.no_accounts_rounded,
                        'Random groups are hidden/blocked for minors in this phase.'),
                    const SizedBox(height: 4),
                    _calmBullet(Icons.report_problem_outlined,
                        'Report a participant or leave instantly at any time.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey<String>('enter-random-group-queue-button'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () async {
                await ref
                    .read(bodyDoubleControllerProvider.notifier)
                    .enterRandomGroupQueue(
                      sessionType: BodyDoubleSessionType.focusSprint,
                      taskCategory: 'general',
                      sessionLengthMinutes: 25,
                      communicationMode:
                          BodyDoubleCommunicationMode.presetSignals,
                    );
                if (mounted) context.go('/body-double/session');
              },
              icon: const Icon(Icons.groups_2_rounded),
              label: const Text('Enter quiet group queue'),
            ),
          ] else ...[
            // Known Person Mode Options
            if (knownPersons.isEmpty) ...[
              Card(
                color: Theme.of(context)
                    .colorScheme
                    .errorContainer
                    .withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.redAccent.shade700),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.people_outline_rounded,
                          size: 48, color: Colors.redAccent),
                      const SizedBox(height: 8),
                      const Text(
                        'No Connected Partners Found',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'You can connect a trusted caregiver or supported user in Caregiver Settings, or co-work with Dope-i right now.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => setState(() => _mode = 'dopei'),
                        child: const Text('Use Dope-i instead'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_mode == 'knownGroup') ...[
              Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade800),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Small known-person group',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Invite up to two accepted trusted people. The session starts when at least two people accept, and everyone can leave at any time.',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 12),
                      ...knownPersons.map((person) => CheckboxListTile(
                            value:
                                _selectedGroupReceiverIds.contains(person.id),
                            title: Text(person.label),
                            subtitle:
                                const Text('Accepted trusted relationship'),
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true &&
                                    _selectedGroupReceiverIds.length <
                                        BodyDoubleGroupPolicy
                                                .maximumParticipants -
                                            1) {
                                  _selectedGroupReceiverIds.add(person.id);
                                } else if (selected != true) {
                                  _selectedGroupReceiverIds.remove(person.id);
                                }
                              });
                            },
                          )),
                      const SizedBox(height: 8),
                      _calmBullet(Icons.groups_rounded,
                          'Group size is capped at 3 people.'),
                      const SizedBox(height: 4),
                      _calmBullet(Icons.logout_rounded,
                          'You can leave at any time. No forced continuation.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const ValueKey<String>('send-known-group-invites-button'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _selectedGroupReceiverIds.isEmpty
                    ? null
                    : () async {
                        final senderId = currentUserId;
                        if (senderId == null) return;
                        final sent = await ref
                            .read(bodyDoubleControllerProvider.notifier)
                            .createKnownGroupInvites(
                              senderId: senderId,
                              receiverIds: _selectedGroupReceiverIds.toList(),
                              taskId: taskState.task?.id,
                              taskTitle: taskState.task?.normalizedTitle,
                              privacyLevel: _privacyLevel,
                              sessionType: _friendType,
                              communicationMode:
                                  BodyDoubleCommunicationMode.presetSignals,
                              sessionLengthMinutes: _sessionLengthMinutes,
                              allowedReceiverIds: knownPersonIds,
                            );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(sent
                                ? 'Small group invites sent. The session starts after consent.'
                                : ref
                                    .read(bodyDoubleControllerProvider)
                                    .gentlePrompt),
                          ),
                        );
                        if (sent) context.go('/body-double/session');
                      },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send small group invites'),
              ),
            ] else ...[
              // Setup Invite Form
              Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade800),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Co-work with someone you trust',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Invite someone you trust to quietly work alongside you. They only see what you choose to share.',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 16),

                      // Select Partner
                      DropdownButtonFormField<String>(
                        value: _selectedReceiverId,
                        decoration: const InputDecoration(
                          labelText: 'Select person',
                          border: OutlineInputBorder(),
                        ),
                        items: knownPersons.map((p) {
                          return DropdownMenuItem<String>(
                            value: p.id,
                            child: Text(p.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedReceiverId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Focus Type
                      DropdownButtonFormField<BodyDoubleSessionType>(
                        value: _friendType,
                        decoration: const InputDecoration(
                          labelText: 'Focus Type',
                          border: OutlineInputBorder(),
                        ),
                        items: BodyDoubleSessionType.values.map((type) {
                          return DropdownMenuItem<BodyDoubleSessionType>(
                            value: type,
                            child: Text(type.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _friendType = val;
                              _sessionLengthMinutes = val.defaultMinutes;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Session Duration
                      DropdownButtonFormField<int?>(
                        value: _sessionLengthMinutes,
                        decoration: const InputDecoration(
                          labelText: 'Session Duration',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem<int?>(
                              value: 5, child: Text('5 minutes')),
                          DropdownMenuItem<int?>(
                              value: 15, child: Text('15 minutes')),
                          DropdownMenuItem<int?>(
                              value: 25, child: Text('25 minutes (Default)')),
                          DropdownMenuItem<int?>(
                              value: 45, child: Text('45 minutes')),
                          DropdownMenuItem<int?>(
                              value: 60, child: Text('60 minutes')),
                          DropdownMenuItem<int?>(
                              value: null, child: Text('Open-ended')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _sessionLengthMinutes = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Privacy Level (conservative default titleOnly with explanations)
                      DropdownButtonFormField<BodyDoublePrivacyLevel>(
                        value: _privacyLevel,
                        decoration: const InputDecoration(
                          labelText: 'Privacy Level',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem<BodyDoublePrivacyLevel>(
                            value: BodyDoublePrivacyLevel.titleOnly,
                            child: Text('Title only (recommended)'),
                          ),
                          DropdownMenuItem<BodyDoublePrivacyLevel>(
                            value: BodyDoublePrivacyLevel.private,
                            child: Text('Private'),
                          ),
                          DropdownMenuItem<BodyDoublePrivacyLevel>(
                            value: BodyDoublePrivacyLevel.progressOnly,
                            child: Text('Progress only'),
                          ),
                          DropdownMenuItem<BodyDoublePrivacyLevel>(
                            value: BodyDoublePrivacyLevel.fullSteps,
                            child: Text('Full steps'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _privacyLevel = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      // Privacy Description Helper
                      Text(
                        _getPrivacyDescription(_privacyLevel),
                        style:
                            const TextStyle(fontSize: 11, color: Colors.teal),
                      ),
                      const SizedBox(height: 16),

                      // Communication Mode
                      DropdownButtonFormField<BodyDoubleCommunicationMode>(
                        value: _communicationMode,
                        decoration: const InputDecoration(
                          labelText: 'Communication Mode',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem<BodyDoubleCommunicationMode>(
                            value: BodyDoubleCommunicationMode.quiet,
                            child:
                                Text('Quiet (Silence, minimal interruption)'),
                          ),
                          DropdownMenuItem<BodyDoubleCommunicationMode>(
                            value: BodyDoubleCommunicationMode.presetSignals,
                            child: Text('Preset Signals Only'),
                          ),
                          DropdownMenuItem<BodyDoubleCommunicationMode>(
                            value: BodyDoubleCommunicationMode.textOnly,
                            child: Text('Quiet messages'),
                          ),
                          DropdownMenuItem<BodyDoubleCommunicationMode>(
                            value: BodyDoubleCommunicationMode.voice,
                            child: Text('Voice prompts'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _communicationMode = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Calm assurances
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    _calmBullet(Icons.check_circle_outline_rounded,
                        'The session starts only if they accept.'),
                    const SizedBox(height: 4),
                    _calmBullet(Icons.check_circle_outline_rounded,
                        'You are always in control and can leave at any time.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _selectedReceiverId == null
                    ? null
                    : () async {
                        final senderId = currentUserId;
                        if (senderId == null || _selectedReceiverId == null) {
                          return;
                        }
                        final sent = await ref
                            .read(bodyDoubleControllerProvider.notifier)
                            .createFriendInvite(
                              senderId: senderId,
                              receiverId: _selectedReceiverId!,
                              taskId: taskState.task?.id,
                              taskTitle: taskState.task?.normalizedTitle,
                              privacyLevel: _privacyLevel,
                              sessionType: _friendType,
                              communicationMode: _communicationMode,
                              sessionLengthMinutes: _sessionLengthMinutes,
                              allowedReceiverIds: knownPersonIds,
                            );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(sent
                                ? 'Invite sent. The session starts only if they accept.'
                                : ref
                                    .read(bodyDoubleControllerProvider)
                                    .gentlePrompt),
                          ),
                        );
                        if (sent) context.go('/body-double/session');
                      },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send Co-working Invitation'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _getPrivacyDescription(BodyDoublePrivacyLevel level) {
    switch (level) {
      case BodyDoublePrivacyLevel.titleOnly:
        return 'Title only: they can see the task title.';
      case BodyDoublePrivacyLevel.private:
        return 'Private: they only know you are in a session.';
      case BodyDoublePrivacyLevel.progressOnly:
        return 'Progress only: they can see step count/progress.';
      case BodyDoublePrivacyLevel.fullSteps:
        return 'Full steps: they can see the steps you choose to share.';
    }
  }

  Widget _calmBullet(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.teal),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _KnownPerson {
  const _KnownPerson({
    required this.id,
    required this.name,
    required this.label,
  });

  final String id;
  final String name;
  final String label;
}
