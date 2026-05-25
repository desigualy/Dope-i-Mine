import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';

class OnboardingAccessibilitySetupScreen extends ConsumerWidget {
  const OnboardingAccessibilitySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility and sensory')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Make the app easier to use',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'These settings stay free and can be changed later.',
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: state.largeText,
              onChanged: controller.setLargeText,
              title: const Text('Large text'),
            ),
            SwitchListTile(
              value: state.reducedAnimation,
              onChanged: controller.setReducedMotion,
              title: const Text('Reduced motion'),
            ),
            SwitchListTile(
              value: state.softColors,
              onChanged: controller.setSoftColors,
              title: const Text('Sensory-friendly colours'),
            ),
            SwitchListTile(
              value: state.iconMode,
              onChanged: controller.setIconMode,
              title: const Text('Plain-language and icon support'),
            ),
            SwitchListTile(
              value: state.reduceSurprises,
              onChanged: controller.setReduceSurprises,
              title: const Text('Calm mode'),
            ),
            SwitchListTile(
              value: state.soundEnabled,
              onChanged: controller.setSoundEnabled,
              title: const Text('Sound and haptics'),
            ),
            SwitchListTile(
              value: state.voiceEnabled,
              onChanged: controller.setVoiceEnabled,
              title: const Text('Voice-first mode'),
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () =>
                      context.go('/onboarding/phase4/notifications'),
                  child: const Text('Back'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/onboarding/phase4/body-double'),
                  child: const Text('Skip for now'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.go('/onboarding/phase4/body-double'),
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
