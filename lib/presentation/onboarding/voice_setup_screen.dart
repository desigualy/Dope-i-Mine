import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_step_scaffold.dart';

class VoiceSetupScreen extends ConsumerStatefulWidget {
  const VoiceSetupScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

  @override
  ConsumerState<VoiceSetupScreen> createState() => _VoiceSetupScreenState();
}

class _VoiceSetupScreenState extends ConsumerState<VoiceSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();

    return OnboardingStepScaffold(
      title: 'Voice setup',
      stepNumber: 8,
      totalSteps: 9,
      onBack: () => context.go(
        widget.returnToSummary ? '/onboarding/summary' : '/onboarding/permissions',
      ),
      onNext: () => context.go(
        widget.returnToSummary ? '/onboarding/summary' : '/onboarding/summary',
      ),
      nextLabel: widget.returnToSummary ? 'Done' : 'Next',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SwitchListTile(
              value: state.voiceEnabled,
              onChanged: controller.setVoiceEnabled,
              title: const Text('Enable voice support'),
            ),
            const SizedBox(height: 8),
            Text('Speech rate: ${state.speechRate.toStringAsFixed(2)}'),
            Slider(
              value: state.speechRate.clamp(0.2, 1.0),
              min: 0.2,
              max: 1.0,
              onChanged: state.voiceEnabled ? controller.setSpeechRate : null,
            ),
            SwitchListTile(
              value: state.autoReadSteps,
              onChanged: state.voiceEnabled ? controller.setAutoReadSteps : null,
              title: const Text('Auto-read steps'),
            ),
            SwitchListTile(
              value: state.autoReadSidequests,
              onChanged:
                  state.voiceEnabled ? controller.setAutoReadSidequests : null,
              title: const Text('Auto-read side quests'),
            ),
            const SizedBox(height: 12),
            if (authUser == null) ...<Widget>[
              const Text(
                'Voice profiles will be available after login.',
              ),
            ] else ...<Widget>[
              FutureBuilder<List<Map<String, dynamic>>>(
                future: ref
                    .read(voiceSettingsRepositoryProvider)
                    .getVoiceProfiles(),
                builder: (context, snapshot) {
                  final rows = snapshot.data ?? const <Map<String, dynamic>>[];
                  final items = rows
                      .map(
                        (row) => DropdownMenuItem<String>(
                          value: row['id'] as String,
                          child: Text((row['label'] as String?) ?? 'Voice'),
                        ),
                      )
                      .toList();

                  return ListTile(
                    title: const Text('Voice profile'),
                    subtitle: const Text('Choose a voice (optional).'),
                    trailing: DropdownButton<String?>(
                      value: state.activeVoiceProfileId,
                      items: <DropdownMenuItem<String?>>[
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Default'),
                        ),
                        ...items,
                      ],
                      onChanged: state.voiceEnabled
                          ? (value) => controller.setActiveVoiceProfileId(value)
                          : null,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
