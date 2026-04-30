import 'package:flutter/material.dart';

import '../../domain/avatar/avatar_enums.dart';
import '../../domain/avatar/user_avatar_profile.dart';
import 'unified_user_avatar.dart';

class AvatarPreviewCard extends StatelessWidget {
  const AvatarPreviewCard({
    super.key,
    required this.profile,
    this.mood = DopeiMood.neutral,
    this.title = 'Your avatar',
    this.subtitle = 'Inclusive portrait preview',
  });

  final UserAvatarProfile profile;
  final DopeiMood mood;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            UnifiedUserAvatar(profile: profile, mood: mood, size: 112),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
