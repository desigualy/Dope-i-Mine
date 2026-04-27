import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/widgets/error_banner.dart';
import '../../domain/branding/pronunciation_option.dart';
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

  static const int _totalSteps = 9;

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
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
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
      title: 'Summary',
      stepNumber: 9,
      totalSteps: _totalSteps,
      onBack: () => context.go('/onboarding/voice'),
      bottom: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _loading
              ? null
              : () async {
                  setState(() {
                    _loading = true;
                    _errorText = null;
                  });
                  try {
                    final authUser =
                        ref.read(authRepositoryProvider).getCurrentUser();
                    if (authUser != null) {
                      await ref
                          .read(profileRepositoryProvider)
                          .saveOnboardingProfile(
                            userId: authUser.id,
                            ageBand: state.ageBand,
                            assistantDisplayName: state.assistantDisplayName,
                            pronunciation: state.pronunciation,
                            mode: state.mode,
                            voiceEnabled: state.voiceEnabled,
                            reducedAnimation: state.reducedAnimation,
                            largeText: state.largeText,
                            soundEnabled: state.soundEnabled,
                            softColors: state.softColors,
                            praiseLevel: state.praiseLevel,
                            iconMode: state.iconMode,
                            reduceSurprises: state.reduceSurprises,
                          );
                    }
                    if (mounted) {
                      context.go('/home');
                    }
                  } catch (error, stack) {
                    debugPrint('===== SUMMARY FINISH ERROR =====');
                    debugPrint('Error type: ${error.runtimeType}');
                    debugPrint('Error: $error');
                    debugPrint('Stack: $stack');
                    debugPrint('================================');
                    setState(() {
                      _errorText = mapToUserFacingError(error);
                    });
                  } finally {
                    if (mounted) {
                      setState(() => _loading = false);
                    }
                  }
                },
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
              onEdit: () => context.go('/branding/pronunciation?return=summary'),
            ),
            _summaryRow(
              label: 'Age band',
              value: state.ageBand.name,
              onEdit: () => context.go('/onboarding/age-band?return=summary'),
            ),
            _summaryRow(
              label: 'Assistant name',
              value: state.assistantDisplayName,
              onEdit: () => context.go('/onboarding/assistant-name?return=summary'),
            ),
            _summaryRow(
              label: 'Mode',
              value: state.mode.name,
              onEdit: () => context.go('/onboarding/mode?return=summary'),
            ),
            _summaryRow(
              label: 'Sensory preferences',
              value: 'Sound: ${state.soundEnabled}',
              onEdit: () => context.go('/onboarding/sensory?return=summary'),
            ),
            _summaryRow(
              label: 'Accessibility & comfort',
              value:
                  'Reduced animation: ${state.reducedAnimation} · Large text: ${state.largeText} · Soft colors: ${state.softColors} · Icon mode: ${state.iconMode} · Reduce surprises: ${state.reduceSurprises} · Praise: ${state.praiseLevel}',
              onEdit: () => context.go('/onboarding/accessibility?return=summary'),
            ),
            _summaryRow(
              label: 'Permissions',
              value:
                  'Notifications: ${state.notificationsEnabled} · Microphone: ${state.microphoneEnabled}',
              onEdit: () => context.go('/onboarding/permissions?return=summary'),
            ),
            _summaryRow(
              label: 'Voice support',
              value: state.voiceEnabled ? 'Enabled' : 'Disabled',
              onEdit: () => context.go('/onboarding/voice?return=summary'),
            ),
            _summaryRow(
              label: 'Voice setup',
              value:
                  'Rate: ${state.speechRate.toStringAsFixed(2)} · Auto-read steps: ${state.autoReadSteps} · Auto-read side quests: ${state.autoReadSidequests} · Voice profile: ${state.activeVoiceProfileId ?? 'Default'}',
              onEdit: () => context.go('/onboarding/voice-setup?return=summary'),
            ),
          ],
        ),
      ),
    );
  }
}
