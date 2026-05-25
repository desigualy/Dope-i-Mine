import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../avatar_engine_v4/avatar_engine_v4.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../domain/companion/avatar_config_model.dart';
import '../../domain/companion/dopei_mood.dart' as companion;
import '../avatar/current_user_avatar_provider.dart';
import '../core/controllers/avatar_controller.dart';
import '../core/widgets/dopei_guide.dart';
import 'widgets/primary_action_card.dart';
import 'widgets/dopei_support_card.dart';
import 'widgets/todays_tasks_card.dart';
import 'widgets/home_sync_status_card.dart';
import 'widgets/beta_feedback_card.dart';
import 'widgets/caregiver_card.dart';
import 'widgets/body_double_invites_card.dart';
import 'widgets/notifications_summary_card.dart';
import 'widgets/accessibility_shortcuts_card.dart';

String _getWelcomeMessage(WidgetRef ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning! Let\'s start your day with intention.';
  if (hour < 17) return 'Good afternoon! Keep the momentum going.';
  return 'Good evening! Let\'s wind things down gently.';
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarMood = ref.watch(avatarControllerProvider).mood;
    final userAvatarConfig = ref.watch(currentUserAvatarConfigProvider);

    return PrimaryScaffold(
      title: 'Dope-i-Mine',
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.push('/settings'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            const SizedBox(height: 16),
            DopeiGuide(
              text: _getWelcomeMessage(ref),
              mood: DopeiMood.happy,
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
            _HomeAvatarHero(
              configState: userAvatarConfig,
              mood: avatarMood,
            ),
            const SizedBox(height: 20),
            Text(
              'Hi there!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ready to tackle your day?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 28),
            const PrimaryActionCard(),
            const SizedBox(height: 12),
            const DopeiSupportCard(),
            const SizedBox(height: 12),
            const TodaysTasksCard(),
            const SizedBox(height: 12),
            const HomeSyncStatusCard(),
            const SizedBox(height: 12),
            const BetaFeedbackCard(),
            const SizedBox(height: 12),
            const CaregiverCard(),
            const SizedBox(height: 12),
            const BodyDoubleInvitesCard(),
            const SizedBox(height: 12),
            const NotificationsSummaryCard(),
            const SizedBox(height: 12),
            const AccessibilityShortcutsCard(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _HomeAvatarHero extends StatelessWidget {
  const _HomeAvatarHero({
    required this.configState,
    required this.mood,
  });

  final AsyncValue<AvatarConfigModel> configState;
  final companion.DopeiMood mood;

  @override
  Widget build(BuildContext context) {
    final config = configState.maybeWhen(
      data: _v4ConfigFromLegacyCompanionConfig,
      orElse: AvatarV4Config.starter,
    );

    return Center(
      child: Column(
        children: <Widget>[
          AvatarRiveView(
            key: const ValueKey<String>('home-avatar-v4-rive'),
            config: config,
            size: 132,
          ),
          TextButton(
            onPressed: () => context.push('/avatar/customize'),
            child: const Text('My avatar'),
          ),
        ],
      ),
    );
  }

  AvatarV4Config _v4ConfigFromLegacyCompanionConfig(AvatarConfigModel config) {
    final profile = config.toUserAvatarProfile();

    return AvatarV4Config.starter().copyWith(
      skinTone: 'legacy_${profile.skinTone.value.toRadixString(16)}',
      hairPackId: 'hair_${profile.hairType.name}',
      hairStyleId: '${profile.hairType.name}_${profile.hairLength.name}',
      hairColor: 'legacy_${profile.hairColor.value.toRadixString(16)}',
      freckles: profile.skinDetail.name == 'freckles',
      facialHairStyleId: 'none',
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
  }
}
