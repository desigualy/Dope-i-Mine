import 'avatar_v2_profile.dart';

class AvatarV2Option<T> {
  const AvatarV2Option({
    required this.value,
    required this.label,
    this.description,
    this.freeForever = true,
  });

  final T value;
  final String label;
  final String? description;
  final bool freeForever;
}

class AvatarV2Options {
  const AvatarV2Options._();

  static const List<AvatarV2Option<AvatarV2Mode>> modes = <AvatarV2Option<AvatarV2Mode>>[
    AvatarV2Option(
      value: AvatarV2Mode.looksLikeMe,
      label: 'Looks like me',
      description: 'Uses the closest editable portrait traits and optional reference photo.',
    ),
    AvatarV2Option(
      value: AvatarV2Mode.inspiredByMe,
      label: 'Inspired by me',
      description: 'Soft portrait with likeness cues but less pressure for exact realism.',
    ),
    AvatarV2Option(
      value: AvatarV2Mode.privateAbstract,
      label: 'Private / abstract',
      description: 'No human likeness. Uses colour, shape, and initials instead.',
    ),
  ];

  static const List<AvatarV2HairTexture> hairTextures = <AvatarV2HairTexture>[
    AvatarV2HairTexture.straight,
    AvatarV2HairTexture.wavy,
    AvatarV2HairTexture.curly,
    AvatarV2HairTexture.coily,
    AvatarV2HairTexture.afro,
    AvatarV2HairTexture.locs,
    AvatarV2HairTexture.braids,
    AvatarV2HairTexture.twists,
    AvatarV2HairTexture.shaved,
    AvatarV2HairTexture.bald,
    AvatarV2HairTexture.covered,
  ];

  static const Map<AvatarV2HairTexture, List<AvatarV2HairStyle>> hairStylesByTexture =
      <AvatarV2HairTexture, List<AvatarV2HairStyle>>{
    AvatarV2HairTexture.straight: <AvatarV2HairStyle>[
      AvatarV2HairStyle.shortCrop,
      AvatarV2HairStyle.buzzCut,
      AvatarV2HairStyle.fade,
      AvatarV2HairStyle.bob,
      AvatarV2HairStyle.ponytail,
      AvatarV2HairStyle.bun,
    ],
    AvatarV2HairTexture.wavy: <AvatarV2HairStyle>[
      AvatarV2HairStyle.shortWaves,
      AvatarV2HairStyle.layeredWaves,
      AvatarV2HairStyle.bob,
      AvatarV2HairStyle.ponytail,
      AvatarV2HairStyle.bun,
    ],
    AvatarV2HairTexture.curly: <AvatarV2HairStyle>[
      AvatarV2HairStyle.shortCurls,
      AvatarV2HairStyle.shoulderCurls,
      AvatarV2HairStyle.longCurls,
      AvatarV2HairStyle.curlyPuff,
    ],
    AvatarV2HairTexture.coily: <AvatarV2HairStyle>[
      AvatarV2HairStyle.coilyCrop,
      AvatarV2HairStyle.taperedCoils,
      AvatarV2HairStyle.miniAfro,
      AvatarV2HairStyle.sidePartAfro,
      AvatarV2HairStyle.curlyPuff,
    ],
    AvatarV2HairTexture.afro: <AvatarV2HairStyle>[
      AvatarV2HairStyle.fullAfro,
      AvatarV2HairStyle.roundedAfro,
      AvatarV2HairStyle.taperedAfro,
      AvatarV2HairStyle.sidePartAfro,
      AvatarV2HairStyle.afroPuff,
      AvatarV2HairStyle.twinPuffs,
    ],
    AvatarV2HairTexture.locs: <AvatarV2HairStyle>[
      AvatarV2HairStyle.shortLocs,
      AvatarV2HairStyle.locBob,
      AvatarV2HairStyle.shoulderLocs,
      AvatarV2HairStyle.longLocs,
      AvatarV2HairStyle.locBun,
    ],
    AvatarV2HairTexture.braids: <AvatarV2HairStyle>[
      AvatarV2HairStyle.cornrows,
      AvatarV2HairStyle.boxBraids,
      AvatarV2HairStyle.braidBob,
      AvatarV2HairStyle.longBraids,
      AvatarV2HairStyle.braidedPonytail,
    ],
    AvatarV2HairTexture.twists: <AvatarV2HairStyle>[
      AvatarV2HairStyle.shortTwists,
      AvatarV2HairStyle.twistBob,
      AvatarV2HairStyle.longTwists,
      AvatarV2HairStyle.flatTwists,
    ],
    AvatarV2HairTexture.shaved: <AvatarV2HairStyle>[
      AvatarV2HairStyle.buzzCut,
      AvatarV2HairStyle.fade,
    ],
    AvatarV2HairTexture.bald: <AvatarV2HairStyle>[
      AvatarV2HairStyle.shortCrop,
    ],
    AvatarV2HairTexture.covered: <AvatarV2HairStyle>[
      AvatarV2HairStyle.headwrap,
      AvatarV2HairStyle.covered,
    ],
  };

