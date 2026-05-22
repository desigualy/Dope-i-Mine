import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';

class OnboardingBodyDoubleSetupScreen extends ConsumerWidget {
  const OnboardingBodyDoubleSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(onboardingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Body-double preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Body-double support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              value: controller.bodyDoubleEnabled,
              onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setBodyDoubleEnabled(v),
              title: const Text('Enable body-double support'),
            ),
            const SizedBox(height: 8),
            const Text('Options: Dope-i support (bot), known-person, random anonymous'),
            const SizedBox(height: 12),
            Row(children: [
              TextButton(onPressed: () => context.pop(), child: const Text('Back')),
              const Spacer(),
              TextButton(onPressed: () => context.go('/onboarding/phase4/first-task'), child: const Text('Skip for now')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => context.go('/onboarding/phase4/first-task'), child: const Text('Continue')),
            ])
          ],
        ),
      ),
    );
  }
}
