import 'package:flutter/material.dart';

class AvatarMissingRigDiagnostic extends StatelessWidget {
  const AvatarMissingRigDiagnostic({
    super.key,
    required this.assetPath,
    this.size = 180,
    this.details,
  });

  final String assetPath;
  final double size;
  final String? details;

  @override
  Widget build(BuildContext context) {
    final safeSize = size <= 0 ? 180.0 : size;
    final theme = Theme.of(context);
    final compact = safeSize < 210;

    return Semantics(
      label: 'Avatar preview placeholder. Production avatar rig missing.',
      child: Container(
        key: const ValueKey<String>('avatar-v4-missing-rig-diagnostic'),
        width: safeSize,
        height: safeSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(safeSize * .18),
          gradient: const LinearGradient(
            colors: <Color>[
              Color(0xFFECFEFF),
              Color(0xFFF0FDF4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF14B8A6), width: 2),
        ),
        padding: EdgeInsets.all(safeSize * .07),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: safeSize * .78,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _StarterAvatarGlyph(size: compact ? 58 : safeSize * .42),
                SizedBox(height: compact ? 6 : safeSize * .045),
                Text(
                  compact ? 'Avatar preview' : 'Starter avatar preview',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF115E59),
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 12 : null,
                  ),
                ),
                if (!compact) ...<Widget>[
                  SizedBox(height: safeSize * .030),
                  Text(
                    details ??
                        'Production Rive rig not installed yet: $assetPath',
                    key: const ValueKey<String>(
                        'avatar-v4-rig-diagnostic-details'),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF134E4A),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarterAvatarGlyph extends StatelessWidget {
  const _StarterAvatarGlyph({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      key: const ValueKey<String>('avatar-v4-starter-visible-preview'),
      dimension: size,
      child: CustomPaint(
        painter: _StarterAvatarGlyphPainter(),
      ),
    );
  }
}

class _StarterAvatarGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.shortestSide / 100;

    final shadow = Paint()
      ..color = const Color(0x33115E59)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 34 * scale),
        width: 58 * scale,
        height: 12 * scale,
      ),
      shadow,
    );

    final body = Paint()..color = const Color(0xFF5EEAD4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 28 * scale),
          width: 58 * scale,
          height: 42 * scale,
        ),
        Radius.circular(20 * scale),
      ),
      body,
    );

    final head = Paint()..color = const Color(0xFFFED7AA);
    canvas.drawCircle(
        Offset(center.dx, center.dy - 12 * scale), 28 * scale, head);

    final hair = Paint()..color = const Color(0xFF7C2D12);
    final hairPath = Path()
      ..moveTo(center.dx - 28 * scale, center.dy - 14 * scale)
      ..quadraticBezierTo(center.dx - 20 * scale, center.dy - 46 * scale,
          center.dx + 4 * scale, center.dy - 41 * scale)
      ..quadraticBezierTo(center.dx + 30 * scale, center.dy - 36 * scale,
          center.dx + 28 * scale, center.dy - 8 * scale)
      ..quadraticBezierTo(center.dx + 10 * scale, center.dy - 22 * scale,
          center.dx - 28 * scale, center.dy - 14 * scale)
      ..close();
    canvas.drawPath(hairPath, hair);

    final eye = Paint()..color = const Color(0xFF111827);
    canvas.drawCircle(
        Offset(center.dx - 10 * scale, center.dy - 10 * scale), 3 * scale, eye);
    canvas.drawCircle(
        Offset(center.dx + 10 * scale, center.dy - 10 * scale), 3 * scale, eye);

    final smile = Paint()
      ..color = const Color(0xFF111827)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 2 * scale),
        width: 22 * scale,
        height: 14 * scale,
      ),
      0.15,
      2.85,
      false,
      smile,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
