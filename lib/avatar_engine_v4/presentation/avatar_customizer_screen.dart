import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/avatar_v4_config.dart';
import '../providers/avatar_v4_providers.dart';
import 'avatar_reference_image_panel.dart';
import 'avatar_rive_view.dart';

class AvatarCustomizerScreen extends ConsumerWidget {
  const AvatarCustomizerScreen({
    super.key,
    this.config = const AvatarV4Config(),
  });

  final AvatarV4Config config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(avatarV4CurrentUserIdProvider);
    final isOnline = ref.watch(avatarV4OnlineProvider).maybeWhen(
          data: (value) => value,
          orElse: () => false,
        );
    final referenceImageService =
        ref.watch(avatarV4ReferenceImageServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Center(
            child: AvatarRiveView(
              config: config,
              size: 220,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Avatar Engine V4 is ready for Rive art packs.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Changing avatar appearance requires online sync. Already-owned outfits and accessories can be used from local cache once downloaded.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AvatarReferenceImagePanel(
            userId: userId,
            isOnline: isOnline,
            service: referenceImageService,
          ),
        ],
      ),
    );
  }
}
