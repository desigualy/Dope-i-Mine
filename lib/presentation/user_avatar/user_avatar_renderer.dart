import 'package:flutter/material.dart';

import '../../domain/user_avatar/user_avatar_profile.dart';
import '../avatar/avatar_engine_bridge.dart';

class UserAvatarRenderer extends StatelessWidget {
  const UserAvatarRenderer({
    super.key,
    required this.profile,
    this.size = 160,
    this.layerResolver = const UserAvatarLayerResolver(),
    this.showFallbackBase = true,
  });

  final UserAvatarProfile profile;
  final double size;
  final UserAvatarLayerResolver layerResolver;
  final bool showFallbackBase;

  @override
  Widget build(BuildContext context) {
    return AvatarEngineBridge(profile: profile, size: size);
  }
}

class UserAvatarLayerResolver {
  const UserAvatarLayerResolver();

  List<UserAvatarLayer> layersFor(UserAvatarProfile profile) {
    return const <UserAvatarLayer>[];
  }
}

class UserAvatarLayer {
  const UserAvatarLayer({
    required this.id,
    required this.assetPath,
  });

  final String id;
  final String assetPath;
}
