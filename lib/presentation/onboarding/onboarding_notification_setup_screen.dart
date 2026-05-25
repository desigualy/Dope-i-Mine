import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';

class OnboardingNotificationSetupScreen extends ConsumerWidget {
  const OnboardingNotificationSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Reminder preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Notifications are for tasks, routines, caregiver assignments, body-double invites, matches, and gentle nudges. If Android permission is denied, the app should keep working and show in-app guidance where available.',
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: state.notificationsEnabled,
              onChanged: controller.setNotificationsEnabled,
              title: const Text('Task and routine reminders'),
            ),
            SwitchListTile(
              value: state.bodyDoubleEnabled,
              onChanged: controller.setBodyDoubleEnabled,
              title: const Text('Body-double invites and matches'),
            ),
            SwitchListTile(
              value: state.sideQuestsEnabled,
              onChanged: controller.setSideQuestsEnabled,
              title: const Text('Side quest prompts'),
              subtitle: const Text(
                'Side quests are small optional extras. They should feel helpful, not intrusive.',
              ),
            ),
            const ListTile(
              title: Text('Quiet hours'),
              subtitle: Text(
                  'Keep enabled reminders quiet during rest time where implemented.'),
            ),
            const ListTile(
              title: Text('Sound and vibration'),
              subtitle: Text(
                  'Use the app and Android settings to adjust sound or vibration.'),
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => context.go('/onboarding/phase4/voice'),
                  child: const Text('Back'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    controller.setNotificationsEnabled(false);
                    context.go('/onboarding/phase4/accessibility');
                  },
                  child: const Text('Skip for now'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () =>
                      context.go('/onboarding/phase4/accessibility'),
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
