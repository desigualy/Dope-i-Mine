import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 390;
          final outerPadding = compact ? 0.0 : 20.0;
          final panelPadding = compact ? 14.0 : 20.0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: outerPadding),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: ColorTokens.homeSurface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: ListView(
                padding: EdgeInsets.all(panelPadding),
                physics: const BouncingScrollPhysics(),
                children: <Widget>[
                  const SizedBox(height: 8),
                  DopeiGuide(
                    text: _getWelcomeMessage(ref),
                    mood: DopeiMood.happy,
                    size: compact ? 58 : 80,
                    padding: EdgeInsets.all(compact ? 8 : 16),
                  ),
                  const SizedBox(height: 16),
                  _HomeAvatarHero(
                    configState: userAvatarConfig,
                    mood: avatarMood,
                    size: compact ? 96 : 116,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hi there!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: ColorTokens.homeText,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ready to tackle your day?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ColorTokens.homeSubtext,
                        ),
                  ),
                  const SizedBox(height: 20),
                  const PrimaryActionCard(),
                  const SizedBox(height: 12),
                  const TodaysTasksCard(),
                  const SizedBox(height: 16),
                  _MenuButton(
                    key: const ValueKey<String>('home-menu-my-avatar'),
                    icon: Icons.face_retouching_natural_rounded,
                    title: 'My avatar',
                    subtitle: 'Customize your look',
                    route: '/avatar/customize',
                    color: ColorTokens.homeTaupeCard,
                  ),
                  _MenuButton(
                    key: const ValueKey<String>('home-menu-body-double'),
                    icon: Icons.groups_2_rounded,
                    title: 'Body double',
                    subtitle: 'Start a support session',
                    route: '/body-double/start',
                    color: ColorTokens.homeTaupeCard,
                  ),
                  _MenuButton(
                    key: const ValueKey<String>('home-menu-routines'),
                    icon: Icons.repeat_rounded,
                    title: 'My routines',
                    subtitle: 'Templates and repeatable steps',
                    route: '/routines',
                    color: ColorTokens.homeMauveCard,
                  ),
                  _MenuButton(
                    key: const ValueKey<String>('home-menu-progress'),
                    icon: Icons.trending_up_rounded,
                    title: 'My progress',
                    subtitle: 'See what is moving',
                    route: '/progress',
                    color: ColorTokens.homeBlueCard,
                  ),
                  _MenuButton(
                    key: const ValueKey<String>('home-menu-caregiver'),
                    icon: Icons.volunteer_activism_rounded,
                    title: 'Caregiver support',
                    subtitle: 'Trusted support tools',
                    route: '/caregiver',
                    color: ColorTokens.homeBlueCard,
                  ),
                  const SizedBox(height: 16),
                  const _SecondarySupportActions(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeAvatarHero extends StatelessWidget {
  const _HomeAvatarHero({
    required this.configState,
    required this.mood,
    required this.size,
  });

  final AsyncValue<AvatarConfigModel> configState;
  final companion.DopeiMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    final config = configState.maybeWhen(
      data: _v4ConfigFromLegacyCompanionConfig,
      orElse: AvatarV4Config.starter,
    );

    return Center(
      child: AvatarRiveView(
        key: const ValueKey<String>('home-avatar-v4-rive'),
        config: config,
        size: size,
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

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 25,
                  backgroundColor: ColorTokens.homeIconWell,
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: ColorTokens.homeText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ColorTokens.homeSubtext,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: ColorTokens.homeSubtext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondarySupportActions extends StatelessWidget {
  const _SecondarySupportActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const <Widget>[
        _SupportChip(
          key: ValueKey<String>('home-secondary-notifications'),
          icon: Icons.notifications_active_rounded,
          label: 'Notifications',
          route: '/notifications',
        ),
        _SupportChip(
          key: ValueKey<String>('home-secondary-sync'),
          icon: Icons.sync_rounded,
          label: 'Sync',
          route: '/settings',
        ),
        _SupportChip(
          key: ValueKey<String>('home-secondary-accessibility'),
          icon: Icons.accessibility_new_rounded,
          label: 'Accessibility',
          route: '/settings',
        ),
        _SupportChip(
          key: ValueKey<String>('home-secondary-voice'),
          icon: Icons.record_voice_over_rounded,
          label: 'Voice',
          route: '/settings/voice',
        ),
        _SupportChip(
          key: ValueKey<String>('home-secondary-feedback'),
          icon: Icons.feedback_rounded,
          label: 'Feedback',
          route: '/feedback/beta',
        ),
      ],
    );
  }
}

class _SupportChip extends StatelessWidget {
  const _SupportChip({
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
    return ActionChip(
      backgroundColor: ColorTokens.homeIconWell,
      side: BorderSide.none,
      avatar: Icon(
        icon,
        size: 18,
        color: ColorTokens.homeSurface,
      ),
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: ColorTokens.homeSurface,
            fontWeight: FontWeight.w800,
          ),
      onPressed: () => context.push(route),
    );
  }
}
