import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sync/sync_queue_item.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../domain/voice/installed_tts_voice_model.dart';
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
  String? selectedPlatformVoiceId;
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
          selectedPlatformVoiceId = _platformVoiceId(
            name: localSettings.platformVoiceName,
            locale: localSettings.platformVoiceLocale ?? localSettings.localeId,
          );
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
        selectedPlatformVoiceId = _platformVoiceId(
              name: settings?.platformVoiceName,
              locale: settings?.platformVoiceLocale ?? settings?.localeId,
            ) ??
            selectedPlatformVoiceId;
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
    final installedVoices = ref.watch(installedTtsVoicesProvider);
    return PrimaryScaffold(
      title: 'Voice settings',
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                _EngineStatusLabel(
                  hasSelectedPlatformVoice: selectedPlatformVoiceId != null,
                  installedVoices: installedVoices,
                ),
                const SizedBox(height: 16),
                installedVoices.when(
                  data: (voices) => voices.isEmpty
                      ? const _NoInstalledVoicesNotice()
                      : DropdownButtonFormField<String>(
                          value: _resolvedSelectedPlatformVoiceId(voices),
                          items: voices
                              .map((voice) => DropdownMenuItem<String>(
                                    value: voice.id,
                                    child: Text(voice.displayLabel),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            final selected = _installedVoiceFor(voices, value);
                            setState(() {
                              selectedPlatformVoiceId = value;
                              if (selected != null) {
                                selectedVoiceId = _matchingProfileIdForLocale(
                                      selected.locale,
                                    ) ??
                                    selectedVoiceId;
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Android system voice',
                            helperText:
                                'These are real voices installed on this device.',
                          ),
                        ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const _NoInstalledVoicesNotice(),
                ),
                const SizedBox(height: 16),
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
                  decoration: const InputDecoration(
                    labelText: 'Voice profile tuning',
                    helperText:
                        'Used for rate, pitch, locale hints, Neural TTS, and Sherpa fallback.',
                  ),
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
                    final installedVoices = await ref
                        .read(installedTtsVoicesProvider.future)
                        .catchError(
                            (_) => const <InstalledTtsVoiceModel>[]);
                    final selectedPlatformVoice = _installedVoiceFor(
                      installedVoices,
                      selectedPlatformVoiceId,
                    );
                    final nextSettings = VoiceSettingsModel(
                      activeVoiceProfileId: selectedVoiceId,
                      localeId: selectedPlatformVoice?.locale ??
                          _profileFor(selectedVoiceId)?.localeId,
                      platformVoiceName: selectedPlatformVoice?.name,
                      platformVoiceLocale: selectedPlatformVoice?.locale,
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
                                'platformVoiceName':
                                    nextSettings.platformVoiceName,
                                'platformVoiceLocale':
                                    nextSettings.platformVoiceLocale,
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
                  previewProfile: _previewProfile(installedVoices),
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

  VoiceProfileModel? _previewProfile(
      AsyncValue<List<InstalledTtsVoiceModel>> installedVoices) {
    final profile = _profileFor(selectedVoiceId);
    final selectedVoice = installedVoices.maybeWhen(
      data: (voices) => _installedVoiceFor(voices, selectedPlatformVoiceId),
      orElse: () => null,
    );
    if (selectedVoice == null) return profile;
    return VoiceProfileModel(
      id: profile?.id ?? selectedVoice.id,
      provider: 'system',
      label: selectedVoice.displayLabel,
      localeId: selectedVoice.locale,
      accent: profile?.accent ?? _accentForLocale(selectedVoice.locale),
      gender: profile?.gender ?? 'neutral',
      pace: profile?.pace ?? 'normal',
      warmth: profile?.warmth ?? 'medium',
      firmness: profile?.firmness ?? 'medium',
      tonePreset: profile?.tonePreset ?? 'platform_system_voice',
      platformVoiceName: selectedVoice.name,
    );
  }

  String? _resolvedSelectedPlatformVoiceId(
      List<InstalledTtsVoiceModel> voices) {
    if (voices.any((voice) => voice.id == selectedPlatformVoiceId)) {
      return selectedPlatformVoiceId;
    }
    return null;
  }

  InstalledTtsVoiceModel? _installedVoiceFor(
    List<InstalledTtsVoiceModel> voices,
    String? id,
  ) {
    if (id == null) return null;
    for (final voice in voices) {
      if (voice.id == id) return voice;
    }
    return null;
  }

  String? _matchingProfileIdForLocale(String locale) {
    final normalized = locale.toLowerCase().replaceAll('_', '-');
    for (final profile in profiles) {
      if (profile.localeId.toLowerCase().replaceAll('_', '-') == normalized) {
        return profile.id;
      }
    }
    return null;
  }

  String? _platformVoiceId({String? name, String? locale}) {
    if (name == null || name.isEmpty || locale == null || locale.isEmpty) {
      return null;
    }
    return '$locale::$name';
  }

  String _accentForLocale(String locale) {
    return locale.toLowerCase().contains('us') ? 'US' : 'UK';
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

class _EngineStatusLabel extends StatelessWidget {
  const _EngineStatusLabel({
    required this.hasSelectedPlatformVoice,
    required this.installedVoices,
  });

  final bool hasSelectedPlatformVoice;
  final AsyncValue<List<InstalledTtsVoiceModel>> installedVoices;

  @override
  Widget build(BuildContext context) {
    final label = installedVoices.when(
      data: (voices) {
        if (hasSelectedPlatformVoice) return 'Engine active: Android system voice';
        if (voices.isNotEmpty) {
          return 'Engine active: Sherpa offline unless an Android voice is selected';
        }
        return 'Engine active: Sherpa offline or Neural, then Android default fallback';
      },
      loading: () => 'Engine active: checking Android system voices',
      error: (_, __) => 'Engine active: Sherpa offline, Neural, or Android default fallback',
    );
    return Semantics(
      label: label,
      child: Chip(
        avatar: const Icon(Icons.graphic_eq_rounded, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _NoInstalledVoicesNotice extends StatelessWidget {
  const _NoInstalledVoicesNotice();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'No installed Android system voices were reported by this device. '
      'Fallback profiles may still use Sherpa offline, Neural TTS if configured, '
      'or the Android default voice, but they are not separate installed voices.',
    );
  }
}
