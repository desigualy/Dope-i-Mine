import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/user_avatar/user_avatar_profile.dart';

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
    final layers = layerResolver.layersFor(profile);

    return Semantics(
      image: true,
      label: profile.isPrivacyFirst
          ? 'Private abstract user avatar'
          : 'Soft illustrated portrait user avatar',
      child: SizedBox.square(
        dimension: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.18),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (showFallbackBase)
                CustomPaint(
                  key: const ValueKey<String>('user-avatar-fallback-base'),
                  painter: _UserAvatarFallbackPainter(profile),
                ),
              ...layers.map(
                (layer) => Image.asset(
                  layer.assetPath,
                  key: ValueKey<String>('user-avatar-layer-${layer.assetPath}'),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  semanticLabel: layer.semanticLabel,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatarFallbackPainter extends CustomPainter {
  const _UserAvatarFallbackPainter(this.profile);

  final UserAvatarProfile profile;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _backgroundColors(profile.backgroundColor),
      ).createShader(rect);
    canvas.drawRect(rect, background);

    if (profile.isPrivacyFirst) {
      _paintAbstract(canvas, size);
    } else {
      _paintHumanLike(canvas, size);
    }
  }

  void _paintAbstract(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.28;
    final aura = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          _moodColor(profile.moodStyle).withOpacity(0.65),
          _moodColor(profile.moodStyle).withOpacity(0.16),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 2.2));
    canvas.drawCircle(center, radius * 1.9, aura);

    final orb = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        colors: <Color>[
          Colors.white.withOpacity(0.94),
          _moodColor(profile.moodStyle),
          _moodColor(profile.moodStyle).withOpacity(0.72),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, orb);
  }

  void _paintHumanLike(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final shortest = size.shortestSide;
    final skin = _skinToneColor(profile.skinTone);
    final outline = Paint()..color = Colors.black.withOpacity(0.12);
    final headCenter = Offset(centerX, size.height * 0.43);
    final headWidth = size.width * _faceWidthFactor(profile.faceShape);
    final headHeight = size.height * 0.46;
    final shoulderCenter = Offset(centerX, size.height * 0.86);
    final shoulderWidth = size.width * _bodyWidthFactor(profile.bodyShape);
    final shoulderHeight = size.height * 0.33;
    final shoulderRect = Rect.fromCenter(
      center: shoulderCenter,
      width: shoulderWidth,
      height: shoulderHeight,
    );

    final softShadow = Paint()
      ..color = Colors.black.withOpacity(0.14)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shortest * 0.035);
    canvas.drawOval(
      Rect.fromCenter(
        center: shoulderCenter.translate(0, shortest * 0.035),
        width: shoulderWidth * 0.92,
        height: shoulderHeight * 0.72,
      ),
      softShadow,
    );

    if (_hasCulturalHeadwear('hijab')) {
      _paintHijabDrape(canvas, size, headCenter, headWidth, headHeight);
    }

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _clothingGradient(profile.clothingItems),
      ).createShader(shoulderRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        shoulderRect,
        Radius.circular(shortest * 0.2),
      ),
      outline,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        shoulderRect.deflate(shortest * 0.012),
        Radius.circular(shortest * 0.18),
      ),
      bodyPaint,
    );
    _paintClothingDetails(canvas, size, shoulderRect);

    final neckRect = Rect.fromCenter(
      center: Offset(centerX, size.height * 0.64),
      width: headWidth * 0.26,
      height: headHeight * 0.28,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(neckRect, Radius.circular(shortest * 0.04)),
      Paint()..color = _shade(skin, -0.08),
    );

    final earPaint = Paint()..color = _shade(skin, -0.02);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenter.dx - headWidth * 0.49, headCenter.dy),
        width: headWidth * 0.12,
        height: headHeight * 0.18,
      ),
      earPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenter.dx + headWidth * 0.49, headCenter.dy),
        width: headWidth * 0.12,
        height: headHeight * 0.18,
      ),
      earPaint,
    );

    final headRect = Rect.fromCenter(
      center: headCenter,
      width: headWidth,
      height: headHeight,
    );
    canvas.drawOval(headRect.inflate(shortest * 0.015), outline);
    final skinPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.32, -0.45),
        colors: <Color>[
          _shade(skin, 0.16),
          skin,
          _shade(skin, -0.08),
        ],
      ).createShader(headRect);
    canvas.drawOval(headRect, skinPaint);

    _paintHairOrHeadwear(canvas, size, headCenter, headWidth, headHeight);
    _paintFace(canvas, size, headCenter, headWidth, headHeight);
    _paintAccessibilityMarkers(canvas, size, headCenter, headWidth, headHeight);
  }

  void _paintClothingDetails(Canvas canvas, Size size, Rect shoulderRect) {
    final centerX = size.width / 2;
    final accent = Paint()
      ..color = const Color(0xFF2DD4BF).withOpacity(0.82)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.015;
    final seam = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.01;

    if (profile.clothingItems.contains('hoodie')) {
      final hoodRect = Rect.fromCenter(
        center: Offset(centerX, size.height * 0.69),
        width: shoulderRect.width * 0.38,
        height: shoulderRect.height * 0.34,
      );
      canvas.drawArc(hoodRect, 0.08, math.pi - 0.16, false, seam);
      canvas.drawLine(
        Offset(centerX - shoulderRect.width * 0.08, size.height * 0.71),
        Offset(centerX - shoulderRect.width * 0.1, size.height * 0.85),
        accent,
      );
      canvas.drawLine(
        Offset(centerX + shoulderRect.width * 0.08, size.height * 0.71),
        Offset(centerX + shoulderRect.width * 0.1, size.height * 0.85),
        accent,
      );
    }

    if (profile.clothingItems.contains('smart_casual') ||
        profile.clothingItems.contains('workwear')) {
      final lapel = Path()
        ..moveTo(centerX, shoulderRect.top + shoulderRect.height * 0.1)
        ..lineTo(centerX - shoulderRect.width * 0.1, shoulderRect.center.dy)
        ..lineTo(centerX, shoulderRect.bottom - shoulderRect.height * 0.08)
        ..lineTo(centerX + shoulderRect.width * 0.1, shoulderRect.center.dy)
        ..close();
      canvas.drawPath(
        lapel,
        Paint()..color = Colors.white.withOpacity(0.2),
      );
    }
  }

  void _paintHairOrHeadwear(
    Canvas canvas,
    Size size,
    Offset headCenter,
    double headWidth,
    double headHeight,
  ) {
    if (_hasCulturalHeadwear('hijab')) {
      _paintHijabFrame(canvas, size, headCenter, headWidth, headHeight);
      return;
    }

    final coveredHair = _hasCulturalHeadwear('turban') ||
        _hasCulturalHeadwear('headwrap') ||
        profile.hairStyle == 'hidden_hair';

    if (!coveredHair &&
        profile.hairType != 'bald' &&
        profile.hairType != 'not_applicable') {
      final hairColor = _hairColor(profile.hairColor);
      final hairPaint = Paint()
        ..color = hairColor
        ..style = PaintingStyle.fill;
      final hairPath = Path()
        ..moveTo(
            headCenter.dx - headWidth * 0.48, headCenter.dy - headHeight * 0.1)
        ..cubicTo(
          headCenter.dx - headWidth * 0.42,
          headCenter.dy - headHeight * 0.5,
          headCenter.dx + headWidth * 0.36,
          headCenter.dy - headHeight * 0.55,
          headCenter.dx + headWidth * 0.47,
          headCenter.dy - headHeight * 0.12,
        )
        ..quadraticBezierTo(
          headCenter.dx + headWidth * 0.17,
          headCenter.dy - headHeight * 0.27,
          headCenter.dx - headWidth * 0.02,
          headCenter.dy - headHeight * 0.23,
        )
        ..quadraticBezierTo(
          headCenter.dx - headWidth * 0.28,
          headCenter.dy - headHeight * 0.2,
          headCenter.dx - headWidth * 0.48,
          headCenter.dy - headHeight * 0.1,
        )
        ..close();
      canvas.drawPath(hairPath, hairPaint);
      _paintHairTexture(
          canvas, size, headCenter, headWidth, headHeight, hairColor);
    }

    if (_hasCulturalHeadwear('turban') || _hasCulturalHeadwear('headwrap')) {
      _paintWrappedHeadwear(canvas, size, headCenter, headWidth, headHeight);
    }
    if (_hasCulturalHeadwear('kippah')) {
      _paintKippah(canvas, size, headCenter, headWidth, headHeight);
    }
  }

  void _paintHairTexture(
    Canvas canvas,
    Size size,
    Offset headCenter,
    double headWidth,
    double headHeight,
    Color hairColor,
  ) {
    final texturePaint = Paint()
      ..color = _shade(hairColor, 0.22).withOpacity(0.82)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.01;

    if (profile.hairType == 'coily' ||
        profile.hairType == 'afro_textured' ||
        profile.hairStyle == 'afro') {
      for (var i = 0; i < 13; i += 1) {
        final angle = math.pi + (i / 12) * math.pi;
        final center = Offset(
          headCenter.dx + math.cos(angle) * headWidth * 0.34,
          headCenter.dy -
              headHeight * 0.2 +
              math.sin(angle) * headHeight * 0.12,
        );
        canvas.drawCircle(center, size.shortestSide * 0.018, texturePaint);
      }
      return;
    }

    if (profile.hairType == 'locs' ||
        profile.hairType == 'braids' ||
        profile.hairType == 'twists' ||
        profile.hairStyle == 'box_braids' ||
        profile.hairStyle == 'cornrows') {
      for (var i = 0; i < 7; i += 1) {
        final x = headCenter.dx - headWidth * 0.31 + i * headWidth * 0.105;
        canvas.drawLine(
          Offset(x, headCenter.dy - headHeight * 0.32),
          Offset(x + headWidth * 0.02, headCenter.dy + headHeight * 0.03),
          texturePaint,
        );
      }
      return;
    }

    if (profile.hairType == 'curly') {
      for (var i = 0; i < 6; i += 1) {
        final rect = Rect.fromCenter(
          center: Offset(
            headCenter.dx - headWidth * 0.26 + i * headWidth * 0.1,
            headCenter.dy - headHeight * 0.28,
          ),
          width: headWidth * 0.09,
          height: headHeight * 0.08,
        );
        canvas.drawArc(rect, 0, math.pi * 1.65, false, texturePaint);
      }
      return;
    }

    final wavePath = Path()
      ..moveTo(
          headCenter.dx - headWidth * 0.32, headCenter.dy - headHeight * 0.27)
      ..cubicTo(
        headCenter.dx - headWidth * 0.18,
        headCenter.dy - headHeight * 0.34,
        headCenter.dx - headWidth * 0.04,
        headCenter.dy - headHeight * 0.19,
        headCenter.dx + headWidth * 0.1,
        headCenter.dy - headHeight * 0.28,
      )
      ..cubicTo(
        headCenter.dx + headWidth * 0.22,
        headCenter.dy - headHeight * 0.36,
        headCenter.dx + headWidth * 0.31,
        headCenter.dy - headHeight * 0.23,
        headCenter.dx + headWidth * 0.38,
        headCenter.dy - headHeight * 0.19,
      );
    canvas.drawPath(wavePath, texturePaint);
  }

  void _paintHijabDrape(
    Canvas canvas,
    Size size,
    Offset headCenter,
    double headWidth,
    double headHeight,
  ) {
    final drape = Path()
      ..moveTo(
          headCenter.dx - headWidth * 0.58, headCenter.dy - headHeight * 0.2)
      ..quadraticBezierTo(
        headCenter.dx,
        headCenter.dy - headHeight * 0.58,
        headCenter.dx + headWidth * 0.58,
        headCenter.dy - headHeight * 0.2,
      )
      ..quadraticBezierTo(
        headCenter.dx + headWidth * 0.7,
        size.height * 0.82,
        headCenter.dx,
        size.height * 0.92,
      )
      ..quadraticBezierTo(
        headCenter.dx - headWidth * 0.7,
        size.height * 0.82,
        headCenter.dx - headWidth * 0.58,
        headCenter.dy - headHeight * 0.2,
      )
      ..close();
    canvas.drawPath(
      drape,
      Paint()..color = const Color(0xFF3730A3),
    );
  }

  void _paintHijabFrame(
    Canvas canvas,
    Size size,
    Offset headCenter,
    double headWidth,
    double headHeight,
  ) {
    final frame = Path()
      ..fillType = PathFillType.evenOdd
      ..addOval(
        Rect.fromCenter(
          center: headCenter.translate(0, -headHeight * 0.02),
          width: headWidth * 1.18,
          height: headHeight * 1.15,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: headCenter.translate(0, headHeight * 0.04),
          width: headWidth * 0.88,
          height: headHeight * 0.86,
        ),
      );
    canvas.drawPath(
      frame,
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Color(0xFF4338CA), Color(0xFF111827)],
        ).createShader(Offset.zero & size),
    );
  }

  void _paintWrappedHeadwear(
    Canvas canvas,
    Size size,
    Offset headCenter,
    double headWidth,
    double headHeight,
  ) {
    final baseColor = _hasCulturalHeadwear('turban')
        ? const Color(0xFF0F766E)
        : const Color(0xFF7C3AED);
    final wrapPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;
    final bandRect = Rect.fromCenter(
      center: headCenter.translate(0, -headHeight * 0.28),
      width: headWidth * 1.02,
      height: headHeight * 0.24,
    );
    canvas.drawOval(bandRect, wrapPaint);
    final stripe = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.012;
    canvas.drawLine(
      Offset(bandRect.left + bandRect.width * 0.12, bandRect.center.dy),
      Offset(bandRect.right - bandRect.width * 0.12, bandRect.center.dy),
      stripe,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: headCenter.translate(headWidth * 0.13, -headHeight * 0.31),
        width: headWidth * 0.24,
        height: headHeight * 0.12,
      ),
      Paint()..color = _shade(baseColor, 0.1),
    );
  }

  void _paintKippah(
    Canvas canvas,
    Size size,
    Offset headCenter,
    double headWidth,
    double headHeight,
  ) {
    final rect = Rect.fromCenter(
      center: headCenter.translate(0, -headHeight * 0.43),
      width: headWidth * 0.32,
      height: headHeight * 0.1,
    );
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF1E3A8A),
    );
  }

  void _paintFace(
    Canvas canvas,
    Size size,
    Offset headCenter,
    double headWidth,
    double headHeight,
  ) {
    final inkPaint = Paint()
      ..color = const Color(0xFF172033)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.018;
    final eyePaint = Paint()..color = const Color(0xFF172033).withOpacity(0.9);

    final leftEye = Offset(headCenter.dx - headWidth * 0.17, headCenter.dy);
    final rightEye = Offset(headCenter.dx + headWidth * 0.17, headCenter.dy);
    canvas.drawOval(
      Rect.fromCenter(
        center: leftEye,
        width: headWidth * 0.065,
        height: headHeight * 0.04,
      ),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: rightEye,
        width: headWidth * 0.065,
        height: headHeight * 0.04,
      ),
      eyePaint,
    );

    final nosePaint = Paint()
      ..color = const Color(0xFF172033).withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.009;
    canvas.drawLine(
      headCenter.translate(0, headHeight * 0.02),
      headCenter.translate(-headWidth * 0.03, headHeight * 0.12),
      nosePaint,
    );

    canvas.drawArc(
      Rect.fromCenter(
        center: headCenter.translate(0, headHeight * 0.19),
        width: headWidth * 0.22,
        height: headHeight * 0.1,
      ),
      0.15,
      math.pi - 0.3,
      false,
      inkPaint,
    );

    final browPaint = Paint()
      ..color = const Color(0xFF172033).withOpacity(0.46)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.009;
    canvas.drawLine(
      leftEye.translate(-headWidth * 0.05, -headHeight * 0.08),
      leftEye.translate(headWidth * 0.06, -headHeight * 0.09),
      browPaint,
    );
    canvas.drawLine(
      rightEye.translate(-headWidth * 0.06, -headHeight * 0.09),
      rightEye.translate(headWidth * 0.05, -headHeight * 0.08),
      browPaint,
    );
  }

  void _paintAccessibilityMarkers(
    Canvas canvas,
    Size size,
    Offset headCenter,
    double headWidth,
    double headHeight,
  ) {
    final items = profile.accessibilityItems;
    if (items.isEmpty) return;

    if (items.contains('glasses')) {
      final glassesPaint = Paint()
        ..color = const Color(0xFF0F172A).withOpacity(0.86)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.011;
      final left = Rect.fromCenter(
        center: headCenter.translate(-headWidth * 0.17, 0),
        width: headWidth * 0.18,
        height: headHeight * 0.1,
      );
      final right = Rect.fromCenter(
        center: headCenter.translate(headWidth * 0.17, 0),
        width: headWidth * 0.18,
        height: headHeight * 0.1,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            left, Radius.circular(size.shortestSide * 0.02)),
        glassesPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            right, Radius.circular(size.shortestSide * 0.02)),
        glassesPaint,
      );
      canvas.drawLine(left.centerRight, right.centerLeft, glassesPaint);
    }

    if (items.contains('hearing_aids') || items.contains('cochlear_implant')) {
      final hearingPaint = Paint()
        ..color = const Color(0xFF0EA5E9)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.shortestSide * 0.014;
      canvas.drawArc(
        Rect.fromCenter(
          center: headCenter.translate(headWidth * 0.55, headHeight * 0.02),
          width: headWidth * 0.13,
          height: headHeight * 0.18,
        ),
        math.pi * 0.72,
        math.pi * 1.1,
        false,
        hearingPaint,
      );
      if (items.contains('cochlear_implant')) {
        canvas.drawCircle(
          headCenter.translate(headWidth * 0.48, -headHeight * 0.23),
          size.shortestSide * 0.025,
          Paint()..color = const Color(0xFF22D3EE),
        );
      }
    }

    if (items.contains('sensory_headphones')) {
      final accessoryPaint = Paint()
        ..color = const Color(0xFF0EA5E9)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.width * 0.034;
      canvas.drawArc(
        Rect.fromCenter(
          center: headCenter.translate(0, -headHeight * 0.02),
          width: headWidth * 1.25,
          height: headHeight * 1.05,
        ),
        math.pi * 1.05,
        math.pi * 0.9,
        false,
        accessoryPaint,
      );
      final cupPaint = Paint()..color = const Color(0xFF0F172A);
      canvas.drawOval(
        Rect.fromCenter(
          center: headCenter.translate(-headWidth * 0.54, headHeight * 0.03),
          width: headWidth * 0.14,
          height: headHeight * 0.26,
        ),
        cupPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: headCenter.translate(headWidth * 0.54, headHeight * 0.03),
          width: headWidth * 0.14,
          height: headHeight * 0.26,
        ),
        cupPaint,
      );
    }

    if (items.contains('wheelchair')) {
      final wheelPaint = Paint()
        ..color = const Color(0xFF2563EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.012;
      final wheelCenter = Offset(size.width * 0.78, size.height * 0.84);
      canvas.drawCircle(wheelCenter, size.shortestSide * 0.065, wheelPaint);
      canvas.drawLine(
        wheelCenter.translate(
            -size.shortestSide * 0.04, -size.shortestSide * 0.04),
        wheelCenter.translate(
            size.shortestSide * 0.04, size.shortestSide * 0.04),
        wheelPaint,
      );
    }

    if (items.contains('walking_stick') || items.contains('crutches')) {
      final canePaint = Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.shortestSide * 0.012;
      canvas.drawLine(
        Offset(size.width * 0.18, size.height * 0.72),
        Offset(size.width * 0.12, size.height * 0.96),
        canePaint,
      );
      if (items.contains('crutches')) {
        canvas.drawLine(
          Offset(size.width * 0.24, size.height * 0.72),
          Offset(size.width * 0.18, size.height * 0.96),
          canePaint,
        );
      }
    }

    if (items.contains('prosthetic_arm') ||
        items.contains('prosthetic_leg') ||
        items.contains('limb_difference')) {
      final markerPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.shortestSide * 0.026;
      canvas.drawLine(
        Offset(size.width * 0.69, size.height * 0.76),
        Offset(size.width * 0.82, size.height * 0.88),
        markerPaint,
      );
    }

    if (items.contains('glucose_monitor') ||
        items.contains('insulin_pump') ||
        items.contains('medical_patch')) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width * 0.36, size.height * 0.78),
            width: size.width * 0.1,
            height: size.height * 0.06,
          ),
          Radius.circular(size.shortestSide * 0.015),
        ),
        Paint()..color = const Color(0xFFE0F2FE),
      );
    }
  }

  bool _hasCulturalHeadwear(String item) {
    return profile.culturalItems.contains(item);
  }

  List<Color> _backgroundColors(String value) {
    return switch (value) {
      'bold' => const <Color>[Color(0xFF312E81), Color(0xFF0891B2)],
      'warm' => const <Color>[Color(0xFFFFFBEB), Color(0xFFFBBF24)],
      'minimal' => const <Color>[Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
      _ => const <Color>[Color(0xFFE0F2FE), Color(0xFFCCFBF1)],
    };
  }

  Color _skinToneColor(String value) {
    return switch (value) {
      'very_light' => const Color(0xFFF8D8C6),
      'light' => const Color(0xFFEFC2A2),
      'olive' => const Color(0xFFC9A46F),
      'tan' => const Color(0xFFB98255),
      'brown' => const Color(0xFF8D5524),
      'deep_brown' => const Color(0xFF5C3422),
      'very_deep' => const Color(0xFF352018),
      _ => const Color(0xFFD8A06B),
    };
  }

  Color _hairColor(String value) {
    return switch (value) {
      'black' => const Color(0xFF111827),
      'blonde' => const Color(0xFFEAB308),
      'ginger' => const Color(0xFFC2410C),
      'grey' => const Color(0xFF9CA3AF),
      'white' => const Color(0xFFF8FAFC),
      'dyed' => const Color(0xFF9333EA),
      _ => const Color(0xFF5B341F),
    };
  }

  Color _moodColor(String value) {
    return switch (value) {
      'bright' => const Color(0xFFFBBF24),
      'playful' => const Color(0xFFEC4899),
      'minimal' => const Color(0xFF64748B),
      'bold' => const Color(0xFF7C3AED),
      _ => const Color(0xFF2DD4BF),
    };
  }

  double _bodyWidthFactor(String value) {
    return switch (value) {
      'petite' => 0.5,
      'slim' => 0.56,
      'broad' => 0.74,
      'larger_body' => 0.78,
      'muscular' => 0.76,
      _ => 0.64,
    };
  }

  double _faceWidthFactor(String value) {
    return switch (value) {
      'oval' => 0.39,
      'heart' => 0.41,
      'square' => 0.44,
      'long' => 0.37,
      _ => 0.42,
    };
  }

  List<Color> _clothingGradient(List<String> items) {
    if (items.contains('school_uniform')) {
      return const <Color>[Color(0xFF334155), Color(0xFF0F172A)];
    }
    if (items.contains('workwear') || items.contains('smart_casual')) {
      return const <Color>[Color(0xFF475569), Color(0xFF1E293B)];
    }
    if (items.contains('sportswear')) {
      return const <Color>[Color(0xFF0891B2), Color(0xFF164E63)];
    }
    if (items.contains('pyjamas')) {
      return const <Color>[Color(0xFF93C5FD), Color(0xFF6366F1)];
    }
    if (items.contains('dress') || items.contains('skirt')) {
      return const <Color>[Color(0xFFEC4899), Color(0xFF7C3AED)];
    }
    return const <Color>[Color(0xFF4C1D95), Color(0xFF111827)];
  }

  Color _shade(Color color, double amount) {
    final target = amount >= 0 ? Colors.white : Colors.black;
    final t = amount.abs().clamp(0.0, 1.0);
    return Color.fromARGB(
      color.alpha,
      (color.red + (target.red - color.red) * t).round(),
      (color.green + (target.green - color.green) * t).round(),
      (color.blue + (target.blue - color.blue) * t).round(),
    );
  }

  @override
  bool shouldRepaint(covariant _UserAvatarFallbackPainter oldDelegate) {
    return oldDelegate.profile.toJson().toString() !=
        profile.toJson().toString();
  }
}
