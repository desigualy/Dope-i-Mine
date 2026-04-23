
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../domain/branding/pronunciation_option.dart';
import '../../presentation/onboarding/onboarding_controller.dart';
import '../../presentation/voice/voice_controller.dart';
import '../../providers.dart';

class VoiceNamePreviewScreen extends ConsumerWidget {
  const VoiceNamePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingControllerProvider);
    final previews = ref.read(brandingRepositoryProvider).getVoiceNamePreviews();

    return PrimaryScaffold(
      title: 'Preview assistant name',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Current pronunciation: ${onboarding.pronunciation.label}'),
          const SizedBox(height: 12),
          const Text(
            'Preview how the assistant name will sound before saving voice settings.',
          ),
          const SizedBox(height: 16),
          ...previews.map(
            (spoken) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(voiceControllerProvider).speakStep(spoken);
                },
                child: Text('Play: $spoken'),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              final spoken = switch (onboarding.pronunciation) {
                PronunciationOption.dopeEe => 'Dope-ee',
                PronunciationOption.dopy => 'Dopy',
                PronunciationOption.dopeEye => 'Dope-eye',
                PronunciationOption.custom => onboarding.assistantDisplayName,
              };
              await ref.read(voiceControllerProvider).speakStep(spoken);
            },
            child: const Text('Play selected pronunciation'),
          ),
        ],
      ),
    );
  }
}
