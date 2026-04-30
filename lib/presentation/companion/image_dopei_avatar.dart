import 'package:flutter/material.dart';

import '../../domain/avatar/avatar_enums.dart';

class ImageDopeiAvatar extends StatelessWidget {
  const ImageDopeiAvatar({
    super.key,
    required this.mood,
    this.size = 148,
    this.reducedMotion = false,
  });

  final DopeiMood mood;
  final double size;
  final bool reducedMotion;

  String get assetPath {
    switch (mood) {
      case DopeiMood.focused:
        return 'assets/avatar/dopey/focused.png';
      case DopeiMood.happy:
        return 'assets/avatar/dopey/happy.png';
      case DopeiMood.celebration:
        return 'assets/avatar/dopey/celebration.png';
      case DopeiMood.overwhelmed:
        return 'assets/avatar/dopey/overwhelmed.png';
      case DopeiMood.calm:
        return 'assets/avatar/dopey/calm.png';
      case DopeiMood.encouraging:
        return 'assets/avatar/dopey/encouraging.png';
      case DopeiMood.proud:
        return 'assets/avatar/dopey/proud.png';
      case DopeiMood.neutral:
        return 'assets/avatar/dopey/neutral.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reducedMotion) {
      return _image();
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey(mood),
      tween: Tween<double>(begin: 0.96, end: 1.0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: _image(),
    );
  }

  Widget _image() {
    return Semantics(
      image: true,
      label: mood.semanticLabel,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
