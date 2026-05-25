import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../avatar_engine_v4/avatar_engine_v4.dart';
import 'widgets/onboarding_page_scaffold.dart';

class AvatarSetupScreen extends ConsumerWidget {
  const AvatarSetupScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingPageScaffold(
      title: 'Avatar',
      onBack: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/identity',
      ),
      onNext: () => context.go(
        returnToSummary ? '/onboarding/summary' : '/onboarding/summary',
      ),
      nextLabel: returnToSummary ? 'Save' : 'Continue',
      child: ListView(
        children: <Widget>[
          Card(
            key: const ValueKey<String>('onboarding-avatar-preview'),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: <Widget>[
                  AvatarRiveView(
                    key: const ValueKey<String>('onboarding-avatar-v4-rive'),
                    config: const AvatarV4Config(),
                    size: 220,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your personal avatar',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Avatar Engine V4 uses the Rive avatar rig. The old blob/SVG avatar renderer is not used in onboarding.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey<String>('customize-user-avatar-button'),
            onPressed: () => context.go('/avatar/customize'),
            icon: const Icon(Icons.view_in_ar_outlined),
            label: const Text('Customize avatar'),
          ),
          const SizedBox(height: 16),
          const _AvatarV4DirectionNote(),
        ],
      ),
    );
  }
}

class _AvatarV4DirectionNote extends StatelessWidget {
  const _AvatarV4DirectionNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          'The app is now locked to Avatar Engine V4. The final visual quality depends on assets/avatar_rive/base_avatar.riv matching the Apple/Meta-style Rive contract.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
