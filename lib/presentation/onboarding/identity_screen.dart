import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/onboarding/onboarding_state.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_step_scaffold.dart';

class IdentityScreen extends ConsumerWidget {
  const IdentityScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingStepScaffold(
      title: 'Sex, gender & pronouns',
      stepNumber: 11,
      totalSteps: 13,
      onBack: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/voice-setup',
      ),
      onNext: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/avatar',
      ),
      nextLabel: returnToSummary ? 'Save' : 'Next',
      child: ListView(
        children: <Widget>[
          Text(
            'This helps Dope-i use respectful language and avoid assumptions.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<SexAtBirth>(
            key: const ValueKey<String>('onboarding-sex-at-birth-field'),
            value: state.sexAtBirth,
            items: SexAtBirth.values
                .map(
                  (value) => DropdownMenuItem<SexAtBirth>(
                    value: value,
                    child: Text(value.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) controller.setSexAtBirth(value);
            },
            decoration: const InputDecoration(
              labelText: 'Sex at birth',
              helperText: 'Optional. Choose “Prefer not to say” if unsure.',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<GenderIdentity>(
            key: const ValueKey<String>('onboarding-gender-identity-field'),
            value: state.genderIdentity,
            items: GenderIdentity.values
                .map(
                  (value) => DropdownMenuItem<GenderIdentity>(
                    value: value,
                    child: Text(value.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) controller.setGenderIdentity(value);
            },
            decoration: const InputDecoration(
              labelText: 'Gender',
              helperText: 'Optional. This is about identity, not diagnosis.',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PronounSet>(
            key: const ValueKey<String>('onboarding-pronouns-field'),
            value: state.pronouns,
            items: PronounSet.values
                .map(
                  (value) => DropdownMenuItem<PronounSet>(
                    value: value,
                    child: Text(value.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) controller.setPronouns(value);
            },
            decoration: const InputDecoration(
              labelText: 'Pronouns',
              helperText: 'Used for respectful wording in the app.',
            ),
          ),
          if (state.pronouns == PronounSet.custom) ...<Widget>[
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey<String>('onboarding-custom-pronouns-field'),
              initialValue: state.customPronouns,
              onChanged: controller.setCustomPronouns,
              decoration: const InputDecoration(
                labelText: 'Custom pronouns',
                hintText: 'Example: xe/xem',
              ),
            ),
          ],
          const SizedBox(height: 16),
          const _IdentityPrivacyNote(),
        ],
      ),
    );
  }
}

class _IdentityPrivacyNote extends StatelessWidget {
  const _IdentityPrivacyNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          'You can change this later. Dope-i should never force identity labels or guess them from appearance.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