  static List<AvatarV2HairStyle> hairStylesFor(AvatarV2HairTexture texture) {
    return hairStylesByTexture[texture] ?? const <AvatarV2HairStyle>[];
  }

  static AvatarV2HairStyle defaultHairStyleFor(AvatarV2HairTexture texture) {
    final styles = hairStylesFor(texture);
    return styles.isEmpty ? AvatarV2HairStyle.shortCrop : styles.first;
  }

  static AvatarV2HairLength defaultHairLengthFor(AvatarV2HairStyle style) {
    switch (style) {
      case AvatarV2HairStyle.buzzCut:
      case AvatarV2HairStyle.fade:
      case AvatarV2HairStyle.shortCrop:
      case AvatarV2HairStyle.shortWaves:
      case AvatarV2HairStyle.shortCurls:
      case AvatarV2HairStyle.coilyCrop:
      case AvatarV2HairStyle.taperedCoils:
      case AvatarV2HairStyle.shortLocs:
      case AvatarV2HairStyle.shortTwists:
        return AvatarV2HairLength.short;
      case AvatarV2HairStyle.shoulderCurls:
      case AvatarV2HairStyle.shoulderLocs:
      case AvatarV2HairStyle.braidBob:
      case AvatarV2HairStyle.locBob:
      case AvatarV2HairStyle.twistBob:
        return AvatarV2HairLength.shoulder;
      case AvatarV2HairStyle.longCurls:
      case AvatarV2HairStyle.longLocs:
      case AvatarV2HairStyle.longBraids:
      case AvatarV2HairStyle.longTwists:
        return AvatarV2HairLength.long;
      case AvatarV2HairStyle.fullAfro:
      case AvatarV2HairStyle.roundedAfro:
      case AvatarV2HairStyle.taperedAfro:
      case AvatarV2HairStyle.sidePartAfro:
      case AvatarV2HairStyle.miniAfro:
      case AvatarV2HairStyle.afroPuff:
      case AvatarV2HairStyle.twinPuffs:
        return AvatarV2HairLength.medium;
      case AvatarV2HairStyle.headwrap:
      case AvatarV2HairStyle.covered:
        return AvatarV2HairLength.medium;
      case AvatarV2HairStyle.bob:
      case AvatarV2HairStyle.ponytail:
      case AvatarV2HairStyle.bun:
      case AvatarV2HairStyle.layeredWaves:
      case AvatarV2HairStyle.curlyPuff:
      case AvatarV2HairStyle.locBun:
      case AvatarV2HairStyle.cornrows:
      case AvatarV2HairStyle.boxBraids:
      case AvatarV2HairStyle.braidedPonytail:
      case AvatarV2HairStyle.flatTwists:
        return AvatarV2HairLength.medium;
    }
  }

  static AvatarV2FrontStrandPolicy frontPolicyFor(AvatarV2HairStyle style) {
    switch (style) {
      case AvatarV2HairStyle.bob:
      case AvatarV2HairStyle.layeredWaves:
        return AvatarV2FrontStrandPolicy.sideOnly;
      case AvatarV2HairStyle.shortCrop:
      case AvatarV2HairStyle.shortWaves:
      case AvatarV2HairStyle.shortCurls:
        return AvatarV2FrontStrandPolicy.fringeAllowed;
      case AvatarV2HairStyle.headwrap:
      case AvatarV2HairStyle.covered:
        return AvatarV2FrontStrandPolicy.covered;
      default:
        return AvatarV2FrontStrandPolicy.noFaceOverlap;
    }
  }

  static const List<AvatarV2BirthmarkType> birthmarkTypes = <AvatarV2BirthmarkType>[
    AvatarV2BirthmarkType.flatPatch,
    AvatarV2BirthmarkType.beautyMark,
    AvatarV2BirthmarkType.portWineStain,
    AvatarV2BirthmarkType.moleCluster,
    AvatarV2BirthmarkType.cafeAuLait,
  ];

  static const List<AvatarV2ScarType> scarTypes = <AvatarV2ScarType>[
    AvatarV2ScarType.fineLine,
    AvatarV2ScarType.raisedScar,
    AvatarV2ScarType.surgicalScar,
    AvatarV2ScarType.burnScar,
    AvatarV2ScarType.acneScarring,
  ];

  static const List<AvatarV2FaceRegion> skinDetailLocations = <AvatarV2FaceRegion>[
    AvatarV2FaceRegion.forehead,
    AvatarV2FaceRegion.leftCheek,
    AvatarV2FaceRegion.rightCheek,
    AvatarV2FaceRegion.noseBridge,
    AvatarV2FaceRegion.mouthCorner,
    AvatarV2FaceRegion.chin,
    AvatarV2FaceRegion.jaw,
    AvatarV2FaceRegion.neck,
  ];
}
