import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';

class OnboardingAccessibilitySetupScreen extends ConsumerWidget {
  const OnboardingAccessibilitySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(onboardingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility & sensory')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Accessibility preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              value: controller.largeText,
              onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setLargeText(v),
              title: const Text('Large text'),
            ),
            SwitchListTile(
              value: controller.reducedAnimation,
              onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setReducedMotion(v),
              title: const Text('Reduce motion'),
            ),
            SwitchListTile(
              value: controller.softColors,
              onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setCalmMode(v),
              title: const Text('Calm mode (sensory-friendly)'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              TextButton(onPressed: () => context.pop(), child: const Text('Back')),
              const Spacer(),
              TextButton(onPressed: () => context.go('/onboarding/phase4/body-double'), child: const Text('Skip for now')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => context.go('/onboarding/phase4/body-double'), child: const Text('Continue')),
            ])
          ],
        ),
      ),
    );
  }
}
