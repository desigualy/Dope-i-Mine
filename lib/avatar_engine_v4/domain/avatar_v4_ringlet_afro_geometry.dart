class AvatarV4RingletAfroGeometry {
  const AvatarV4RingletAfroGeometry._();

  static const bool hasLeftSideVolume = true;
  static const bool hasRightSideVolume = true;
  static const bool hasRearHalo = true;
  static const bool hasTopCrownVolume = true;
  static const bool keepsMouthAndChinClear = true;
  static const bool usesSmallNaturalCurls = true;

  static const double mouthChinExclusionTopY = 60;
  static const double mouthChinExclusionBottomY = 94;
  static const double mouthChinExclusionLeftX = 34;
  static const double mouthChinExclusionRightX = 66;

  static const List<AvatarV4CurlAnchor> leftSideVolume = <AvatarV4CurlAnchor>[
    AvatarV4CurlAnchor(region: 'left side volume', x: 18, y: 28, radius: 5),
    AvatarV4CurlAnchor(region: 'left side volume', x: 13, y: 38, radius: 5),
    AvatarV4CurlAnchor(region: 'left side volume', x: 11, y: 49, radius: 4),
    AvatarV4CurlAnchor(region: 'left side volume', x: 14, y: 59, radius: 4),
    AvatarV4CurlAnchor(region: 'left side volume', x: 20, y: 67, radius: 4),
  ];

  static const List<AvatarV4CurlAnchor> rightSideVolume = <AvatarV4CurlAnchor>[
    AvatarV4CurlAnchor(region: 'right side volume', x: 82, y: 28, radius: 5),
    AvatarV4CurlAnchor(region: 'right side volume', x: 87, y: 38, radius: 5),
    AvatarV4CurlAnchor(region: 'right side volume', x: 89, y: 49, radius: 4),
    AvatarV4CurlAnchor(region: 'right side volume', x: 86, y: 59, radius: 4),
    AvatarV4CurlAnchor(region: 'right side volume', x: 80, y: 67, radius: 4),
  ];

  static const List<AvatarV4CurlAnchor> rearHalo = <AvatarV4CurlAnchor>[
    AvatarV4CurlAnchor(region: 'rear halo', x: 28, y: 18, radius: 5),
    AvatarV4CurlAnchor(region: 'rear halo', x: 38, y: 12, radius: 5),
    AvatarV4CurlAnchor(region: 'rear halo', x: 50, y: 10, radius: 5),
    AvatarV4CurlAnchor(region: 'rear halo', x: 62, y: 12, radius: 5),
    AvatarV4CurlAnchor(region: 'rear halo', x: 72, y: 18, radius: 5),
    AvatarV4CurlAnchor(region: 'rear halo', x: 24, y: 25, radius: 4),
    AvatarV4CurlAnchor(region: 'rear halo', x: 76, y: 25, radius: 4),
    AvatarV4CurlAnchor(region: 'rear halo', x: 50, y: 17, radius: 4),
  ];

  static const List<AvatarV4CurlAnchor> crownVolume = <AvatarV4CurlAnchor>[
    AvatarV4CurlAnchor(region: 'top crown volume', x: 34, y: 24, radius: 4),
    AvatarV4CurlAnchor(region: 'top crown volume', x: 43, y: 20, radius: 4),
    AvatarV4CurlAnchor(region: 'top crown volume', x: 52, y: 20, radius: 4),
    AvatarV4CurlAnchor(region: 'top crown volume', x: 61, y: 22, radius: 4),
    AvatarV4CurlAnchor(region: 'top crown volume', x: 68, y: 28, radius: 4),
  ];

  static const List<AvatarV4CurlAnchor> templeRinglets = <AvatarV4CurlAnchor>[
    AvatarV4CurlAnchor(region: 'small ringlets at temples only', x: 29, y: 42, radius: 3),
    AvatarV4CurlAnchor(region: 'small ringlets at temples only', x: 71, y: 42, radius: 3),
    AvatarV4CurlAnchor(region: 'kept above eyebrows', x: 36, y: 35, radius: 3),
    AvatarV4CurlAnchor(region: 'kept above eyebrows', x: 64, y: 35, radius: 3),
  ];

  static List<AvatarV4CurlAnchor> get allCurls => <AvatarV4CurlAnchor>[
        ...leftSideVolume,
        ...rightSideVolume,
        ...rearHalo,
        ...crownVolume,
        ...templeRinglets,
        const AvatarV4CurlAnchor(region: 'rear halo filler', x: 31, y: 31, radius: 3),
        const AvatarV4CurlAnchor(region: 'rear halo filler', x: 41, y: 29, radius: 3),
        const AvatarV4CurlAnchor(region: 'rear halo filler', x: 50, y: 28, radius: 3),
        const AvatarV4CurlAnchor(region: 'rear halo filler', x: 59, y: 29, radius: 3),
        const AvatarV4CurlAnchor(region: 'rear halo filler', x: 69, y: 31, radius: 3),
        const AvatarV4CurlAnchor(region: 'left side volume', x: 22, y: 38, radius: 3),
        const AvatarV4CurlAnchor(region: 'left side volume', x: 24, y: 50, radius: 3),
        const AvatarV4CurlAnchor(region: 'right side volume', x: 78, y: 38, radius: 3),
        const AvatarV4CurlAnchor(region: 'right side volume', x: 76, y: 50, radius: 3),
      ];
}

class AvatarV4CurlAnchor {
  const AvatarV4CurlAnchor({
    required this.region,
    required this.x,
    required this.y,
    required this.radius,
  });

  final String region;
  final double x;
  final double y;
  final double radius;

  bool get violatesMouthChinExclusion {
    final withinX = x >= AvatarV4RingletAfroGeometry.mouthChinExclusionLeftX &&
        x <= AvatarV4RingletAfroGeometry.mouthChinExclusionRightX;
    final withinY = y >= AvatarV4RingletAfroGeometry.mouthChinExclusionTopY &&
        y <= AvatarV4RingletAfroGeometry.mouthChinExclusionBottomY;
    return withinX && withinY;
  }
}
