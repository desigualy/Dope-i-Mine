import 'package:flutter/material.dart';

import '../../domain/avatar_v3/avatar_v3_options.dart';
import '../../domain/avatar_v3/avatar_v3_profile.dart';
import 'avatar_v3_layer_stack.dart';

class AvatarV3Renderer extends StatelessWidget {
  const AvatarV3Renderer({
    super.key,
    required this.profile,
    this.size = 180,
  });

  final AvatarV3Profile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalized = AvatarV3Options.normalize(profile);

    return Semantics(
      image: true,
      label: 'Avatar V3 Apple Meta style avatar',
      child: SizedBox.square(
        key: const ValueKey<String>('avatar-v3-renderer'),
        dimension: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.18),
          child: AvatarV3LayerStack(profile: normalized),
        ),
      ),
    );
  }
}
