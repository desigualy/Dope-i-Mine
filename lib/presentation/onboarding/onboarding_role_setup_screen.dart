import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/onboarding/onboarding_state.dart';
import 'onboarding_controller.dart';

class OnboardingRoleSetupScreen extends ConsumerWidget {
  const OnboardingRoleSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Who is using the app?')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Choose the role that best describes you. You can edit setup later from Settings.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RadioListTile<OnboardingRole>(
              value: OnboardingRole.self,
              groupValue: state.role,
              title: const Text('I am using this for myself'),
              onChanged: (value) => controller.setRole(value!),
            ),
            RadioListTile<OnboardingRole>(
              value: OnboardingRole.caregiver,
              groupValue: state.role,
              title: const Text('I support someone else'),
              onChanged: (value) => controller.setRole(value!),
            ),
            RadioListTile<OnboardingRole>(
              value: OnboardingRole.supported,
              groupValue: state.role,
              title: const Text('Someone supports me'),
              onChanged: (value) => controller.setRole(value!),
            ),
            RadioListTile<OnboardingRole>(
              value: OnboardingRole.both,
              groupValue: state.role,
              title: const Text('Both apply to me'),
              onChanged: (value) => controller.setRole(value!),
            ),
            const SizedBox(height: 12),
            const Text(
              'A caregiver can assign a support task, send a gentle nudge, and view permitted progress only. Access can be removed by the supported user.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Caregiver support is optional. Assigned tasks are support, not punishment, and nudges should stay respectful.',
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go('/branding/intro'),
                  child: const Text('Back'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/onboarding/phase4/voice'),
                  child: const Text('Skip for now'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.go('/onboarding/phase4/voice'),
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
