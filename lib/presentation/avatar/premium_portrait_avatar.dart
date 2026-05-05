import 'package:flutter/material.dart';

import '../../domain/avatar/user_avatar_profile.dart';
import 'avatar_engine_bridge.dart';

class PremiumPortraitAvatar extends StatelessWidget {
  const PremiumPortraitAvatar({
    super.key,
    required this.profile,
    this.size = 180,
    this.showBackground = true,
  });

  final UserAvatarProfile profile;
  final double size;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    return AvatarEngineBridge(profile: profile, size: size);
  }
}
