import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../data/local/local_body_double_store.dart';
import '../../data/repositories/body_double_repository_impl.dart';
import '../../domain/body_double/body_double_session.dart';
import '../../domain/tasks/task_state_snapshot.dart' as task_snapshot;
import '../../providers.dart';
import 'body_double_controller.dart';

class RandomBodyDoubleSettingsScreen extends ConsumerStatefulWidget {
  const RandomBodyDoubleSettingsScreen({super.key});

  @override
  ConsumerState<RandomBodyDoubleSettingsScreen> createState() =>
      _RandomBodyDoubleSettingsScreenState();
}

class _RandomBodyDoubleSettingsScreenState
    extends ConsumerState<RandomBodyDoubleSettingsScreen> {
  final TextEditingController _minorUserIdController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _message;
  task_snapshot.AgeBand? _ageBand;
  bool _randomMatchingEnabled = false;
  bool _presetSignalsAllowed = true;
  bool _quietModeAllowed = true;
  bool _textAllowed = false;
  // Phase 3D/3E deliberately does not expose voice until a real monitored
  // random-voice runtime exists. This prevents fake/open voice behaviour.
  bool _voiceAllowed = false;
  BodyDoubleSessionType _sessionType = BodyDoubleSessionType.focusSprint;
  BodyDoubleCommunicationMode _communicationMode =
      BodyDoubleCommunicationMode.presetSignals;
  int _sessionLengthMinutes = 25;
  bool _enteringQueue = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _minorUserIdController.dispose();
    super.dispose();
  }

  BodyDoubleRepositoryImpl? _repository() {
    final client = ref.read(supabaseProvider);
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) return null;
    return BodyDoubleRepositoryImpl(
      localStore: ref.read(localBodyDoubleStoreProvider),
      client: client,
      userId: userId,
    );
  }

  Future<void> _load() async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final profile =
          await ref.read(profileRepositoryProvider).getProfile(authUser.id);
      final settings = await _repository()?.loadRandomSafetySettings();
      await ref
          .read(bodyDoubleControllerProvider.notifier)
          .refreshRandomEligibility();
      if (!mounted) return;
      setState(() {
        _ageBand = profile?.ageBand;
        _randomMatchingEnabled = settings?.randomMatchingEnabled ?? false;
        _presetSignalsAllowed = settings?.presetSignalsAllowed ?? true;
        _quietModeAllowed = settings?.quietModeAllowed ?? true;
        _textAllowed = settings?.textAllowed ?? false;
        _voiceAllowed = settings?.voiceAllowed ?? false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Could not load random body double settings.';
        _loading = false;
      });
    }
  }

  Future<void> _saveAdultSettings() async {
    if (!_presetSignalsAllowed && !_quietModeAllowed) {
      setState(() {
        _message =
            'Keep at least one safe mode enabled: preset signals or silent presence.';
      });
      return;
    }
    final repository = _repository();
    if (repository == null) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    await repository.saveAdultRandomSafetySettings(
      randomMatchingEnabled: _randomMatchingEnabled,
      presetSignalsAllowed: _presetSignalsAllowed,
      quietModeAllowed: _quietModeAllowed,
      textAllowed: _textAllowed,
      voiceAllowed: _voiceAllowed,
    );
    await ref
        .read(bodyDoubleControllerProvider.notifier)
        .refreshRandomEligibility();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = 'Random body double settings saved.';
    });
  }

  Future<void> _setGuardianApproval(bool approved) async {
    final targetUserId = _minorUserIdController.text.trim();
    if (targetUserId.isEmpty) {
      setState(() => _message = 'Enter the minor user ID first.');
      return;
    }
    final repository = _repository();
    if (repository == null) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    await repository.setGuardianRandomApproval(
      targetUserId: targetUserId,
      approved: approved,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = approved
          ? 'Guardian approval submitted. The server will only accept it for active caregiver relationships.'
          : 'Guardian approval revoked if you have permission.';
    });
  }

  bool get _isAdult => _ageBand == task_snapshot.AgeBand.adult;

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Random body double safety',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Random body doubling pairs you with another person for quiet task support. '
                      'Do not share real names, contact details, location, social handles, photos, or private information. '
                      'You can leave at any time. You can report a participant at any time.',
                    ),
                  ),
                ),
                if (_message != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(_message!),
                ],
                const SizedBox(height: 16),
                if (_isAdult)
                  _adultSettings(context)
                else
                  _minorNotice(context),
                const Divider(height: 32),
                _queueEntry(context),
                const Divider(height: 32),
                _guardianApproval(context),
              ],
            ),
    );
  }

  Widget _adultSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Your adult random matching settings',
            style: Theme.of(context).textTheme.titleLarge),
        SwitchListTile(
          key: const ValueKey<String>('random-matching-enabled-switch'),
          title: const Text('Enable random body doubling'),
          subtitle: const Text('Off by default. You can turn it off anytime.'),
          value: _randomMatchingEnabled,
          onChanged: _saving
              ? null
              : (value) => setState(() => _randomMatchingEnabled = value),
        ),
        SwitchListTile(
          title: const Text('Preset signals'),
          subtitle: const Text(
              'Allow safe signals like “Still here” and “Step done”.'),
          value: _presetSignalsAllowed,
          onChanged: _saving
              ? null
              : (value) => setState(() => _presetSignalsAllowed = value),
        ),
        SwitchListTile(
          title: const Text('Silent presence'),
          subtitle: const Text('Allow no-message co-presence sessions.'),
          value: _quietModeAllowed,
          onChanged: _saving
              ? null
              : (value) => setState(() => _quietModeAllowed = value),
        ),
        SwitchListTile(
          title: const Text('Limited text for adults'),
          subtitle: const Text(
            'Filtered short text only. No links, contact details, locations, profanity, medical/sexual/abusive content, or social handles.',
          ),
          value: _textAllowed,
          onChanged:
              _saving ? null : (value) => setState(() => _textAllowed = value),
        ),
        const ListTile(
          leading: Icon(Icons.mic_off_rounded),
          title: Text('Voice is not available for random matching'),
          subtitle: Text(
            'Random voice stays off until a real monitored adult-only voice safety runtime is deployed. Minors can never use random voice.',
          ),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _saveAdultSettings,
          icon: const Icon(Icons.shield_rounded),
          label: Text(_saving ? 'Saving…' : 'Save safety settings'),
        ),
      ],
    );
  }

  Widget _minorNotice(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Minor random matching',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Random matching is disabled by default for minors. It requires guardian approval and remains limited to silent/preset-signal mode only.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _guardianApproval(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Guardian approval',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
          'For caregivers/guardians only. The server accepts approval only when an active caregiver relationship exists. Approval never enables free text, voice, or video for minors.',
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey<String>('guardian-random-minor-user-id-field'),
          controller: _minorUserIdController,
          decoration: const InputDecoration(
            labelText: 'Minor user ID',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: <Widget>[
            FilledButton(
              onPressed: _saving ? null : () => _setGuardianApproval(true),
              child: const Text('Approve safe random matching'),
            ),
            OutlinedButton(
              onPressed: _saving ? null : () => _setGuardianApproval(false),
              child: const Text('Revoke approval'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _queueEntry(BuildContext context) {
    final state = ref.watch(bodyDoubleControllerProvider);
    final eligibility = state.eligibility;
    final canEnter = eligibility?.canEnterRandomQueue == true &&
        eligibility!.allowsCommunicationMode(_communicationMode);
    final queueId = state.queueId;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Enter random body double queue',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Safety gate runs before queue entry. Random matching is support, not social discovery.',
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BodyDoubleSessionType>(
              value: _sessionType,
              decoration: const InputDecoration(
                labelText: 'Safe session type',
                border: OutlineInputBorder(),
              ),
              items: BodyDoubleSessionType.values
                  .map((type) => DropdownMenuItem<BodyDoubleSessionType>(
                        value: type,
                        child: Text(type.label),
                      ))
                  .toList(),
              onChanged: queueId == null
                  ? (value) => setState(() {
                        _sessionType = value ?? _sessionType;
                        _sessionLengthMinutes = _sessionType.defaultMinutes ??
                            _sessionLengthMinutes;
                      })
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _sessionLengthMinutes,
              decoration: const InputDecoration(
                labelText: 'Session length',
                border: OutlineInputBorder(),
              ),
              items: const <DropdownMenuItem<int>>[
                DropdownMenuItem<int>(value: 5, child: Text('5 minutes')),
                DropdownMenuItem<int>(value: 15, child: Text('15 minutes')),
                DropdownMenuItem<int>(value: 25, child: Text('25 minutes')),
                DropdownMenuItem<int>(value: 45, child: Text('45 minutes')),
                DropdownMenuItem<int>(value: 60, child: Text('60 minutes')),
              ],
              onChanged: queueId == null
                  ? (value) => setState(() =>
                      _sessionLengthMinutes = value ?? _sessionLengthMinutes)
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BodyDoubleCommunicationMode>(
              value: _communicationMode,
              decoration: const InputDecoration(
                labelText: 'Allowed communication mode',
                border: OutlineInputBorder(),
              ),
              items: _allowedCommunicationModes()
                  .map((mode) => DropdownMenuItem<BodyDoubleCommunicationMode>(
                        value: mode,
                        child: Text(_communicationLabel(mode)),
                      ))
                  .toList(),
              onChanged: queueId == null
                  ? (value) => setState(
                      () => _communicationMode = value ?? _communicationMode)
                  : null,
            ),
            const SizedBox(height: 12),
            if (state.randomSafetyNotice != null)
              Text(
                state.randomSafetyNotice!,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            if (eligibility != null && !canEnter) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                _ineligibleMessage(eligibility),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.icon(
                  key: const ValueKey<String>('enter-random-queue-button'),
                  onPressed: queueId != null || _enteringQueue || !canEnter
                      ? null
                      : _enterQueue,
                  icon: const Icon(Icons.diversity_2_rounded),
                  label: Text(_enteringQueue
                      ? 'Checking safety…'
                      : 'Enter safe random queue'),
                ),
                if (queueId != null)
                  OutlinedButton.icon(
                    key: const ValueKey<String>('cancel-random-queue-button'),
                    onPressed: _enteringQueue
                        ? null
                        : () => ref
                            .read(bodyDoubleControllerProvider.notifier)
                            .cancelRandomQueue(),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancel queue'),
                  ),
                if (state.activeSession?.mode == BodyDoubleMode.random &&
                    state.activeSession?.status == BodyDoubleStatus.active)
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/body-double/session'),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Open matched session'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<BodyDoubleCommunicationMode> _allowedCommunicationModes() {
    final modes = <BodyDoubleCommunicationMode>[
      BodyDoubleCommunicationMode.presetSignals,
      BodyDoubleCommunicationMode.quiet,
    ];
    if (_isAdult && _textAllowed) {
      modes.add(BodyDoubleCommunicationMode.textOnly);
    }
    // Do not expose random voice in Phase 3D/3E. There is no production voice
    // room/monitoring runtime here, so showing it would be fake behaviour.
    if (!modes.contains(_communicationMode)) {
      _communicationMode = modes.first;
    }
    return modes;
  }

  String _communicationLabel(BodyDoubleCommunicationMode mode) {
    switch (mode) {
      case BodyDoubleCommunicationMode.quiet:
        return 'Quiet presence';
      case BodyDoubleCommunicationMode.presetSignals:
        return 'Preset signals';
      case BodyDoubleCommunicationMode.textOnly:
        return 'Limited filtered text (adults only)';
      case BodyDoubleCommunicationMode.voice:
        return 'Voice (adults only, safety-gated)';
    }
  }

  String _ineligibleMessage(RandomBodyDoubleEligibility eligibility) {
    if (!eligibility.randomMatchingEnabled) {
      return 'Random matching is off. Enable it in safety settings first.';
    }
    if (eligibility.ageBand != BodyDoubleAgeBand.adult &&
        !eligibility.guardianApproved) {
      return 'Guardian approval is required before a minor can use random matching.';
    }
    return 'This communication mode is not allowed by your safety settings.';
  }

  Future<void> _enterQueue() async {
    setState(() {
      _enteringQueue = true;
      _message = null;
    });
    await ref.read(bodyDoubleControllerProvider.notifier).enterRandomQueue(
          sessionType: _sessionType,
          sessionLengthMinutes: _sessionLengthMinutes,
          communicationMode: _communicationMode,
          privacyLevel: BodyDoublePrivacyLevel.titleOnly,
        );
    if (!mounted) return;
    final state = ref.read(bodyDoubleControllerProvider);
    setState(() {
      _enteringQueue = false;
      _message = state.activeSession?.status == BodyDoubleStatus.active
          ? 'Matched. Opening your anonymous session.'
          : state.queueId != null
              ? 'You are in the random queue. You can cancel anytime.'
              : state.randomSafetyNotice ?? 'Could not enter random queue.';
    });
    if (state.activeSession?.mode == BodyDoubleMode.random &&
        state.activeSession?.status == BodyDoubleStatus.active &&
        mounted) {
      context.go('/body-double/session');
    }
  }
}
