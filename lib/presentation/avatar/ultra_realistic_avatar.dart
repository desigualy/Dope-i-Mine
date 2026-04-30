import 'dart:io';

import 'package:flutter/material.dart';

class UltraRealisticAvatar extends StatelessWidget {
  const UltraRealisticAvatar({
    super.key,
    this.localPath,
    this.remoteUrl,
    this.size = 180,
    this.moodGlow = Colors.cyanAccent,
    this.placeholder,
  }) : assert(
          localPath != null || remoteUrl != null || placeholder != null,
          'Provide localPath, remoteUrl, or placeholder.',
        );

  final String? localPath;
  final String? remoteUrl;
  final double size;
  final Color moodGlow;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();

    return Semantics(
      image: true,
      label: 'Ultra realistic avatar portrait',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: moodGlow.withOpacity(0.45),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(child: image),
      ),
    );
  }

  Widget _buildImage() {
    if (localPath != null && localPath!.isNotEmpty) {
      return Image.file(
        File(localPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    if (remoteUrl != null && remoteUrl!.isNotEmpty) {
      return Image.network(
        remoteUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return placeholder ??
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                moodGlow.withOpacity(0.8),
                const Color(0xFF111827),
              ],
            ),
          ),
          child: const Center(
            child: Icon(Icons.person, color: Colors.white, size: 48),
          ),
        );
  }
}

class AnimatedUltraRealisticAvatar extends StatefulWidget {
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
  State<AnimatedUltraRealisticAvatar> createState() =>
      _AnimatedUltraRealisticAvatarState();
}

class _AnimatedUltraRealisticAvatarState
    extends State<AnimatedUltraRealisticAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = widget.reducedMotion ||
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false);

    final child = UltraRealisticAvatar(
      localPath: widget.localPath,
      remoteUrl: widget.remoteUrl,
      size: widget.size,
      moodGlow: widget.moodGlow,
      placeholder: widget.placeholder,
    );

    if (reducedMotion) {
      return child;
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, avatar) {
        final scale = 0.985 + controller.value * 0.03;
        return Transform.scale(scale: scale, child: avatar);
      },
      child: child,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
