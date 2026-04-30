import 'package:flutter/material.dart';
import '../../../domain/companion/dopei_mood.dart';
import '../../companion/animated_dopey_avatar.dart';
export '../../../domain/companion/dopei_mood.dart';

class DopeiAvatar extends StatelessWidget {
  const DopeiAvatar({
    super.key,
    required this.mood,
    this.size = 120,
    this.reducedMotion = false,
  });

  final DopeiMood mood;
  final double size;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return AnimatedDopeyAvatar(
      mood: mood,
      size: size,
      reducedMotion: reducedMotion,
    );
  }
}

class FloatingDopeiAvatar extends StatelessWidget {
  const FloatingDopeiAvatar({
    super.key,
    required this.mood,
    this.size = 120,
    this.reducedMotion = false,
  });

  final DopeiMood mood;
  final double size;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return DopeiAvatar(
      mood: mood,
      size: size,
      reducedMotion: reducedMotion,
    );
  }
}
