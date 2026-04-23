import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import 'onboarding_controller.dart';

class VoicePreferencesScreen extends ConsumerWidget {
  const VoicePreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return PrimaryScaffold(
      title: 'Voice preferences',
      child: Column(
        children: <Widget>[
          SwitchListTile(
            value: state.voiceEnabled,
            onChanged: controller.setVoiceEnabled,
            title: const Text('Enable voice support'),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/onboarding/summary'),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
