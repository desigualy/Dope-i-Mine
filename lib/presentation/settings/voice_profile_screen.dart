import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../domain/voice/voice_settings_model.dart';
import '../../providers.dart';

class VoiceProfileScreen extends ConsumerStatefulWidget {
  const VoiceProfileScreen({super.key});

  @override
  ConsumerState<VoiceProfileScreen> createState() => _VoiceProfileScreenState();
}

class _VoiceProfileScreenState extends ConsumerState<VoiceProfileScreen> {
  String? selectedVoiceId;
  double speechRate = 1.0;
  bool autoReadSteps = false;
  bool autoReadSidequests = false;
  bool loading = true;
  List<Map<String, dynamic>> profiles = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser == null) return;
      final repo = ref.read(voiceSettingsRepositoryProvider);
      final settings = await repo.getSettings(authUser.id);
      final availableProfiles = await repo.getVoiceProfiles();
      if (!mounted) return;
      setState(() {
        profiles = availableProfiles;
        selectedVoiceId = settings?.activeVoiceProfileId;
        speechRate = settings?.speechRate ?? 1.0;
        autoReadSteps = settings?.autoReadSteps ?? false;
        autoReadSidequests = settings?.autoReadSidequests ?? false;
        loading = false;
      });
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
                            value: p['id'] as String,
                            child: Text(p['label'] as String),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedVoiceId = value),
                  decoration: const InputDecoration(labelText: 'Voice profile'),
                ),
                const SizedBox(height: 16),
                Text('Speech rate: ${speechRate.toStringAsFixed(2)}'),
                Slider(
                  value: speechRate,
                  min: 0.5,
                  max: 1.5,
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
                  onChanged: (value) => setState(() => autoReadSidequests = value),
                  title: const Text('Auto-read side quests'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
                    if (authUser == null) return;
                    await ref.read(voiceSettingsRepositoryProvider).save(
                          userId: authUser.id,
                          settings: VoiceSettingsModel(
                            activeVoiceProfileId: selectedVoiceId,
                            speechRate: speechRate,
                            autoReadSteps: autoReadSteps,
                            autoReadSidequests: autoReadSidequests,
                          ),
                        );
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save voice settings'),
                ),
              ],
            ),
    );
  }
}
