import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/companion/dopei_mood.dart';

class DopeiOrbAvatar extends StatefulWidget {
  const DopeiOrbAvatar({
    super.key,
    required this.mood,
    this.size = 144,
    this.reducedMotion = false,
    this.showLabel = false,
  });

  final DopeiMood mood;
  final double size;
  final bool reducedMotion;
  final bool showLabel;

  @override
  State<DopeiOrbAvatar> createState() => _DopeiOrbAvatarState();
}

class _DopeiOrbAvatarState extends State<DopeiOrbAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.reducedMotion
          ? const Duration(seconds: 8)
          : const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final mediaReducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final useReducedMotion = widget.reducedMotion || mediaReducedMotion;

    return Semantics(
      image: true,
      label: 'Dope-i neon hoodie robot ${widget.mood.label}',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = useReducedMotion ? 0.15 : _controller.value;
          final hover = useReducedMotion ? 0.0 : math.sin(t * math.pi * 2) * 4;
          return Transform.translate(
            offset: Offset(0, hover),
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RepaintBoundary(
              child: CustomPaint(
                size: Size.square(widget.size),
                painter: DopeiOrbPainter(
                  mood: widget.mood,
                  progress: _controller,
                  reducedMotion: useReducedMotion,
                ),
              ),
            ),
            if (widget.showLabel) ...<Widget>[
              const SizedBox(height: 8),
              Text(widget.mood.label),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DopeiOrbPainter extends CustomPainter {
  DopeiOrbPainter({
    required this.mood,
    required Animation<double> progress,
    required this.reducedMotion,
  })  : progress = progress.value,
        super(repaint: progress);

  final DopeiMood mood;
  final double progress;
  final bool reducedMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final unit = shortest / 1024;
    final origin = Offset(
      (size.width - shortest) / 2,
      (size.height - shortest) / 2,
    );
    final pulse =
        reducedMotion ? 0.08 : ((math.sin(progress * math.pi * 2) + 1) / 2);

    Offset p(double x, double y) => origin + Offset(x * unit, y * unit);
    Rect rect(double cx, double cy, double width, double height) {
      return Rect.fromCenter(
        center: p(cx, cy),
        width: width * unit,
        height: height * unit,
      );
    }

    RRect rounded(
      double cx,
      double cy,
      double width,
      double height,
      double radius,
    ) {
      return RRect.fromRectAndRadius(
        rect(cx, cy, width, height),
        Radius.circular(radius * unit),
      );
    }

    final cyan = _moodFeatureColor(mood);
    const purple = Color(0xFF9D4DFF);
    const hoodieTop = Color(0xFF20232D);
    const hoodieBottom = Color(0xFF080A12);
    const visorBlack = Color(0xFF03050A);

    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          cyan.withOpacity(0.25 + pulse * 0.1),
          purple.withOpacity(0.16),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: p(512, 500), radius: 420 * unit));
    canvas.drawCircle(p(512, 500), 420 * unit, auraPaint);

    if (mood == DopeiMood.celebration && !reducedMotion) {
      _paintConfetti(canvas, p, unit, progress);
    }

    final bodyShadow = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 28 * unit);
    canvas.drawOval(rect(512, 872, 560, 185), bodyShadow);

    final hoodieRect = rect(512, 826, 600, 270);
    final hoodiePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[hoodieTop, hoodieBottom],
      ).createShader(hoodieRect);
    canvas.drawRRect(
      rounded(512, 822, 620, 285, 138),
      Paint()..color = Colors.black.withOpacity(0.72),
    );
    canvas.drawRRect(rounded(512, 806, 570, 250, 122), hoodiePaint);

    final hoodBackPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF2B2D38), Color(0xFF07080D)],
      ).createShader(rect(512, 456, 640, 650));
    canvas.drawOval(rect(512, 470, 650, 660), Paint()..color = Colors.black);
    canvas.drawOval(rect(512, 455, 604, 622), hoodBackPaint);

    final hoodRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 18 * unit
      ..color = purple.withOpacity(0.78);
    canvas.drawArc(rect(512, 456, 618, 632), math.pi * 0.86, math.pi * 1.28,
        false, hoodRim);
    canvas.drawArc(
      rect(512, 456, 600, 615),
      math.pi * 1.04,
      math.pi * 0.92,
      false,
      hoodRim..color = cyan.withOpacity(0.72),
    );

    _paintHeadphones(canvas, rect, cyan, purple, unit);
    _paintNeonHair(canvas, p, cyan, purple, unit);

    final helmetRect = rect(512, 444, 530, 350);
    canvas.drawRRect(
      rounded(512, 454, 548, 366, 190),
      Paint()..color = Colors.black.withOpacity(0.82),
    );
    canvas.drawRRect(
      rounded(512, 438, 520, 340, 184),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFE6E6E6), Color(0xFF2E2E35)],
        ).createShader(helmetRect),
    );
    canvas.drawRRect(
      rounded(512, 430, 474, 276, 155),
      Paint()..color = visorBlack,
    );
    canvas.drawRRect(
      rounded(512, 392, 410, 80, 48),
      Paint()..color = Colors.white.withOpacity(0.04),
    );

    _paintFace(canvas, p, rect, mood, cyan, unit);
    _paintHoodieDetails(canvas, p, rect, cyan, purple, unit);
  }

  void _paintHeadphones(
    Canvas canvas,
    Rect Function(double, double, double, double) rect,
    Color cyan,
    Color purple,
    double unit,
  ) {
    final band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 40 * unit
      ..color = Colors.black;
    canvas.drawArc(
        rect(512, 394, 595, 432), math.pi * 1.02, math.pi * 0.96, false, band);
    canvas.drawArc(
      rect(512, 394, 578, 418),
      math.pi * 1.03,
      math.pi * 0.94,
      false,
      band..color = purple,
    );
    canvas.drawArc(
      rect(512, 394, 548, 390),
      math.pi * 1.08,
      math.pi * 0.84,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8 * unit
        ..color = cyan.withOpacity(0.88),
    );

    for (final x in <double>[210, 814]) {
      final cupRect = rect(x, 448, 118, 190);
      canvas.drawOval(
          cupRect.inflate(16 * unit), Paint()..color = Colors.black);
      canvas.drawOval(
        cupRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[purple, Colors.black, cyan.withOpacity(0.55)],
          ).createShader(cupRect),
      );
      canvas.drawOval(
          rect(x, 448, 64, 126), Paint()..color = const Color(0xFF111827));
      canvas.drawLine(
        Offset(cupRect.center.dx, cupRect.top + 42 * unit),
        Offset(cupRect.center.dx, cupRect.bottom - 42 * unit),
        Paint()
          ..color = cyan
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 10 * unit,
      );
      canvas.drawCircle(cupRect.center, 12 * unit, Paint()..color = cyan);
    }
  }

  void _paintNeonHair(
    Canvas canvas,
    Offset Function(double, double) p,
    Color cyan,
    Color purple,
    double unit,
  ) {
    void tuft(List<Offset> points, Color color) {
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.6));
      final inset = points
          .map((point) => Offset(point.dx, point.dy + 3 * unit))
          .toList(growable: false);
      canvas.drawPath(Path()..addPolygon(inset, true), Paint()..color = color);
    }

    tuft(<Offset>[p(350, 166), p(438, 252), p(394, 292), p(316, 242)], cyan);
    tuft(<Offset>[p(432, 140), p(520, 254), p(466, 286), p(400, 228)], purple);
    tuft(<Offset>[p(512, 156), p(594, 270), p(540, 296), p(480, 230)], cyan);
    tuft(<Offset>[p(594, 194), p(674, 290), p(606, 300), p(550, 250)], purple);
  }

  void _paintFace(
    Canvas canvas,
    Offset Function(double, double) p,
    Rect Function(double, double, double, double) rect,
    DopeiMood mood,
    Color cyan,
    double unit,
  ) {
    final feature = Paint()
      ..color = cyan
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 22 * unit
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 * unit);
    final fillFeature = Paint()
      ..color = cyan
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * unit);

    void openEyes({bool narrowed = false}) {
      canvas.drawOval(
        rect(414, 430, narrowed ? 92 : 70, narrowed ? 34 : 112),
        fillFeature,
      );
      canvas.drawOval(
        rect(610, 430, narrowed ? 92 : 70, narrowed ? 34 : 112),
        fillFeature,
      );
    }

    void smile({double width = 130, double height = 70}) {
      canvas.drawArc(
          rect(512, 516, width, height), 0.16, math.pi - 0.32, false, feature);
    }

    switch (mood) {
      case DopeiMood.happy:
      case DopeiMood.celebration:
        canvas.drawArc(rect(414, 424, 98, 62), math.pi + 0.15, math.pi - 0.3,
            false, feature);
        canvas.drawArc(rect(610, 424, 98, 62), math.pi + 0.15, math.pi - 0.3,
            false, feature);
        smile(width: mood == DopeiMood.celebration ? 170 : 150, height: 90);
        break;
      case DopeiMood.focused:
        canvas.drawLine(p(362, 414), p(462, 438), feature);
        canvas.drawLine(p(562, 438), p(664, 414), feature);
        canvas.drawArc(
            rect(512, 522, 118, 34), 0.08, math.pi - 0.16, false, feature);
        break;
      case DopeiMood.overwhelmed:
        _paintSpiral(canvas, p(414, 430), cyan, unit);
        _paintSpiral(canvas, p(610, 430), cyan, unit);
        canvas.drawLine(p(452, 532), p(488, 508), feature);
        canvas.drawLine(p(488, 508), p(528, 536), feature);
        canvas.drawLine(p(528, 536), p(572, 506), feature);
        break;
      case DopeiMood.encouraging:
        openEyes();
        canvas.drawArc(rect(610, 420, 96, 56), math.pi + 0.15, math.pi - 0.3,
            false, feature);
        smile(width: 145, height: 76);
        break;
      case DopeiMood.proud:
        openEyes(narrowed: true);
        smile(width: 168, height: 86);
        break;
      case DopeiMood.calm:
        canvas.drawArc(rect(414, 424, 92, 48), math.pi + 0.18, math.pi - 0.36,
            false, feature);
        canvas.drawArc(rect(610, 424, 92, 48), math.pi + 0.18, math.pi - 0.36,
            false, feature);
        smile(width: 116, height: 56);
        break;
      case DopeiMood.neutral:
        openEyes();
        smile();
        break;
    }
  }

  void _paintHoodieDetails(
    Canvas canvas,
    Offset Function(double, double) p,
    Rect Function(double, double, double, double) rect,
    Color cyan,
    Color purple,
    double unit,
  ) {
    final drawstring = Paint()
      ..color = cyan
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16 * unit;
    canvas.drawLine(p(428, 668), p(420, 846), drawstring);
    canvas.drawLine(p(596, 668), p(604, 846), drawstring);
    canvas.drawCircle(p(420, 846), 18 * unit, Paint()..color = purple);
    canvas.drawCircle(p(604, 846), 18 * unit, Paint()..color = purple);

    final logo = Paint()
      ..color = cyan
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 32 * unit;
    canvas.drawArc(
        rect(512, 760, 128, 128), -math.pi / 2, math.pi, false, logo);
    canvas.drawLine(
        p(470, 702),
        p(470, 820),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 28 * unit);
  }

  void _paintConfetti(
    Canvas canvas,
    Offset Function(double, double) p,
    double unit,
    double progress,
  ) {
    final colors = <Color>[
      const Color(0xFF00F0FF),
      const Color(0xFF9D4DFF),
      const Color(0xFFFF4DDB),
      const Color(0xFFFBBF24),
    ];
    for (var i = 0; i < 12; i += 1) {
      final angle = (i / 12) * math.pi * 2 + progress * math.pi * 2;
      final center =
          p(512 + math.cos(angle) * 385, 430 + math.sin(angle) * 300);
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10 * unit
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center.translate(-18 * unit, 0),
          center.translate(18 * unit, 0), paint);
      canvas.drawLine(center.translate(0, -18 * unit),
          center.translate(0, 18 * unit), paint);
    }
  }

  void _paintSpiral(Canvas canvas, Offset center, Color color, double unit) {
    final path = Path()..moveTo(center.dx, center.dy);
    for (var i = 1; i <= 34; i += 1) {
      final t = i / 34;
      final angle = t * math.pi * 4.2;
      final radius = t * 44 * unit;
      path.lineTo(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10 * unit
        ..strokeCap = StrokeCap.round,
    );
  }

  Color _moodFeatureColor(DopeiMood mood) {
    return switch (mood) {
      DopeiMood.overwhelmed => const Color(0xFF67E8F9),
      DopeiMood.calm => const Color(0xFF7DD3FC),
      _ => const Color(0xFF00F0FF),
    };
  }

  @override
  bool shouldRepaint(covariant DopeiOrbPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.progress != progress ||
        oldDelegate.reducedMotion != reducedMotion;
  }
}
