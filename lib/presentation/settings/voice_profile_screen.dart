import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sync/sync_queue_item.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../domain/voice/voice_profile_model.dart';
import '../../domain/voice/voice_settings_model.dart';
import '../../providers.dart';

import '../../presentation/voice/voice_test_panel.dart';

class VoiceProfileScreen extends ConsumerStatefulWidget {
  const VoiceProfileScreen({super.key});

  @override
  ConsumerState<VoiceProfileScreen> createState() => _VoiceProfileScreenState();
}

class _VoiceProfileScreenState extends ConsumerState<VoiceProfileScreen> {
  static const double _minSpeechRate = 0.5;
  static const double _maxSpeechRate = 1.5;

  String? selectedVoiceId;
  double speechRate = 1.0;
  bool autoReadSteps = false;
  bool autoReadSidequests = false;
  bool loading = true;
  List<VoiceProfileModel> profiles = const <VoiceProfileModel>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser == null) {
        if (mounted) setState(() => loading = false);
        return;
      }
      final localSettings =
          await ref.read(localVoiceSettingsStoreProvider).load(authUser.id);
      if (localSettings != null) {
        setState(() {
          selectedVoiceId = localSettings.activeVoiceProfileId;
          speechRate = _clampSpeechRate(localSettings.speechRate);
          autoReadSteps = localSettings.autoReadSteps;
          autoReadSidequests = localSettings.autoReadSidequests;
        });
      }

      final repo = ref.read(voiceSettingsRepositoryProvider);
      VoiceSettingsModel? settings;
      List<VoiceProfileModel> availableProfiles = VoiceProfileModel.fallbacks;
      try {
        settings = await repo.getSettings(authUser.id);
        availableProfiles = await repo.getVoiceProfiles();
      } catch (error) {
        debugPrint('Loaded local voice settings; remote load failed: $error');
      }
      if (!mounted) return;
      final resolvedVoiceId = _resolveSelectedVoiceId(
        preferredId: settings?.activeVoiceProfileId ?? selectedVoiceId,
        availableProfiles: availableProfiles,
      );
      setState(() {
        profiles = availableProfiles;
        selectedVoiceId = resolvedVoiceId;
        speechRate = _clampSpeechRate(settings?.speechRate ?? speechRate);
        autoReadSteps = settings?.autoReadSteps ?? autoReadSteps;
        autoReadSidequests = settings?.autoReadSidequests ?? autoReadSidequests;
        loading = false;
      });
      if (settings != null) {
        await ref
            .read(localVoiceSettingsStoreProvider)
            .save(userId: authUser.id, settings: settings);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Voice settings',
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: selectedVoiceId,
                  items: profiles
                      .map((p) => DropdownMenuItem<String>(
                            value: p.id,
                            child: Text(p.label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    final selected = _profileFor(value);
                    setState(() {
                      selectedVoiceId = value;
                      if (selected != null) {
                        speechRate = _clampSpeechRate(selected.defaultRate);
                      }
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Voice profile'),
                ),
                if (_profileFor(selectedVoiceId) case final selected?) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${selected.accent} · ${selected.gender} · ${selected.localeId} · ${selected.pace}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 16),
                Text('Speech rate: ${speechRate.toStringAsFixed(2)}'),
                Slider(
                  value: speechRate,
                  min: _minSpeechRate,
                  max: _maxSpeechRate,
                  divisions: 10,
                  onChanged: (value) => setState(() => speechRate = value),
                ),
                SwitchListTile(
                  value: autoReadSteps,
                  onChanged: (value) => setState(() => autoReadSteps = value),
                  title: const Text('Auto-read steps'),
                ),
                SwitchListTile(
                  value: autoReadSidequests,
                  onChanged: (value) =>
                      setState(() => autoReadSidequests = value),
                  title: const Text('Auto-read side quests'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final authUser =
                        ref.read(authRepositoryProvider).getCurrentUser();
                    if (authUser == null) return;
                    final nextSettings = VoiceSettingsModel(
                      activeVoiceProfileId: selectedVoiceId,
                      localeId: _profileFor(selectedVoiceId)?.localeId,
                      speechRate: speechRate,
                      autoReadSteps: autoReadSteps,
                      autoReadSidequests: autoReadSidequests,
                    );
                    await ref
                        .read(localVoiceSettingsStoreProvider)
                        .save(userId: authUser.id, settings: nextSettings);
                    try {
                      await ref.read(voiceSettingsRepositoryProvider).save(
                            userId: authUser.id,
                            settings: nextSettings,
                          );
                    } catch (error) {
                      debugPrint(
                          'Saved voice settings locally; remote sync failed: $error');
                      await ref.read(syncQueueServiceProvider).enqueue(
                            SyncQueueItem.create(
                              type: 'save_voice_settings',
                              idempotencyKey:
                                  'save_voice_settings_${authUser.id}',
                              payload: <String, dynamic>{
                                'userId': authUser.id,
                                'activeVoiceProfileId':
                                    nextSettings.activeVoiceProfileId,
                                'localeId': nextSettings.localeId,
                                'speechRate': nextSettings.speechRate,
                                'autoReadSteps': nextSettings.autoReadSteps,
                                'autoReadSidequests':
                                    nextSettings.autoReadSidequests,
                              },
                            ),
                          );
                    }
                    ref.invalidate(voiceSettingsProvider);

                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save voice settings'),
                ),
                const SizedBox(height: 24),
                VoiceTestPanel(
                  previewProfile: _profileFor(selectedVoiceId),
                  previewSpeechRate: speechRate,
                ),
              ],
            ),
    );
  }

  VoiceProfileModel? _profileFor(String? id) {
    if (id == null) return null;
    for (final profile in profiles) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  String? _resolveSelectedVoiceId({
    required String? preferredId,
    required List<VoiceProfileModel> availableProfiles,
  }) {
    if (availableProfiles.isEmpty) return null;
    for (final profile in availableProfiles) {
      if (profile.id == preferredId) return preferredId;
    }
    return availableProfiles.first.id;
  }

  double _clampSpeechRate(double value) {
    return value.clamp(_minSpeechRate, _maxSpeechRate).toDouble();
  }
}
