import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/widgets/error_banner.dart';
import '../../domain/onboarding/onboarding_state.dart';
import '../../providers.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_step_scaffold.dart';

class OnboardingSummaryScreen extends ConsumerStatefulWidget {
  const OnboardingSummaryScreen({super.key});

  @override
  ConsumerState<OnboardingSummaryScreen> createState() =>
      _OnboardingSummaryScreenState();
}

class _OnboardingSummaryScreenState
    extends ConsumerState<OnboardingSummaryScreen> {
  bool _loading = false;
  String? _errorText;

  Widget _summaryRow({
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Edit')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);

    return OnboardingStepScaffold(
      title: 'Setup summary',
      stepNumber: 13,
      totalSteps: 13,
      onBack: () => context.go('/onboarding/phase4/first-task'),
      bottom: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _loading ? null : _finishSetup,
          child: Text(_loading ? 'Saving...' : 'Finish'),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_errorText != null) ...<Widget>[
              ErrorBanner(message: _errorText!),
              const SizedBox(height: 12),
            ],
            _summaryRow(
              label: 'Assistant intro',
              value: 'Meet Dope-i',
              onEdit: () => context.go('/branding/intro?return=summary'),
            ),
            _summaryRow(
              label: 'Pronunciation',
              value: state.pronunciation.label,
              onEdit: () =>
                  context.go('/branding/pronunciation?return=summary'),
            ),
            _summaryRow(
              label: 'Role choice',
              value: state.role.label,
              onEdit: () =>
                  context.go('/onboarding/phase4/role?return=summary'),
            ),
            _summaryRow(
              label: 'Support style',
              value: state.mode.name,
              onEdit: () => context.go('/onboarding/mode?return=summary'),
            ),
            _summaryRow(
              label: 'Caregiver support',
              value: switch (state.role) {
                final role when role.name == 'caregiver' =>
                  'Support someone else',
                final role when role.name == 'supported' =>
                  'Someone supports me',
                final role when role.name == 'both' =>
                  'Both caregiver and supported-user options apply',
                _ => 'Not set up now',
              },
              onEdit: () =>
                  context.go('/onboarding/phase4/role?return=summary'),
            ),
            _summaryRow(
              label: 'Voice choice',
              value:
                  'Voice: ${state.voiceEnabled ? 'Enabled' : 'Disabled'} | Microphone: ${state.microphoneEnabled ? 'Prepared' : 'Not now'}',
              onEdit: () =>
                  context.go('/onboarding/phase4/voice?return=summary'),
            ),
            _summaryRow(
              label: 'Voice setup',
              value:
                  'Rate: ${state.speechRate.toStringAsFixed(2)} | Read steps: ${state.autoReadSteps}',
              onEdit: () =>
                  context.go('/onboarding/voice-setup?return=summary'),
            ),
            _summaryRow(
              label: 'Notification choice',
              value: state.notificationsEnabled ? 'Enabled' : 'Disabled',
              onEdit: () =>
                  context.go('/onboarding/phase4/notifications?return=summary'),
            ),
            _summaryRow(
              label: 'Accessibility and sensory choices',
              value:
                  'Large text: ${state.largeText} | Reduced motion: ${state.reducedAnimation} | Sensory-friendly colours: ${state.softColors} | Calm mode: ${state.reduceSurprises} | Sound: ${state.soundEnabled}',
              onEdit: () =>
                  context.go('/onboarding/phase4/accessibility?return=summary'),
            ),
            _summaryRow(
              label: 'Side quest choice',
              value: state.sideQuestsEnabled ? 'Enabled' : 'Disabled',
              onEdit: () =>
                  context.go('/onboarding/phase4/notifications?return=summary'),
            ),
            _summaryRow(
              label: 'Body-double preference',
              value: state.bodyDoubleEnabled ? 'Enabled' : 'Disabled',
              onEdit: () =>
                  context.go('/onboarding/phase4/body-double?return=summary'),
            ),
            _summaryRow(
              label: 'First task choice',
              value: state.firstTaskChoice,
              onEdit: () =>
                  context.go('/onboarding/phase4/first-task?return=summary'),
            ),
            _summaryRow(
              label: 'Age band',
              value: state.ageBand.name,
              onEdit: () => context.go('/onboarding/age-band?return=summary'),
            ),
            _summaryRow(
              label: 'Assistant name',
              value: state.assistantDisplayName,
              onEdit: () =>
                  context.go('/onboarding/assistant-name?return=summary'),
            ),
            _summaryRow(
              label: 'Sex, gender & pronouns',
              value:
                  'Sex at birth: ${state.sexAtBirth.label} | Gender: ${state.genderIdentity.label} | Pronouns: ${state.pronounDisplay}',
              onEdit: () => context.go('/onboarding/identity?return=summary'),
            ),
            _summaryRow(
              label: 'Avatar',
              value: 'Avatar V4 setup',
              onEdit: () => context.go('/onboarding/avatar?return=summary'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishSetup() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final state = ref.read(onboardingControllerProvider);
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser != null) {
        await ref.read(profileRepositoryProvider).saveOnboardingProfile(
              userId: authUser.id,
              ageBand: state.ageBand,
              assistantDisplayName: state.assistantDisplayName,
              pronunciation: state.pronunciation,
              mode: state.mode,
              voiceEnabled: state.voiceEnabled,
              sexAtBirth: state.sexAtBirth.name,
              genderIdentity: state.genderIdentity.name,
              pronouns: state.pronouns.name,
              customPronouns: state.customPronouns,
              reducedAnimation: state.reducedAnimation,
              largeText: state.largeText,
              soundEnabled: state.soundEnabled,
              softColors: state.softColors,
              praiseLevel: state.praiseLevel,
              iconMode: state.iconMode,
              reduceSurprises: state.reduceSurprises,
              onboardingRole: state.role.name,
              notificationsEnabled: state.notificationsEnabled,
              bodyDoubleEnabled: state.bodyDoubleEnabled,
              sideQuestsEnabled: state.sideQuestsEnabled,
            );
      }
      if (mounted) context.go(await _completionRoute());
    } catch (error, stack) {
      debugPrint('===== SUMMARY FINISH ERROR =====');
      debugPrint('Error type: ${error.runtimeType}');
      debugPrint('Error: $error');
      debugPrint('Stack: $stack');
      debugPrint('================================');
      if (mounted) {
        setState(() {
          _errorText = mapToUserFacingError(error);
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String> _completionRoute() async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return '/home';

    final profileRepository = ref.read(profileRepositoryProvider);
    if (await profileRepository.mustChangePassword(authUser.id)) {
      return '/force-password-change';
    }

    final accountType = await profileRepository.getAccountType(authUser.id);
    return accountType == 'caregiver' ? '/caregiver' : '/home';
  }
}
