import 'package:flutter/material.dart';

import '../../avatar_engine_v4/domain/avatar_v4_profile_mapper.dart';
import '../../avatar_engine_v4/presentation/avatar_rive_view.dart';

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
    final safeSize = size <= 0 ? 180.0 : size;

    return SizedBox.square(
      key: const ValueKey<String>('avatar-v4-engine-bridge'),
      dimension: safeSize,
      child: AvatarRiveView(
        key: const ValueKey<String>('avatar-v4-engine-bridge-rive-view'),
        config: AvatarV4ProfileMapper.fromAny(profile),
        size: safeSize,
      ),
    );
  }
}
