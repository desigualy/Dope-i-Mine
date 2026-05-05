import 'package:flutter/material.dart';

import '../../domain/avatar/avatar_enums.dart';
import '../../domain/avatar/user_avatar_profile.dart';
import 'avatar_engine_bridge.dart';

class UnifiedUserAvatar extends StatelessWidget {
  const UnifiedUserAvatar({
    super.key,
    required this.profile,
    this.mood = DopeiMood.neutral,
    this.size = 180,
    this.reducedMotion = false,
  });

  final UserAvatarProfile profile;
  final DopeiMood mood;
  final double size;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return AvatarEngineBridge(profile: profile, size: size);
  }
}
