import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';

class OnboardingVoiceSetupScreen extends ConsumerWidget {
  const OnboardingVoiceSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Voice setup')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Voice input and output',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('You can use your voice to add tasks.'),
            const Text('You can ask the app to read steps aloud.'),
            const Text('You can stop listening or speaking at any time.'),
            const SizedBox(height: 12),
            SwitchListTile(
              value: state.voiceEnabled,
              onChanged: controller.setVoiceEnabled,
              title: const Text('Voice input and read-aloud'),
            ),
            SwitchListTile(
              value: state.microphoneEnabled,
              onChanged: controller.setMicrophoneEnabled,
              title: const Text('Prepare microphone permission'),
              subtitle:
                  const Text('The microphone will not start automatically.'),
            ),
            SwitchListTile(
              value: state.autoReadSteps,
              onChanged: controller.setAutoReadSteps,
              title: const Text('Read task steps aloud'),
            ),
            const SizedBox(height: 8),
            Text('Speech rate: ${state.speechRate.toStringAsFixed(2)}'),
            Slider(
              value: state.speechRate,
              min: 0.25,
              max: 0.85,
              divisions: 6,
              label: state.speechRate.toStringAsFixed(2),
              onChanged: controller.setSpeechRate,
            ),
            OutlinedButton(
              onPressed: () => context.go('/settings/voice'),
              child: const Text('Open voice test panel'),
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => context.go('/onboarding/phase4/role'),
                  child: const Text('Back'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    controller.setVoiceEnabled(false);
                    context.go('/onboarding/phase4/notifications');
                  },
                  child: const Text('Not now'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () =>
                      context.go('/onboarding/phase4/notifications'),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
