import 'package:flutter/material.dart';

import 'avatar_v3_enums.dart';

class AvatarV3Layer {
  const AvatarV3Layer({
    required this.id,
    required this.slot,
    required this.assetPath,
    required this.zIndex,
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.opacity = 1.0,
  });

  final String id;
  final AvatarV3LayerSlot slot;
  final String assetPath;
  final int zIndex;
  final Offset offset;
  final double scale;
  final double opacity;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'slot': slot.name,
        'assetPath': assetPath,
        'zIndex': zIndex,
        'offset': <String, double>{'dx': offset.dx, 'dy': offset.dy},
        'scale': scale,
        'opacity': opacity,
      };
}
