import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../avatar_engine_v4/avatar_engine_v4.dart';
import '../avatar/current_user_avatar_provider.dart';

class UserAvatarStudioCard extends ConsumerWidget {
  const UserAvatarStudioCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(currentUserAvatarConfigProvider);
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey<String>('home-user-avatar-studio'),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.view_in_ar_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your avatar studio',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Apple/Meta-style avatars now use Avatar Engine V4. '
              'The public renderer is Rive-first; owned outfits and accessories '
              'will cache locally once downloaded.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: AvatarRiveView(
                key: const ValueKey<String>('home-avatar-studio-v4-preview'),
                config: configAsync.maybeWhen(
                  data: (config) => AvatarV4Config.starter().copyWith(
                    skinTone:
                        'legacy_${config.toUserAvatarProfile().skinTone.value.toRadixString(16)}',
                    hairPackId:
                        'hair_${config.toUserAvatarProfile().hairType.name}',
                    hairStyleId:
                        '${config.toUserAvatarProfile().hairType.name}_${config.toUserAvatarProfile().hairLength.name}',
                    hairColor:
                        'legacy_${config.toUserAvatarProfile().hairColor.value.toRadixString(16)}',
                  ),
                  orElse: AvatarV4Config.starter,
                ),
                size: 132,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Avatar Engine V4',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Rive rig required: assets/avatar_rive/base_avatar.riv',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                FilledButton.icon(
                  key: const ValueKey<String>('create-user-avatar-button'),
                  onPressed: () => context.push('/avatar/customize'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create avatar'),
                ),
                OutlinedButton.icon(
                  key: const ValueKey<String>('edit-user-avatar-button'),
                  onPressed: () => context.push('/avatar/customize'),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit avatar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
