import 'package:flutter/material.dart';

import 'ringlet_curl_painter.dart';
import 'ringlet_hair_geometry.dart';

enum RingletAfroHairLayer {
  back,
  front,
}

class RingletAfroHair extends StatelessWidget {
  const RingletAfroHair.back({
    super.key,
    this.baseColor = const Color(0xFFC85A0B),
    this.shadowColor = const Color(0xFF4A1907),
    this.highlightColor = const Color(0xFFF59E0B),
    this.paintGuideZones = false,
  }) : layer = RingletAfroHairLayer.back;

  const RingletAfroHair.front({
    super.key,
    this.baseColor = const Color(0xFFC85A0B),
    this.shadowColor = const Color(0xFF4A1907),
    this.highlightColor = const Color(0xFFF59E0B),
    this.paintGuideZones = false,
  }) : layer = RingletAfroHairLayer.front;

  final RingletAfroHairLayer layer;
  final Color baseColor;
  final Color shadowColor;
  final Color highlightColor;
  final bool paintGuideZones;

  @override
  Widget build(BuildContext context) {
    final curls = switch (layer) {
      RingletAfroHairLayer.back => RingletAfroGeometry.backLayerCurls,
      RingletAfroHairLayer.front => RingletAfroGeometry.frontLayerCurls,
    };

    return IgnorePointer(
      child: CustomPaint(
        key: ValueKey<String>('avatar-v3-ringlet-afro-${layer.name}'),
        painter: RingletCurlPainter(
          curls: curls,
          baseColor: baseColor,
          shadowColor: shadowColor,
          highlightColor: highlightColor,
          paintGuideZones: paintGuideZones,
        ),
        size: Size.infinite,
      ),
    );
  }
}
