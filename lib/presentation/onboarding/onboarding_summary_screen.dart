import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../domain/branding/pronunciation_option.dart';
import '../../providers.dart';
import 'onboarding_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    return PrimaryScaffold(
      title: 'Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_errorText != null) ...<Widget>[
            ErrorBanner(message: _errorText!),
            const SizedBox(height: 12),
          ],
          Text('Age band: ${state.ageBand.name}'),
          Text('Assistant name: ${state.assistantDisplayName}'),
          Text('Pronunciation: ${state.pronunciation.label}'),
          Text('Mode: ${state.mode.name}'),
          Text('Reduced animation: ${state.reducedAnimation}'),
          Text('Large text: ${state.largeText}'),
          Text('Sound enabled: ${state.soundEnabled}'),
          Text('Voice enabled: ${state.voiceEnabled}'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
                              );
                        }
                        if (mounted) {
                          context.go('/home');
                        }
                      } catch (error) {
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
        ],
      ),
    );
  }
}
