import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';
import 'onboarding_controller.dart';

class OnboardingSummaryScreen extends ConsumerStatefulWidget {
  const OnboardingSummaryScreen({super.key, this.settingsMode = false});

  final bool settingsMode;

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

    return PrimaryScaffold(
      title: widget.settingsMode ? 'Setup choices' : 'Setup summary',
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (_errorText != null) ...<Widget>[
                    ErrorBanner(message: _errorText!),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    widget.settingsMode
                        ? 'Review the core setup choices. More optional controls live in Settings.'
                        : 'Review the essentials before you start.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  _summaryRow(
                    label: 'Pronunciation',
                    value: state.pronunciation.label,
                    onEdit: () =>
                        context.go('/branding/pronunciation?return=summary'),
                  ),
                  _summaryRow(
                    label: 'Support style',
                    value: state.mode.name,
                    onEdit: () => context.go('/onboarding/mode?return=summary'),
                  ),
                  _summaryRow(
                    label: 'Voice choice',
                    value:
                        '${state.voiceEnabled ? 'Enabled' : 'Disabled'}; microphone ${state.microphoneEnabled ? 'prepared' : 'not now'}',
                    onEdit: () =>
                        context.go('/onboarding/voice?return=summary'),
                  ),
                  _summaryRow(
                    label: 'Accessibility basics',
                    value:
                        'Large text: ${state.largeText ? 'on' : 'off'}; reduced motion: ${state.reducedAnimation ? 'on' : 'off'}; sound: ${state.soundEnabled ? 'on' : 'off'}',
                    onEdit: () =>
                        context.go('/onboarding/accessibility?return=summary'),
                  ),
                  _summaryRow(
                    label: 'Age band',
                    value: state.ageBand.name,
                    onEdit: () =>
                        context.go('/onboarding/age-band?return=summary'),
                  ),
                  _summaryRow(
                    label: 'Assistant name',
                    value: state.assistantDisplayName,
                    onEdit: () =>
                        context.go('/onboarding/assistant-name?return=summary'),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.tune_rounded),
                    title: const Text('Optional setup'),
                    subtitle: const Text(
                      'Role, reminders, body double, side quests, identity, avatar, and voice details are editable from Settings.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go(
                      widget.settingsMode ? '/settings' : '/settings/setup',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading
                  ? null
                  : widget.settingsMode
                      ? () => context.go('/settings')
                      : _finishSetup,
              child: Text(
                _loading
                    ? 'Saving...'
                    : widget.settingsMode
                        ? 'Done'
                        : 'Finish',
              ),
            ),
          ),
        ],
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
