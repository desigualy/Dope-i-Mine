import 'package:flutter/widgets.dart';

enum RingletAfroRegion {
  rearHalo,
  leftSideVolume,
  rightSideVolume,
  crownVolume,
  leftTemple,
  rightTemple,
}

class RingletAfroCurl {
  const RingletAfroCurl({
    required this.region,
    required this.center,
    required this.radius,
    required this.strokeWidth,
    required this.rotation,
    required this.depth,
  });

  final RingletAfroRegion region;
  final Offset center;
  final double radius;
  final double strokeWidth;
  final double rotation;
  final double depth;

  bool get isBelowMouthBand => center.dy > 0.61;
  bool get isCentreFaceBand => center.dx > 0.36 && center.dx < 0.64;
  bool get violatesMouthChinExclusion => isCentreFaceBand && isBelowMouthBand;
}

class RingletAfroGeometry {
  const RingletAfroGeometry._();

  static const Rect faceSafeZone = Rect.fromLTWH(0.34, 0.34, 0.32, 0.36);
  static const Rect mouthChinExclusionZone = Rect.fromLTWH(0.34, 0.58, 0.32, 0.25);

  static const List<RingletAfroCurl> rearHalo = <RingletAfroCurl>[
    RingletAfroCurl(region: RingletAfroRegion.rearHalo, center: Offset(.33, .24), radius: .034, strokeWidth: .014, rotation: -0.8, depth: .16),
    RingletAfroCurl(region: RingletAfroRegion.rearHalo, center: Offset(.40, .19), radius: .035, strokeWidth: .014, rotation: -0.3, depth: .17),
    RingletAfroCurl(region: RingletAfroRegion.rearHalo, center: Offset(.48, .17), radius: .036, strokeWidth: .015, rotation: .05, depth: .18),
    RingletAfroCurl(region: RingletAfroRegion.rearHalo, center: Offset(.56, .18), radius: .035, strokeWidth: .014, rotation: .25, depth: .17),
    RingletAfroCurl(region: RingletAfroRegion.rearHalo, center: Offset(.64, .24), radius: .034, strokeWidth: .014, rotation: .8, depth: .16),
    RingletAfroCurl(region: RingletAfroRegion.rearHalo, center: Offset(.27, .36), radius: .037, strokeWidth: .015, rotation: -1.1, depth: .14),
    RingletAfroCurl(region: RingletAfroRegion.rearHalo, center: Offset(.73, .36), radius: .037, strokeWidth: .015, rotation: 1.1, depth: .14),
    RingletAfroCurl(region: RingletAfroRegion.rearHalo, center: Offset(.24, .49), radius: .039, strokeWidth: .016, rotation: -0.7, depth: .13),
    RingletAfroCurl(region: RingletAfroRegion.rearHalo, center: Offset(.76, .49), radius: .039, strokeWidth: .016, rotation: .7, depth: .13),
    RingletAfroCurl(region: RingletAfroRegion.rearHalo, center: Offset(.30, .62), radius: .034, strokeWidth: .014, rotation: -.35, depth: .12),
    RingletAfroCurl(region: RingletAfroRegion.rearHalo, center: Offset(.70, .62), radius: .034, strokeWidth: .014, rotation: .35, depth: .12),
  ];

  static const List<RingletAfroCurl> leftSideVolume = <RingletAfroCurl>[
    RingletAfroCurl(region: RingletAfroRegion.leftSideVolume, center: Offset(.25, .30), radius: .034, strokeWidth: .014, rotation: -0.7, depth: .40),
    RingletAfroCurl(region: RingletAfroRegion.leftSideVolume, center: Offset(.22, .39), radius: .036, strokeWidth: .015, rotation: -0.25, depth: .43),
    RingletAfroCurl(region: RingletAfroRegion.leftSideVolume, center: Offset(.21, .49), radius: .038, strokeWidth: .015, rotation: .10, depth: .44),
    RingletAfroCurl(region: RingletAfroRegion.leftSideVolume, center: Offset(.23, .59), radius: .037, strokeWidth: .015, rotation: .28, depth: .43),
    RingletAfroCurl(region: RingletAfroRegion.leftSideVolume, center: Offset(.27, .68), radius: .034, strokeWidth: .014, rotation: .55, depth: .40),
    RingletAfroCurl(region: RingletAfroRegion.leftSideVolume, center: Offset(.32, .72), radius: .027, strokeWidth: .012, rotation: .3, depth: .36),
    RingletAfroCurl(region: RingletAfroRegion.leftSideVolume, center: Offset(.31, .36), radius: .028, strokeWidth: .012, rotation: -.4, depth: .45),
    RingletAfroCurl(region: RingletAfroRegion.leftSideVolume, center: Offset(.30, .54), radius: .029, strokeWidth: .012, rotation: .35, depth: .45),
  ];

