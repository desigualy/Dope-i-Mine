import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import 'onboarding_controller.dart';

class SensoryPreferencesScreen extends ConsumerWidget {
  const SensoryPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return PrimaryScaffold(
      title: 'Sensory preferences',
      child: Column(
        children: <Widget>[
          SwitchListTile(
            value: state.reducedAnimation,
            onChanged: controller.setReducedAnimation,
            title: const Text('Reduce animation'),
          ),
          SwitchListTile(
            value: state.largeText,
            onChanged: controller.setLargeText,
            title: const Text('Large text'),
          ),
          SwitchListTile(
            value: state.soundEnabled,
            onChanged: controller.setSoundEnabled,
            title: const Text('Allow sound'),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/onboarding/voice'),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
