import 'package:flutter/material.dart';

import '../../domain/avatar_v3/avatar_v3_migration.dart';
import '../avatar_v3/avatar_v3_renderer.dart';

class AvatarEngineBridge extends StatelessWidget {
  const AvatarEngineBridge({
    super.key,
    this.profile,
    this.size = 180,
  });

  final Object? profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AvatarV3Renderer(
      profile: AvatarV3Migration.fromAny(profile),
      size: size <= 0 ? 180 : size,
    );
  }
}