  static const List<RingletAfroCurl> rightSideVolume = <RingletAfroCurl>[
    RingletAfroCurl(region: RingletAfroRegion.rightSideVolume, center: Offset(.75, .30), radius: .034, strokeWidth: .014, rotation: .7, depth: .40),
    RingletAfroCurl(region: RingletAfroRegion.rightSideVolume, center: Offset(.78, .39), radius: .036, strokeWidth: .015, rotation: .25, depth: .43),
    RingletAfroCurl(region: RingletAfroRegion.rightSideVolume, center: Offset(.79, .49), radius: .038, strokeWidth: .015, rotation: -.10, depth: .44),
    RingletAfroCurl(region: RingletAfroRegion.rightSideVolume, center: Offset(.77, .59), radius: .037, strokeWidth: .015, rotation: -.28, depth: .43),
    RingletAfroCurl(region: RingletAfroRegion.rightSideVolume, center: Offset(.73, .68), radius: .034, strokeWidth: .014, rotation: -.55, depth: .40),
    RingletAfroCurl(region: RingletAfroRegion.rightSideVolume, center: Offset(.68, .72), radius: .027, strokeWidth: .012, rotation: -.3, depth: .36),
    RingletAfroCurl(region: RingletAfroRegion.rightSideVolume, center: Offset(.69, .36), radius: .028, strokeWidth: .012, rotation: .4, depth: .45),
    RingletAfroCurl(region: RingletAfroRegion.rightSideVolume, center: Offset(.70, .54), radius: .029, strokeWidth: .012, rotation: -.35, depth: .45),
  ];

  static const List<RingletAfroCurl> crownVolume = <RingletAfroCurl>[
    RingletAfroCurl(region: RingletAfroRegion.crownVolume, center: Offset(.33, .21), radius: .032, strokeWidth: .013, rotation: -0.5, depth: .72),
    RingletAfroCurl(region: RingletAfroRegion.crownVolume, center: Offset(.41, .16), radius: .034, strokeWidth: .014, rotation: -0.2, depth: .77),
    RingletAfroCurl(region: RingletAfroRegion.crownVolume, center: Offset(.50, .15), radius: .035, strokeWidth: .014, rotation: .10, depth: .80),
    RingletAfroCurl(region: RingletAfroRegion.crownVolume, center: Offset(.59, .17), radius: .034, strokeWidth: .014, rotation: .28, depth: .77),
    RingletAfroCurl(region: RingletAfroRegion.crownVolume, center: Offset(.67, .22), radius: .032, strokeWidth: .013, rotation: .55, depth: .72),
    RingletAfroCurl(region: RingletAfroRegion.crownVolume, center: Offset(.45, .24), radius: .027, strokeWidth: .012, rotation: -.12, depth: .82),
    RingletAfroCurl(region: RingletAfroRegion.crownVolume, center: Offset(.55, .24), radius: .027, strokeWidth: .012, rotation: .14, depth: .82),
  ];

  static const List<RingletAfroCurl> templeCurls = <RingletAfroCurl>[
    RingletAfroCurl(region: RingletAfroRegion.leftTemple, center: Offset(.31, .33), radius: .025, strokeWidth: .011, rotation: -0.8, depth: .92),
    RingletAfroCurl(region: RingletAfroRegion.leftTemple, center: Offset(.30, .43), radius: .022, strokeWidth: .010, rotation: -.45, depth: .92),
    RingletAfroCurl(region: RingletAfroRegion.rightTemple, center: Offset(.69, .33), radius: .025, strokeWidth: .011, rotation: .8, depth: .92),
    RingletAfroCurl(region: RingletAfroRegion.rightTemple, center: Offset(.70, .43), radius: .022, strokeWidth: .010, rotation: .45, depth: .92),
  ];

  static List<RingletAfroCurl> get backLayerCurls => <RingletAfroCurl>[
        ...rearHalo,
        ...leftSideVolume,
        ...rightSideVolume,
      ];

  static List<RingletAfroCurl> get frontLayerCurls => <RingletAfroCurl>[
        ...crownVolume,
        ...templeCurls,
      ];

  static List<RingletAfroCurl> get allCurls => <RingletAfroCurl>[
        ...backLayerCurls,
        ...frontLayerCurls,
      ];

  static bool get hasLeftSideVolume =>
      leftSideVolume.length >= 4 && leftSideVolume.every((curl) => curl.center.dx < 0.36);

  static bool get hasRightSideVolume =>
      rightSideVolume.length >= 4 && rightSideVolume.every((curl) => curl.center.dx > 0.64);

  static bool get hasRearHalo =>
      rearHalo.length >= 8 && rearHalo.any((curl) => curl.center.dy < 0.24);

  static bool get hasTopCrownVolume =>
      crownVolume.length >= 5 && crownVolume.every((curl) => curl.center.dy < 0.28);

  static bool get keepsMouthAndChinClear =>
      allCurls.every((curl) => !curl.violatesMouthChinExclusion);

  static bool get usesSmallNaturalCurls =>
      allCurls.every((curl) => curl.radius <= .040 && curl.strokeWidth <= .016);
}
