import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';

class OnboardingBodyDoubleSetupScreen extends ConsumerWidget {
  const OnboardingBodyDoubleSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Body-double preferences')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Body-double support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose whether focused support sessions should be easy to find from the app.',
            ),
            SwitchListTile(
              value: state.bodyDoubleEnabled,
              onChanged: controller.setBodyDoubleEnabled,
              title: const Text('Enable body-double support'),
            ),
            const SizedBox(height: 8),
            const ListTile(
              title: Text('Dope-i support session'),
              subtitle: Text('Start a focused session with the app.'),
            ),
            const ListTile(
              title: Text('Known-person body double'),
              subtitle: Text('Invite someone you already trust.'),
            ),
            const ListTile(
              title: Text('Random body double'),
              subtitle: Text('Uses anonymous labels and safety restrictions.'),
            ),
            const ListTile(
              title: Text('Group body double'),
              subtitle: Text(
                  'Shown only where the implemented group flow is available.'),
            ),
            const SizedBox(height: 8),
            const Text('You can leave at any time.'),
            const Text('Do not share private contact or location details.'),
            const Text('You can report a participant.'),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () =>
                      context.go('/onboarding/phase4/accessibility'),
                  child: const Text('Back'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    controller.setBodyDoubleEnabled(false);
                    context.go('/onboarding/phase4/first-task');
                  },
                  child: const Text('Not now'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.go('/onboarding/phase4/first-task'),
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
