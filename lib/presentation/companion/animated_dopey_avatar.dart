import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/companion/dopei_mood.dart';
import 'dopei_orb_avatar.dart';

class AnimatedDopeyAvatar extends StatefulWidget {
  const AnimatedDopeyAvatar({
    super.key,
    required this.mood,
    this.size = 140,
    this.reducedMotion = false,
  });

  final DopeiMood mood;
  final double size;
  final bool reducedMotion;

  @override
  State<AnimatedDopeyAvatar> createState() => _AnimatedDopeyAvatarState();
}

class _AnimatedDopeyAvatarState extends State<AnimatedDopeyAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _lastReducedMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _durationFor(widget.mood),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion(reducedMotion: _shouldReduceMotion(context), reset: false);
  }

  @override
  void didUpdateWidget(covariant AnimatedDopeyAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood ||
        oldWidget.reducedMotion != widget.reducedMotion) {
      _controller.duration = _durationFor(widget.mood);
      _syncMotion(reducedMotion: _shouldReduceMotion(context));
    }
  }

  bool _shouldReduceMotion(BuildContext context) {
    return widget.reducedMotion ||
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false);
  }

  Duration _durationFor(DopeiMood mood) {
    return switch (mood) {
      DopeiMood.overwhelmed => const Duration(milliseconds: 720),
      DopeiMood.celebration => const Duration(milliseconds: 950),
      DopeiMood.happy => const Duration(milliseconds: 1050),
      DopeiMood.encouraging => const Duration(milliseconds: 900),
      DopeiMood.calm => const Duration(milliseconds: 2400),
      DopeiMood.focused => const Duration(milliseconds: 2200),
      DopeiMood.proud => const Duration(milliseconds: 1800),
      DopeiMood.neutral => const Duration(milliseconds: 1800),
    };
  }

  void _syncMotion({required bool reducedMotion, bool reset = true}) {
    if (reducedMotion) {
      _controller.stop();
      if (reset) {
        _controller.value = 0;
      }
      _lastReducedMotion = reducedMotion;
      return;
    }

    if (_lastReducedMotion == reducedMotion &&
        !reset &&
        _controller.isAnimating) {
      return;
    }

    _lastReducedMotion = reducedMotion;

    if (reset) {
      _controller.value = 0;
    }

    if (widget.mood == DopeiMood.overwhelmed) {
      _controller
        ..stop()
        ..forward(from: 0);
      return;
    }

    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = _shouldReduceMotion(context);

    if (reduce) {
      return _AvatarVisual(
        mood: widget.mood,
        size: widget.size,
        reducedMotion: true,
      );
    }

    return AnimatedSwitcher(
      key: const ValueKey<String>('animated-dopey-switcher'),
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: AnimatedBuilder(
        key: ValueKey<String>('animated-dopey-motion-${widget.mood.name}'),
        animation: _controller,
        child: _AvatarVisual(
          mood: widget.mood,
          size: widget.size,
          reducedMotion: false,
        ),
        builder: (context, child) {
          final motion = _motionFor(widget.mood, _controller.value);

          return Transform.translate(
            offset: Offset(0, motion.dy),
            child: Transform.rotate(
              angle: motion.rotation,
              child: Transform.scale(
                scale: motion.scale,
                child: _MoodGlow(
                  mood: widget.mood,
                  size: widget.size,
                  intensity: motion.glowIntensity,
                  child: child!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _AvatarMotion _motionFor(DopeiMood mood, double value) {
    return switch (mood) {
      DopeiMood.neutral => _AvatarMotion(
          dy: -3 + (value * 6),
        ),
      DopeiMood.focused => _AvatarMotion(
          dy: -1 + (value * 2),
          scale: 1.0 + (value * 0.015),
          glowIntensity: 0.22 + (value * 0.08),
        ),
      DopeiMood.happy => _AvatarMotion(
          dy: -5 + (value * 10),
          scale: 1.0 + (value * 0.035),
        ),
      DopeiMood.celebration => _AvatarMotion(
          dy: -8 + (value * 16),
          scale: 1.02 + (value * 0.06),
          rotation: -0.025 + (value * 0.05),
        ),
      DopeiMood.overwhelmed => _overwhelmedMotion(value),
      DopeiMood.calm => _AvatarMotion(
          scale: 0.985 + (value * 0.03),
        ),
      DopeiMood.encouraging => _AvatarMotion(
          scale: 1.0 + (value * 0.045),
          dy: -2 + (value * 4),
        ),
      DopeiMood.proud => _AvatarMotion(
          dy: -2 + (value * 3),
          scale: 1.0 + (value * 0.02),
          glowIntensity: 0.18 + (value * 0.06),
        ),
    };
  }

  _AvatarMotion _overwhelmedMotion(double value) {
    final settle = 1 - Curves.easeOutCubic.transform(value);
    final shake = math.sin(value * math.pi * 8) * settle;

    return _AvatarMotion(
      dy: shake * 2.4,
      rotation: shake * 0.022,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _AvatarVisual extends StatelessWidget {
  const _AvatarVisual({
    required this.mood,
    required this.size,
    required this.reducedMotion,
  });

  final DopeiMood mood;
  final double size;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return DopeiOrbAvatar(
      mood: mood,
      size: size,
      reducedMotion: reducedMotion,
    );
  }
}

class _MoodGlow extends StatelessWidget {
  const _MoodGlow({
    required this.mood,
    required this.size,
    required this.intensity,
    required this.child,
  });

  final DopeiMood mood;
  final double size;
  final double intensity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final glowColor = _glowColorFor(mood);
    if (glowColor == null || intensity <= 0) {
      return child;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: glowColor.withOpacity(intensity.clamp(0.0, 0.32)),
            blurRadius: size * 0.18,
            spreadRadius: size * 0.025,
          ),
        ],
      ),
      child: child,
    );
  }

  Color? _glowColorFor(DopeiMood mood) {
    return switch (mood) {
      DopeiMood.focused => const Color(0xFF00F0FF),
      DopeiMood.proud => const Color(0xFF9D4DFF),
      _ => null,
    };
  }
}

class _AvatarMotion {
  const _AvatarMotion({
    this.dy = 0,
    this.scale = 1,
    this.rotation = 0,
    this.glowIntensity = 0,
  });

  final double dy;
  final double scale;
  final double rotation;
  final double glowIntensity;
}
