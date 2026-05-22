import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';
import 'package:dope_i_mine/domain/onboarding/onboarding_state.dart';

class OnboardingRoleSetupScreen extends ConsumerWidget {
  const OnboardingRoleSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(onboardingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Who is using the app?')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose the role that best describes you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            RadioListTile<OnboardingRole>(
              value: OnboardingRole.self,
              groupValue: controller.role,
              title: const Text('I’m using this for myself'),
              onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setRole(v!),
            ),
            RadioListTile<OnboardingRole>(
              value: OnboardingRole.caregiver,
              groupValue: controller.role,
              title: const Text('I support someone else'),
              onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setRole(v!),
            ),
            RadioListTile<OnboardingRole>(
              value: OnboardingRole.supported,
              groupValue: controller.role,
              title: const Text('Someone supports me'),
              onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setRole(v!),
            ),
            RadioListTile<OnboardingRole>(
              value: OnboardingRole.both,
              groupValue: controller.role,
              title: const Text('Both apply to me'),
              onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setRole(v!),
            ),
            const Spacer(),
            Row(children: [
              TextButton(onPressed: () => context.pop(), child: const Text('Back')),
              const Spacer(),
              TextButton(onPressed: () => context.go('/onboarding/phase4/voice'), child: const Text('Skip for now')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => context.go('/onboarding/phase4/voice'), child: const Text('Continue')),
            ])
          ],
        ),
      ),
    );
  }
}
