import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ringlet_hair_geometry.dart';

class RingletCurlPainter extends CustomPainter {
  const RingletCurlPainter({
    required this.curls,
    required this.baseColor,
    required this.shadowColor,
    required this.highlightColor,
    this.paintGuideZones = false,
  });

  final List<RingletAfroCurl> curls;
  final Color baseColor;
  final Color shadowColor;
  final Color highlightColor;
  final bool paintGuideZones;

  @override
  void paint(Canvas canvas, Size size) {
    if (paintGuideZones) {
      _paintGuideZones(canvas, size);
    }

    final containsBackLayer = curls.any(
      (curl) =>
          curl.region == RingletAfroRegion.rearHalo ||
          curl.region == RingletAfroRegion.leftSideVolume ||
          curl.region == RingletAfroRegion.rightSideVolume,
    );

    final containsFrontLayer = curls.any(
      (curl) =>
          curl.region == RingletAfroRegion.crownVolume ||
          curl.region == RingletAfroRegion.leftTemple ||
          curl.region == RingletAfroRegion.rightTemple,
    );

    if (containsBackLayer) {
      _paintBackHairMass(canvas, size);
    }

    if (containsFrontLayer) {
      _paintFrontHairlineMass(canvas, size);
    }

    final sorted = [...curls]..sort((a, b) => a.depth.compareTo(b.depth));

    for (final curl in sorted) {
      _paintCurlShadow(canvas, size, curl);
    }

    for (final curl in sorted) {
      _paintCurlBody(canvas, size, curl);
      _paintCurlHighlight(canvas, size, curl);
    }
  }

  void _paintBackHairMass(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final mass = Path()
      ..moveTo(.28 * w, .26 * h)
      ..cubicTo(.26 * w, .17 * h, .37 * w, .10 * h, .50 * w, .11 * h)
      ..cubicTo(.64 * w, .10 * h, .74 * w, .18 * h, .72 * w, .29 * h)
      ..cubicTo(.84 * w, .38 * h, .84 * w, .64 * h, .72 * w, .74 * h)
      ..cubicTo(.65 * w, .80 * h, .57 * w, .76 * h, .56 * w, .68 * h)
      ..cubicTo(.66 * w, .64 * h, .68 * w, .45 * h, .63 * w, .32 * h)
      ..cubicTo(.58 * w, .25 * h, .42 * w, .25 * h, .37 * w, .32 * h)
      ..cubicTo(.32 * w, .45 * h, .34 * w, .64 * h, .44 * w, .68 * h)
      ..cubicTo(.43 * w, .76 * h, .35 * w, .80 * h, .28 * w, .74 * h)
      ..cubicTo(.16 * w, .64 * h, .16 * w, .39 * h, .28 * w, .26 * h)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        center: const Alignment(-.25, -.45),
        radius: .85,
        colors: <Color>[
          highlightColor.withAlpha(210),
          baseColor,
          shadowColor,
        ],
        stops: const <double>[0, .48, 1],
      ).createShader(Offset.zero & size);

    canvas.drawPath(mass, paint);

    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * .018
      ..strokeCap = StrokeCap.round
      ..color = shadowColor.withAlpha(120);

    canvas.drawPath(mass, shadow);
  }

  void _paintFrontHairlineMass(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final crown = Path()
      ..moveTo(.31 * w, .27 * h)
      ..cubicTo(.35 * w, .16 * h, .46 * w, .10 * h, .58 * w, .14 * h)
      ..cubicTo(.66 * w, .16 * h, .71 * w, .22 * h, .72 * w, .29 * h)
      ..cubicTo(.62 * w, .24 * h, .52 * w, .22 * h, .42 * w, .24 * h)
      ..cubicTo(.37 * w, .25 * h, .34 * w, .26 * h, .31 * w, .27 * h)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          highlightColor.withAlpha(220),
          baseColor,
          shadowColor.withAlpha(230),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(crown, paint);
  }

  void _paintCurlShadow(Canvas canvas, Size size, RingletAfroCurl curl) {
    final center = Offset(curl.center.dx * size.width, curl.center.dy * size.height);
    final radius = curl.radius * size.shortestSide;
    final rect = Rect.fromCircle(center: center.translate(0, radius * .08), radius: radius * 1.03);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = curl.strokeWidth * size.shortestSide * 1.18
      ..strokeCap = StrokeCap.round
      ..color = shadowColor.withAlpha(118);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(curl.rotation);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(rect, math.pi * .10, math.pi * 1.55, false, paint);
    canvas.restore();
  }

  void _paintCurlBody(Canvas canvas, Size size, RingletAfroCurl curl) {
    final center = Offset(curl.center.dx * size.width, curl.center.dy * size.height);
    final radius = curl.radius * size.shortestSide;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = curl.strokeWidth * size.shortestSide
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: <Color>[
          shadowColor,
          baseColor,
          highlightColor,
          baseColor,
          shadowColor,
        ],
        stops: const <double>[0, .25, .46, .70, 1],
      ).createShader(rect);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(curl.rotation);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(rect, math.pi * .10, math.pi * 1.56, false, paint);
    canvas.restore();
  }

  void _paintCurlHighlight(Canvas canvas, Size size, RingletAfroCurl curl) {
    final center = Offset(curl.center.dx * size.width, curl.center.dy * size.height);
    final radius = curl.radius * size.shortestSide * .78;
    final rect = Rect.fromCircle(center: center.translate(-radius * .08, -radius * .12), radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = curl.strokeWidth * size.shortestSide * .25
      ..strokeCap = StrokeCap.round
      ..color = highlightColor.withAlpha(145);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(curl.rotation - .18);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(rect, math.pi * .18, math.pi * .45, false, paint);
    canvas.restore();
  }

  void _paintGuideZones(Canvas canvas, Size size) {
    final safe = Rect.fromLTWH(
      RingletAfroGeometry.faceSafeZone.left * size.width,
      RingletAfroGeometry.faceSafeZone.top * size.height,
      RingletAfroGeometry.faceSafeZone.width * size.width,
      RingletAfroGeometry.faceSafeZone.height * size.height,
    );
    final exclusion = Rect.fromLTWH(
      RingletAfroGeometry.mouthChinExclusionZone.left * size.width,
      RingletAfroGeometry.mouthChinExclusionZone.top * size.height,
      RingletAfroGeometry.mouthChinExclusionZone.width * size.width,
      RingletAfroGeometry.mouthChinExclusionZone.height * size.height,
    );

    canvas.drawRect(
      safe,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x6600FF00),
    );
    canvas.drawRect(
      exclusion,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x66FF0000),
    );
  }

  @override
  bool shouldRepaint(covariant RingletCurlPainter oldDelegate) {
    return oldDelegate.curls != curls ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.paintGuideZones != paintGuideZones;
  }
}
