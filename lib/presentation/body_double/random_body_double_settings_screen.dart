import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../data/local/local_body_double_store.dart';
import '../../data/repositories/body_double_repository_impl.dart';
import '../../domain/tasks/task_state_snapshot.dart' as task_snapshot;
import '../../providers.dart';

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
  bool _voiceAllowed = false;

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
                      'Random body doubling is anonymous, optional, and safety-gated. '
                      'Phase 3C/E allows limited adult-only text and voice when explicitly enabled. Minors stay preset-only. No video, profiles, or contact exchange.',
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
        SwitchListTile(
          title: const Text('Voice chat for adults'),
          subtitle: const Text(
            'Push-to-talk or timed check-in voice only. Safety monitored and reportable.',
          ),
          value: _voiceAllowed,
          onChanged:
              _saving ? null : (value) => setState(() => _voiceAllowed = value),
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
}
