import 'package:flutter/material.dart';

import '../../domain/avatar/avatar_enums.dart';
import '../../domain/avatar/user_avatar_profile.dart';
import 'avatar_mood_mapper.dart';
import 'premium_portrait_avatar.dart';
import 'ultra_realistic_avatar.dart';

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
    final glow = AvatarMoodMapper.glowForDopeiMood(mood);

    switch (profile.renderMode) {
      case AvatarRenderMode.ultraRealistic:
        return AnimatedUltraRealisticAvatar(
          localPath: profile.localImagePath,
          remoteUrl: profile.generatedImageUrl,
          moodGlow: glow,
          size: size,
          reducedMotion: reducedMotion,
          placeholder: PremiumPortraitAvatar(
            profile: profile.copyWith(
              renderMode: AvatarRenderMode.premiumPortrait,
              expression: AvatarMoodMapper.expressionForDopeiMood(mood),
            ),
            size: size,
          ),
        );
      case AvatarRenderMode.abstract:
      case AvatarRenderMode.illustrated:
      case AvatarRenderMode.premiumPortrait:
        return PremiumPortraitAvatar(
          profile: profile.copyWith(
            expression: AvatarMoodMapper.expressionForDopeiMood(mood),
          ),
          size: size,
        );
    }
  }
}
