import 'package:flutter/material.dart';

import '../../domain/avatar_v3/avatar_v3_migration.dart';
import '../../domain/avatar_v3/avatar_v3_options.dart';
import '../../domain/avatar_v3/avatar_v3_profile.dart';
import 'avatar_v3_layer_stack.dart';

class AvatarV3Renderer extends StatelessWidget {
  const AvatarV3Renderer({
    super.key,
    AvatarV3Profile? profile,
    this.size = 180,
  }) : profile = profile ?? AvatarV3Migration.defaultReferenceProfile;

  final AvatarV3Profile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalized = AvatarV3Options.normalize(profile);
    final safeSize = size <= 0 ? 180.0 : size;

    return Semantics(
      image: true,
      label: 'Avatar V3 Apple Meta style avatar',
      child: RepaintBoundary(
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            width: safeSize,
            height: safeSize,
          ),
          child: SizedBox.square(
            key: const ValueKey<String>('avatar-v3-renderer'),
            dimension: safeSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(safeSize * 0.18),
                color: const Color(0xFFEDE9FE),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(safeSize * 0.18),
                child: AvatarV3LayerStack(profile: normalized),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
