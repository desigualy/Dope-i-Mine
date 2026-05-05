import 'package:flutter/material.dart';

import '../../domain/avatar_v3/avatar_v3_profile.dart';
import 'avatar_v3_renderer.dart';

class AvatarV3PreviewCard extends StatelessWidget {
  const AvatarV3PreviewCard({
    super.key,
    required this.profile,
    this.title = 'Your Avatar V3',
    this.subtitle = 'Local Apple/Meta-style asset avatar',
  });

  final AvatarV3Profile profile;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey<String>('avatar-v3-preview-card'),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            AvatarV3Renderer(profile: profile, size: 120),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
