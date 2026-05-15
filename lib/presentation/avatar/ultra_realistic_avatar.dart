import 'dart:io' show File;

import 'package:flutter/material.dart';

import '../../avatar_engine_v4/domain/avatar_v4_config.dart';
import '../../avatar_engine_v4/presentation/avatar_rive_view.dart';

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
    final safeSize = size <= 0 ? 180.0 : size;
    final local = localPath?.trim();
    final remote = remoteUrl?.trim();

    return DecoratedBox(
      key: const ValueKey<String>('avatar-v4-ultra-realistic-avatar'),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: moodGlow.withOpacity(.28),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: SizedBox.square(
          dimension: safeSize,
          child: _imageOrFallback(
            localPath: local,
            remoteUrl: remote,
            size: safeSize,
          ),
        ),
      ),
    );
  }

  Widget _imageOrFallback({
    required String? localPath,
    required String? remoteUrl,
    required double size,
  }) {
    if (localPath != null && localPath.isNotEmpty) {
      return Image.file(
        File(localPath),
        key: const ValueKey<String>('avatar-v4-ultra-realistic-local-image'),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(size),
      );
    }

    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return Image.network(
        remoteUrl,
        key: const ValueKey<String>('avatar-v4-ultra-realistic-remote-image'),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(size),
      );
    }

    return _fallback(size);
  }

  Widget _fallback(double size) {
    return placeholder ??
        AvatarRiveView(
          key: const ValueKey<String>('avatar-v4-ultra-realistic-rive-fallback'),
          config: AvatarV4Config.starter(),
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
    final avatar = UltraRealisticAvatar(
      localPath: localPath,
      remoteUrl: remoteUrl,
      size: size,
      moodGlow: moodGlow,
      placeholder: placeholder,
    );

    if (reducedMotion) return avatar;

    return AnimatedScale(
      key: const ValueKey<String>('avatar-v4-animated-ultra-realistic-avatar'),
      scale: 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: avatar,
    );
  }
}
