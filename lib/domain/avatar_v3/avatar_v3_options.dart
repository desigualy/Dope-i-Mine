import 'avatar_v3_enums.dart';
import 'avatar_v3_profile.dart';

class AvatarV3Options {
  const AvatarV3Options._();

  static const Map<AvatarV3HairType, List<AvatarV3HairStyle>> hairStyleMap =
      <AvatarV3HairType, List<AvatarV3HairStyle>>{
    AvatarV3HairType.bald: <AvatarV3HairStyle>[
      AvatarV3HairStyle.none,
    ],
    AvatarV3HairType.shaved: <AvatarV3HairStyle>[
      AvatarV3HairStyle.buzzCut,
    ],
    AvatarV3HairType.straight: <AvatarV3HairStyle>[
      AvatarV3HairStyle.shortNeat,
      AvatarV3HairStyle.sidePart,
      AvatarV3HairStyle.shoulderSmooth,
    ],
    AvatarV3HairType.wavy: <AvatarV3HairStyle>[
      AvatarV3HairStyle.shortWavy,
      AvatarV3HairStyle.mediumWavy,
      AvatarV3HairStyle.longWavy,
    ],
    AvatarV3HairType.curly: <AvatarV3HairStyle>[
      AvatarV3HairStyle.shortCurls,
      AvatarV3HairStyle.shoulderCurls,
      AvatarV3HairStyle.longCurls,
    ],
    AvatarV3HairType.coily: <AvatarV3HairStyle>[
      AvatarV3HairStyle.taperedCoils,
      AvatarV3HairStyle.shortAfro,
      AvatarV3HairStyle.roundedAfro,
    ],
    AvatarV3HairType.afro: <AvatarV3HairStyle>[
      AvatarV3HairStyle.shortAfro,
      AvatarV3HairStyle.roundedAfro,
      AvatarV3HairStyle.sidePartAfro,
      AvatarV3HairStyle.voluminousAfro,
    ],
    AvatarV3HairType.ringletAfro: <AvatarV3HairStyle>[
      AvatarV3HairStyle.sidePartAfro,
      AvatarV3HairStyle.longRingletAfro,
      AvatarV3HairStyle.voluminousAfro,
    ],
    AvatarV3HairType.braids: <AvatarV3HairStyle>[
      AvatarV3HairStyle.boxBraids,
      AvatarV3HairStyle.bobBraids,
      AvatarV3HairStyle.longBraids,
      AvatarV3HairStyle.cornrows,
    ],
    AvatarV3HairType.locs: <AvatarV3HairStyle>[
      AvatarV3HairStyle.shortLocs,
      AvatarV3HairStyle.shoulderLocs,
      AvatarV3HairStyle.tiedLocs,
      AvatarV3HairStyle.longLocs,
    ],
    AvatarV3HairType.twists: <AvatarV3HairStyle>[
      AvatarV3HairStyle.shortTwists,
      AvatarV3HairStyle.shoulderTwists,
      AvatarV3HairStyle.longTwists,
    ],
    AvatarV3HairType.covered: <AvatarV3HairStyle>[
      AvatarV3HairStyle.headwrap,
    ],
    AvatarV3HairType.frizzy: <AvatarV3HairStyle>[
      AvatarV3HairStyle.frizzyBob,
      AvatarV3HairStyle.frizzyLong,
    ],
  };

  static List<AvatarV3HairStyle> hairStylesFor(AvatarV3HairType type) {
    return hairStyleMap[type] ?? const <AvatarV3HairStyle>[AvatarV3HairStyle.none];
  }

  static AvatarV3HairStyle defaultHairStyleFor(AvatarV3HairType type) {
    return hairStylesFor(type).first;
  }

  static AvatarV3HairLength defaultHairLengthFor(
    AvatarV3HairType type,
    AvatarV3HairStyle style,
  ) {
    if (type == AvatarV3HairType.bald) return AvatarV3HairLength.none;
    if (type == AvatarV3HairType.shaved) return AvatarV3HairLength.shaved;
    return switch (style) {
      AvatarV3HairStyle.longWavy ||
      AvatarV3HairStyle.longCurls ||
      AvatarV3HairStyle.longRingletAfro ||
      AvatarV3HairStyle.longBraids ||
      AvatarV3HairStyle.longLocs ||
      AvatarV3HairStyle.longTwists ||
      AvatarV3HairStyle.frizzyLong =>
        AvatarV3HairLength.long,
      AvatarV3HairStyle.shoulderSmooth ||
      AvatarV3HairStyle.shoulderCurls ||
      AvatarV3HairStyle.shoulderLocs ||
      AvatarV3HairStyle.shoulderTwists ||
      AvatarV3HairStyle.bobBraids =>
        AvatarV3HairLength.shoulder,
      AvatarV3HairStyle.buzzCut ||
      AvatarV3HairStyle.shortNeat ||
      AvatarV3HairStyle.shortWavy ||
      AvatarV3HairStyle.shortCurls ||
      AvatarV3HairStyle.shortAfro ||
      AvatarV3HairStyle.shortLocs ||
      AvatarV3HairStyle.shortTwists =>
        AvatarV3HairLength.short,
      _ => AvatarV3HairLength.medium,
    };
  }

  static AvatarV3HairFrontPolicy defaultFrontPolicyFor(
    AvatarV3HairType type,
    AvatarV3HairStyle style,
  ) {
    if (type == AvatarV3HairType.ringletAfro ||
        type == AvatarV3HairType.afro ||
        type == AvatarV3HairType.coily) {
      return AvatarV3HairFrontPolicy.noFaceOverlap;
    }
    if (type == AvatarV3HairType.locs ||
        type == AvatarV3HairType.braids ||
        type == AvatarV3HairType.twists) {
      return AvatarV3HairFrontPolicy.sideOnly;
    }
    if (style == AvatarV3HairStyle.sidePart ||
        style == AvatarV3HairStyle.sidePartAfro) {
      return AvatarV3HairFrontPolicy.sideOnly;
    }
    return AvatarV3HairFrontPolicy.softFringe;
  }

  static bool isFacialHairAllowed(AvatarV3AgePresentation age) {
    return age != AvatarV3AgePresentation.child &&
        age != AvatarV3AgePresentation.preTeen;
  }

  static AvatarV3Profile normalize(AvatarV3Profile profile) {
    final allowedStyles = hairStylesFor(profile.hair.type);
    final resolvedStyle = allowedStyles.contains(profile.hair.style)
        ? profile.hair.style
        : defaultHairStyleFor(profile.hair.type);

    final resolvedHair = AvatarV3HairProfile(
      type: profile.hair.type,
      style: resolvedStyle,
      length: profile.hair.length == AvatarV3HairLength.none &&
              profile.hair.type != AvatarV3HairType.bald
          ? defaultHairLengthFor(profile.hair.type, resolvedStyle)
          : profile.hair.length,
      volume: profile.hair.volume,
      frontPolicy: profile.hair.frontPolicy,
      colour: profile.hair.colour,
    );

    final resolvedFacialHair = isFacialHairAllowed(profile.agePresentation)
        ? profile.facialHair
        : const AvatarV3FacialHairProfile();

    return profile.copyWith(
      renderMode: AvatarV3RenderMode.assetLayered,
      visualStyle: profile.mode == AvatarV3Mode.privateAbstract
          ? AvatarV3VisualStyle.privacyAbstract
          : profile.visualStyle,
      hair: resolvedHair,
      facialHair: resolvedFacialHair,
    );
  }
}
