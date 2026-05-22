import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';

class OnboardingNotificationSetupScreen extends ConsumerWidget {
  const OnboardingNotificationSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(onboardingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notification preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              value: controller.notificationsEnabled,
              onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setRemindersEnabled(v),
              title: const Text('Task & routine reminders'),
            ),
            SwitchListTile(
              value: controller.bodyDoubleEnabled,
              onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setBodyDoubleEnabled(v),
              title: const Text('Body-double invites & matches'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              TextButton(onPressed: () => context.pop(), child: const Text('Back')),
              const Spacer(),
              TextButton(onPressed: () => context.go('/onboarding/phase4/accessibility'), child: const Text('Skip for now')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => context.go('/onboarding/phase4/accessibility'), child: const Text('Continue')),
            ])
          ],
        ),
      ),
    );
  }
}
