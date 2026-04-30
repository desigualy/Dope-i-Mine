import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/avatar/avatar_enums.dart';
import '../../domain/avatar/user_avatar_profile.dart';

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
    return Semantics(
      image: true,
      label: 'Personal avatar portrait',
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(size),
          painter: PremiumPortraitAvatarPainter(
            profile: profile,
            showBackground: showBackground,
          ),
        ),
      ),
    );
  }
}

class PremiumPortraitAvatarPainter extends CustomPainter {
  PremiumPortraitAvatarPainter({
    required this.profile,
    required this.showBackground,
  });

  final UserAvatarProfile profile;
  final bool showBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final scale = shortest / 240;

    if (showBackground) {
      _drawBackground(canvas, size, shortest);
    }

    if (profile.mode == AvatarMode.privateAbstract ||
        profile.renderMode == AvatarRenderMode.abstract) {
      _drawAbstract(canvas, center, scale);
      return;
    }

    _drawBody(canvas, center, scale);
    _drawNeck(canvas, center, scale);
    _drawHairBack(canvas, center, scale);
    _drawEars(canvas, center, scale);
    _drawHead(canvas, center, scale);
    _drawSkinDetails(canvas, center, scale);
    _drawFace(canvas, center, scale);
    _drawHairFront(canvas, center, scale);
    _drawCulturalItem(canvas, center, scale);
    _drawAccessibility(canvas, center, scale);
    _drawLighting(canvas, center, scale);
  }

  void _drawBackground(Canvas canvas, Size size, double shortest) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(shortest * 0.18)),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.25,
          colors: <Color>[
            profile.accentColor.withOpacity(0.30),
            profile.backgroundColor,
            const Color(0xFF020617),
          ],
          stops: const <double>[0.0, 0.58, 1.0],
        ).createShader(rect),
    );
  }

  void _drawAbstract(Canvas canvas, Offset center, double scale) {
    canvas.drawCircle(
      center,
      62 * scale,
      Paint()
        ..color = profile.accentColor.withOpacity(0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 24 * scale),
    );

    canvas.drawCircle(
      center,
      58 * scale,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          colors: <Color>[
            Colors.white.withOpacity(0.95),
            profile.accentColor.withOpacity(0.88),
            profile.backgroundColor,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 60 * scale)),
    );
  }

  void _drawBody(Canvas canvas, Offset center, double scale) {
    final shoulderWidth = switch (profile.bodyPresentation) {
          AvatarBodyPresentation.petite => 118.0,
          AvatarBodyPresentation.slim => 130.0,
          AvatarBodyPresentation.average => 142.0,
          AvatarBodyPresentation.broad => 160.0,
          AvatarBodyPresentation.larger => 172.0,
          AvatarBodyPresentation.muscular => 168.0,
          AvatarBodyPresentation.seated => 150.0,
        } *
        scale;

    final rect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 94 * scale),
      width: shoulderWidth,
      height: 82 * scale,
    );

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(46 * scale),
        topRight: Radius.circular(46 * scale),
        bottomLeft: Radius.circular(20 * scale),
        bottomRight: Radius.circular(20 * scale),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            _shade(profile.accentColor, 0.06).withOpacity(0.96),
            _shade(profile.accentColor, -0.30).withOpacity(0.80),
            const Color(0xFF111827),
          ],
        ).createShader(rect),
    );

    if (profile.bodyPresentation == AvatarBodyPresentation.seated) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 98 * scale),
          width: 122 * scale,
          height: 62 * scale,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 * scale
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withOpacity(0.45),
      );
    }
  }

  void _drawNeck(Canvas canvas, Offset center, double scale) {
    final rect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 48 * scale),
      width: 34 * scale,
      height: 45 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(15 * scale)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            profile.skinTone,
            _shade(profile.skinTone, -0.08),
          ],
        ).createShader(rect),
    );
  }

  Rect _headRect(Offset center, double scale) {
    final width = switch (profile.faceShape) {
          AvatarFaceShape.round => 80.0,
          AvatarFaceShape.square => 82.0,
          AvatarFaceShape.heart => 76.0,
          AvatarFaceShape.long => 70.0,
          AvatarFaceShape.oval => 76.0,
        } *
        scale;

    final height = switch (profile.faceShape) {
          AvatarFaceShape.round => 86.0,
          AvatarFaceShape.square => 88.0,
          AvatarFaceShape.heart => 91.0,
          AvatarFaceShape.long => 100.0,
          AvatarFaceShape.oval => 94.0,
        } *
        scale;

    return Rect.fromCenter(
      center: Offset(center.dx, center.dy - 9 * scale),
      width: width,
      height: height,
    );
  }

  void _drawHead(Canvas canvas, Offset center, double scale) {
    final rect = _headRect(center, scale);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.32, -0.48),
          radius: 1.15,
          colors: <Color>[
            _shade(profile.skinTone, 0.13),
            _shade(profile.skinTone, 0.03),
            profile.skinTone,
            _shade(profile.skinTone, -0.10),
          ],
          stops: const <double>[0.0, 0.36, 0.74, 1.0],
        ).createShader(rect),
    );
  }

  void _drawEars(Canvas canvas, Offset center, double scale) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          _shade(profile.skinTone, 0.05),
          _shade(profile.skinTone, -0.06),
        ],
      ).createShader(
        Rect.fromCenter(
            center: center, width: 120 * scale, height: 120 * scale),
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 42 * scale, center.dy - 8 * scale),
        width: 14 * scale,
        height: 25 * scale,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 42 * scale, center.dy - 8 * scale),
        width: 14 * scale,
        height: 25 * scale,
      ),
      paint,
    );
  }

  bool get _hairHidden {
    return profile.hairType == AvatarHairType.none ||
        profile.hairLength == AvatarHairLength.bald ||
        profile.hairType == AvatarHairType.covered ||
        profile.culturalItem == AvatarCulturalItem.hijab ||
        profile.culturalItem == AvatarCulturalItem.turban ||
        profile.culturalItem == AvatarCulturalItem.headwrap;
  }

  void _drawHairBack(Canvas canvas, Offset center, double scale) {
    if (_hairHidden) return;

    final length = switch (profile.hairLength) {
          AvatarHairLength.bald => 0.0,
          AvatarHairLength.short => 18.0,
          AvatarHairLength.medium => 42.0,
          AvatarHairLength.long => 74.0,
        } *
        scale;

    if (length <= 0) return;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 5 * scale),
          width: 98 * scale,
          height: (90 * scale) + length,
        ),
        Radius.circular(46 * scale),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            _shade(profile.hairColor, 0.08),
            profile.hairColor,
            _shade(profile.hairColor, -0.14),
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + 5 * scale),
            width: 100 * scale,
            height: (90 * scale) + length,
          ),
        ),
    );
  }

  void _drawHairFront(Canvas canvas, Offset center, double scale) {
    if (_hairHidden) return;

    final hairPaint = Paint()
      ..color = profile.hairColor
      ..style = PaintingStyle.fill;

    switch (profile.hairType) {
      case AvatarHairType.straight:
      case AvatarHairType.wavy:
        _drawFlowingHair(canvas, center, scale, hairPaint);
        break;
      case AvatarHairType.curly:
      case AvatarHairType.coily:
      case AvatarHairType.afro:
        _drawCurlCrown(canvas, center, scale, hairPaint);
        break;
      case AvatarHairType.locs:
      case AvatarHairType.braids:
      case AvatarHairType.twists:
        _drawStrandHair(canvas, center, scale);
        break;
      case AvatarHairType.shaved:
        _drawShavedHair(canvas, center, scale);
        break;
      case AvatarHairType.none:
      case AvatarHairType.covered:
        break;
    }
  }

  void _drawFlowingHair(
      Canvas canvas, Offset center, double scale, Paint paint) {
    final path = Path()
      ..moveTo(center.dx - 44 * scale, center.dy - 32 * scale)
      ..quadraticBezierTo(
        center.dx - 24 * scale,
        center.dy - 68 * scale,
        center.dx + 6 * scale,
        center.dy - 60 * scale,
      )
      ..quadraticBezierTo(
        center.dx + 38 * scale,
        center.dy - 54 * scale,
        center.dx + 44 * scale,
        center.dy - 24 * scale,
      )
      ..quadraticBezierTo(
        center.dx + 18 * scale,
        center.dy - 42 * scale,
        center.dx - 44 * scale,
        center.dy - 32 * scale,
      );

    canvas.drawPath(path, paint);
  }

  void _drawCurlCrown(Canvas canvas, Offset center, double scale, Paint paint) {
    final curlCount = profile.hairType == AvatarHairType.afro ? 18 : 12;
    final radius = profile.hairType == AvatarHairType.afro ? 14.0 : 10.0;
    for (var i = 0; i < curlCount; i++) {
      final angle = math.pi + (i / (curlCount - 1)) * math.pi;
      final x = center.dx + math.cos(angle) * 42 * scale;
      final y = center.dy - 24 * scale + math.sin(angle) * 34 * scale;
      canvas.drawCircle(Offset(x, y), radius * scale, paint);
      canvas.drawCircle(
        Offset(x - 2 * scale, y - 2 * scale),
        (radius * 0.46) * scale,
        Paint()..color = _shade(profile.hairColor, 0.12).withOpacity(0.28),
      );
    }
  }

  void _drawStrandHair(Canvas canvas, Offset center, double scale) {
    final strand = Paint()
      ..color = profile.hairColor
      ..strokeWidth = 6 * scale
      ..strokeCap = StrokeCap.round;

    final highlight = Paint()
      ..color = _shade(profile.hairColor, 0.18).withOpacity(0.35)
      ..strokeWidth = 1.2 * scale
      ..strokeCap = StrokeCap.round;

    for (var i = -5; i <= 5; i++) {
      final start = Offset(center.dx + i * 8.5 * scale, center.dy - 46 * scale);
      final end = Offset(
        center.dx + i * 9.2 * scale,
        center.dy +
            (profile.hairLength == AvatarHairLength.long ? 64 : 24) * scale,
      );
      canvas.drawLine(start, end, strand);
      canvas.drawLine(
        start.translate(-1 * scale, 0),
        end.translate(-1 * scale, 0),
        highlight,
      );
    }
  }

  void _drawShavedHair(Canvas canvas, Offset center, double scale) {
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 30 * scale),
        width: 78 * scale,
        height: 44 * scale,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10 * scale
        ..strokeCap = StrokeCap.round
        ..color = profile.hairColor,
    );
  }

  void _drawFace(Canvas canvas, Offset center, double scale) {
    _drawEyes(canvas, center, scale);
    _drawBrows(canvas, center, scale);
    _drawNose(canvas, center, scale);
    _drawMouth(canvas, center, scale);
    _drawCheeks(canvas, center, scale);
  }

  void _drawEyes(Canvas canvas, Offset center, double scale) {
    final y = center.dy - 15 * scale;
    final eyePaint = Paint()..color = const Color(0xFF111827);
    final eyeHeight = profile.expression == AvatarExpression.calm ? 3.0 : 10.0;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 16 * scale, y),
        width: 10 * scale,
        height: eyeHeight * scale,
      ),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 16 * scale, y),
        width: 10 * scale,
        height: eyeHeight * scale,
      ),
      eyePaint,
    );

    if (profile.expression != AvatarExpression.calm) {
      final catchLight = Paint()..color = Colors.white.withOpacity(0.65);
      canvas.drawCircle(Offset(center.dx - 18 * scale, y - 2 * scale),
          1.8 * scale, catchLight);
      canvas.drawCircle(Offset(center.dx + 14 * scale, y - 2 * scale),
          1.8 * scale, catchLight);
    }
  }

  void _drawBrows(Canvas canvas, Offset center, double scale) {
    final y = center.dy - 30 * scale;
    final brow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3 * scale
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF111827).withOpacity(0.58);

    final tilt = switch (profile.expression) {
          AvatarExpression.focused => -4.0,
          AvatarExpression.overwhelmed => 4.0,
          AvatarExpression.tired => 3.0,
          _ => 0.0,
        } *
        scale;

    canvas.drawLine(
      Offset(center.dx - 25 * scale, y + tilt),
      Offset(center.dx - 8 * scale, y - tilt * 0.3),
      brow,
    );
    canvas.drawLine(
      Offset(center.dx + 8 * scale, y - tilt * 0.3),
      Offset(center.dx + 25 * scale, y + tilt),
      brow,
    );
  }

  void _drawNose(Canvas canvas, Offset center, double scale) {
    final nose = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale
      ..strokeCap = StrokeCap.round
      ..color = _shade(profile.skinTone, -0.24).withOpacity(0.55);

    canvas.drawLine(
      Offset(center.dx, center.dy - 7 * scale),
      Offset(center.dx - 2 * scale, center.dy + 8 * scale),
      nose,
    );
  }

  void _drawMouth(Canvas canvas, Offset center, double scale) {
    final mouth = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8 * scale
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF5A1D2A).withOpacity(0.76);

    final c = Offset(center.dx, center.dy + 22 * scale);
    final rect =
        Rect.fromCenter(center: c, width: 30 * scale, height: 15 * scale);

    switch (profile.expression) {
      case AvatarExpression.happy:
      case AvatarExpression.proud:
        canvas.drawArc(rect, 0.12, math.pi - 0.24, false, mouth);
        break;
      case AvatarExpression.calm:
        canvas.drawArc(rect, 0.38, math.pi - 0.76, false, mouth);
        break;
      case AvatarExpression.tired:
      case AvatarExpression.focused:
      case AvatarExpression.neutral:
        canvas.drawLine(
            c.translate(-9 * scale, 0), c.translate(9 * scale, 0), mouth);
        break;
      case AvatarExpression.overwhelmed:
        canvas.drawOval(
          Rect.fromCenter(center: c, width: 11 * scale, height: 8 * scale),
          Paint()..color = const Color(0xFF5A1D2A).withOpacity(0.62),
        );
        break;
    }
  }

  void _drawCheeks(Canvas canvas, Offset center, double scale) {
    if (profile.expression != AvatarExpression.happy &&
        profile.expression != AvatarExpression.proud &&
        profile.skinDetail != AvatarSkinDetail.rosacea) {
      return;
    }

    final cheek = Paint()
      ..color = const Color(0xFFFB7185).withOpacity(
        profile.skinDetail == AvatarSkinDetail.rosacea ? 0.22 : 0.14,
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 * scale);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 26 * scale, center.dy + 7 * scale),
        width: 20 * scale,
        height: 10 * scale,
      ),
      cheek,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 26 * scale, center.dy + 7 * scale),
        width: 20 * scale,
        height: 10 * scale,
      ),
      cheek,
    );
  }

  void _drawSkinDetails(Canvas canvas, Offset center, double scale) {
    switch (profile.skinDetail) {
      case AvatarSkinDetail.none:
      case AvatarSkinDetail.rosacea:
        return;
      case AvatarSkinDetail.freckles:
        final paint = Paint()
          ..color = _shade(profile.skinTone, -0.24).withOpacity(0.35);
        for (final offset in <Offset>[
          const Offset(-18, 2),
          const Offset(-10, 7),
          const Offset(12, 4),
          const Offset(21, 8),
          const Offset(4, 10),
        ]) {
          canvas.drawCircle(center + offset * scale, 1.5 * scale, paint);
        }
        break;
      case AvatarSkinDetail.vitiligo:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx + 18 * scale, center.dy - 2 * scale),
            width: 18 * scale,
            height: 26 * scale,
          ),
          Paint()..color = _shade(profile.skinTone, 0.26).withOpacity(0.55),
        );
        break;
      case AvatarSkinDetail.birthmark:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx - 23 * scale, center.dy + 9 * scale),
            width: 12 * scale,
            height: 8 * scale,
          ),
          Paint()..color = _shade(profile.skinTone, -0.18).withOpacity(0.45),
        );
        break;
      case AvatarSkinDetail.scar:
        canvas.drawLine(
          Offset(center.dx + 20 * scale, center.dy - 26 * scale),
          Offset(center.dx + 27 * scale, center.dy - 12 * scale),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6 * scale
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withOpacity(0.55),
        );
        break;
      case AvatarSkinDetail.matureLines:
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 * scale
          ..strokeCap = StrokeCap.round
          ..color = _shade(profile.skinTone, -0.20).withOpacity(0.35);
        canvas.drawLine(
          Offset(center.dx - 24 * scale, center.dy - 36 * scale),
          Offset(center.dx + 24 * scale, center.dy - 36 * scale),
          paint,
        );
        break;
    }
  }

  void _drawCulturalItem(Canvas canvas, Offset center, double scale) {
    if (profile.culturalItem == AvatarCulturalItem.none) return;

    final fabric = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          _shade(profile.accentColor, 0.12),
          profile.accentColor,
          _shade(profile.accentColor, -0.24),
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - 4 * scale),
          width: 100 * scale,
          height: 112 * scale,
        ),
      );

    switch (profile.culturalItem) {
      case AvatarCulturalItem.hijab:
      case AvatarCulturalItem.headwrap:
      case AvatarCulturalItem.turban:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(center.dx, center.dy - 6 * scale),
              width: 98 * scale,
              height: 112 * scale,
            ),
            Radius.circular(48 * scale),
          ),
          fabric,
        );
        _drawHead(canvas, center, scale);
        _drawFace(canvas, center, scale);
        break;
      case AvatarCulturalItem.kippah:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy - 53 * scale),
            width: 44 * scale,
            height: 22 * scale,
          ),
          math.pi,
          math.pi,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8 * scale
            ..strokeCap = StrokeCap.round
            ..color = profile.accentColor,
        );
        break;
      case AvatarCulturalItem.none:
        break;
    }
  }

  void _drawAccessibility(Canvas canvas, Offset center, double scale) {
    if (profile.accessibilityItems.contains(AvatarAccessibilityItem.glasses)) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * scale
        ..color = Colors.white.withOpacity(0.86);

      final y = center.dy - 15 * scale;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx - 16 * scale, y),
            width: 25 * scale,
            height: 18 * scale,
          ),
          Radius.circular(7 * scale),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx + 16 * scale, y),
            width: 25 * scale,
            height: 18 * scale,
          ),
          Radius.circular(7 * scale),
        ),
        paint,
      );
      canvas.drawLine(Offset(center.dx - 3 * scale, y),
          Offset(center.dx + 3 * scale, y), paint);
    }

    if (profile.accessibilityItems
        .contains(AvatarAccessibilityItem.sensoryHeadphones)) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - 18 * scale),
          width: 94 * scale,
          height: 86 * scale,
        ),
        math.pi * 1.08,
        math.pi * 0.84,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 * scale
          ..strokeCap = StrokeCap.round
          ..color = profile.accentColor.withOpacity(0.9),
      );
    }

    if (profile.accessibilityItems
        .contains(AvatarAccessibilityItem.hearingAidLeft)) {
      _drawSmallAid(
          canvas, Offset(center.dx - 48 * scale, center.dy - 3 * scale), scale);
    }
    if (profile.accessibilityItems
        .contains(AvatarAccessibilityItem.hearingAidRight)) {
      _drawSmallAid(
          canvas, Offset(center.dx + 48 * scale, center.dy - 3 * scale), scale);
    }
  }

  void _drawSmallAid(Canvas canvas, Offset c, double scale) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 8 * scale, height: 18 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = Colors.white.withOpacity(0.86),
    );
  }

  void _drawLighting(Canvas canvas, Offset center, double scale) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 18 * scale, center.dy - 31 * scale),
        width: 28 * scale,
        height: 12 * scale,
      ),
      Paint()
        ..color = Colors.white.withOpacity(0.14)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * scale),
    );

    canvas.drawCircle(
      center,
      70 * scale,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale
        ..color = profile.accentColor.withOpacity(0.20)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * scale),
    );
  }

  Color _shade(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(covariant PremiumPortraitAvatarPainter oldDelegate) {
    return oldDelegate.profile != profile ||
        oldDelegate.showBackground != showBackground;
  }
}
