import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../domain/avatar/avatar_enums.dart' as user_avatar;
import '../../domain/companion/dopei_mood.dart' as companion;
import '../../domain/companion/avatar_config_model.dart';
import '../avatar/current_user_avatar_provider.dart';
import '../avatar/unified_user_avatar.dart';
import '../core/widgets/dopei_avatar.dart';
import '../core/controllers/avatar_controller.dart';

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
          children: <Widget>[
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
            _MenuButton(
              title: 'My avatar',
              subtitle: userAvatarConfig.maybeWhen(
                data: (config) => config.displayLabel,
                orElse: () => 'Set up your personal portrait',
              ),
              icon: Icons.face_retouching_natural_rounded,
              color: Colors.tealAccent[700]!,
              onPressed: () => context.push('/settings/companion'),
            ),
            const SizedBox(height: 20),
            _MenuButton(
              title: 'New task',
              subtitle: 'Break down something new',
              icon: Icons.add_rounded,
              color: Colors.cyan[700]!,
              onPressed: () => context.go('/tasks/new'),
            ),
            const SizedBox(height: 12),
            _MenuButton(
              title: 'My routines',
              subtitle: 'Follow your daily patterns',
              icon: Icons.repeat_rounded,
              color: Colors.purple[700]!,
              onPressed: () => context.go('/routines'),
            ),
            const SizedBox(height: 12),
            _MenuButton(
              title: 'My progress',
              subtitle: 'See how far you\'ve come',
              icon: Icons.bar_chart_rounded,
              color: Colors.amber[700]!,
              onPressed: () => context.go('/progress'),
            ),
            const SizedBox(height: 24),
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
    return configState.maybeWhen(
      data: (config) => Center(
        child: UnifiedUserAvatar(
          key: const ValueKey<String>('home-unified-user-avatar'),
          profile: config.toUserAvatarProfile(),
          mood: _toUserAvatarMood(mood),
          size: 132,
        ),
      ),
      orElse: () => Align(
        alignment: Alignment.center,
        child: FloatingDopeiAvatar(
          mood: mood,
          size: 120,
        ),
      ),
    );
  }

  user_avatar.DopeiMood _toUserAvatarMood(companion.DopeiMood mood) {
    return switch (mood) {
      companion.DopeiMood.focused => user_avatar.DopeiMood.focused,
      companion.DopeiMood.happy => user_avatar.DopeiMood.happy,
      companion.DopeiMood.celebration => user_avatar.DopeiMood.celebration,
      companion.DopeiMood.overwhelmed => user_avatar.DopeiMood.overwhelmed,
      companion.DopeiMood.calm => user_avatar.DopeiMood.calm,
      companion.DopeiMood.encouraging => user_avatar.DopeiMood.encouraging,
      companion.DopeiMood.proud => user_avatar.DopeiMood.proud,
      companion.DopeiMood.neutral => user_avatar.DopeiMood.neutral,
    };
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
