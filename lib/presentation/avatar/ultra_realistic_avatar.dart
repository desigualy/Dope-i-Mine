import 'package:flutter/material.dart';

import '../../domain/avatar_v3/avatar_v3_migration.dart';
import '../avatar_v3/avatar_v3_renderer.dart';

class UltraRealisticAvatar extends StatelessWidget {
  const UltraRealisticAvatar({
    super.key,
    this.localPath,
    this.remoteUrl,
    this.size = 180,
    this.moodGlow = Colors.cyanAccent,
    this.placeholder,
  });

  final String? localPath;
  final String? remoteUrl;
  final double size;
  final Color moodGlow;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    return AvatarV3Renderer(
      profile: AvatarV3Migration.defaultReferenceProfile,
      size: size,
    );
  }
}

class AnimatedUltraRealisticAvatar extends StatelessWidget {
  const AnimatedUltraRealisticAvatar({
    super.key,
    this.localPath,
    this.remoteUrl,
    required this.moodGlow,
    this.size = 180,
    this.reducedMotion = false,
    this.placeholder,
  });

  final String? localPath;
  final String? remoteUrl;
  final Color moodGlow;
  final double size;
  final bool reducedMotion;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    return UltraRealisticAvatar(
      localPath: localPath,
      remoteUrl: remoteUrl,
      size: size,
      moodGlow: moodGlow,
      placeholder: placeholder,
    );
  }
}
