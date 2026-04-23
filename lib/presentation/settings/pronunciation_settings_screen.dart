
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../domain/branding/pronunciation_option.dart';
import '../../presentation/onboarding/onboarding_controller.dart';

class PronunciationSettingsScreen extends ConsumerWidget {
  const PronunciationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);

    return PrimaryScaffold(
      title: 'Pronunciation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Choose how Dope-i should sound when spoken aloud.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: PronunciationOption.values
                  .where((e) => e != PronunciationOption.custom)
                  .map(
                    (option) => RadioListTile<PronunciationOption>(
                      value: option,
                      groupValue: state.pronunciation,
                      title: Text(option.label),
                      subtitle: Text(
                        option == PronunciationOption.dopeEe
                            ? 'Common UK-style default'
                            : option == PronunciationOption.dopy
                                ? 'Common US-style default'
                                : 'Alternative spoken form',
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(onboardingControllerProvider.notifier).setPronunciation(value);
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
