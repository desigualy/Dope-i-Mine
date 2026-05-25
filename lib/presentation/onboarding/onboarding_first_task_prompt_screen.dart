import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';

class OnboardingFirstTaskPromptScreen extends ConsumerWidget {
  const OnboardingFirstTaskPromptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Create your first task')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Want to start with one small thing?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('You can also skip and come back later.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.setFirstTaskChoice('Create after setup');
                context.go('/tasks/new');
              },
              child: const Text('Create your first task'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                controller.setFirstTaskChoice('Skipped');
                context.go('/onboarding/summary');
              },
              child: const Text('Skip and review setup'),
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => context.go('/onboarding/phase4/body-double'),
                  child: const Text('Back'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    controller.setFirstTaskChoice('Not now');
                    context.go('/onboarding/summary');
                  },
                  child: const Text('Save and finish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
