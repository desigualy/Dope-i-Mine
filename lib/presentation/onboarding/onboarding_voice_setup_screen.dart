import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';

class OnboardingVoiceSetupScreen extends ConsumerWidget {
  const OnboardingVoiceSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(onboardingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Voice setup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Voice input and output', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('You can use your voice to add tasks and have steps read aloud.'),
            const SizedBox(height: 12),
            SwitchListTile(
              value: controller.voiceEnabled,
              onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setVoiceEnabled(v),
              title: const Text('Enable voice input/output'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              TextButton(onPressed: () => context.pop(), child: const Text('Back')),
              const Spacer(),
              TextButton(onPressed: () => context.go('/onboarding/phase4/notifications'), child: const Text('Skip for now')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => context.go('/onboarding/phase4/notifications'), child: const Text('Continue')),
            ])
          ],
        ),
      ),
    );
  }
}
