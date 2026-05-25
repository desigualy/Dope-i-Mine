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
import 'widgets/todays_tasks_card.dart';

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
            const SizedBox(height: 16),
            _HomeAvatarHero(
              configState: userAvatarConfig,
              mood: avatarMood,
            ),
            const SizedBox(height: 12),
            Text(
              'Hi there!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ready to tackle your day?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            const PrimaryActionCard(),
            const SizedBox(height: 12),
            const TodaysTasksCard(),
            const SizedBox(height: 20),
            const _HomeSupportLinks(),
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
            size: 92,
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

class _HomeSupportLinks extends StatelessWidget {
  const _HomeSupportLinks();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Support',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        _SupportLink(
          key: const ValueKey<String>('home-support-body-double'),
          icon: Icons.groups_2_rounded,
          label: 'Body-double',
          route: '/body-double/start',
        ),
        _SupportLink(
          key: const ValueKey<String>('home-support-caregiver'),
          icon: Icons.volunteer_activism_rounded,
          label: 'Caregiver',
          route: '/caregiver',
        ),
        _SupportLink(
          key: const ValueKey<String>('home-support-notifications'),
          icon: Icons.notifications_active_rounded,
          label: 'Notifications',
          route: '/notifications',
        ),
        _SupportLink(
          key: const ValueKey<String>('home-support-sync'),
          icon: Icons.sync_rounded,
          label: 'Sync queue',
          route: '/settings',
        ),
        _SupportLink(
          key: const ValueKey<String>('home-support-accessibility'),
          icon: Icons.accessibility_new_rounded,
          label: 'Accessibility',
          route: '/settings',
        ),
        _SupportLink(
          key: const ValueKey<String>('home-support-voice'),
          icon: Icons.record_voice_over_rounded,
          label: 'Voice',
          route: '/settings/voice',
        ),
        _SupportLink(
          key: const ValueKey<String>('home-support-feedback'),
          icon: Icons.feedback_rounded,
          label: 'Feedback',
          route: '/feedback/beta',
        ),
      ],
    );
  }
}

class _SupportLink extends StatelessWidget {
  const _SupportLink({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(route),
    );
  }
}
