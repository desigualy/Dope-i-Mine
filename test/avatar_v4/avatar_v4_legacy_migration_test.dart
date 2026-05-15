import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';
import 'package:dope_i_mine/domain/avatar/avatar_enums.dart';
import 'package:dope_i_mine/domain/avatar/user_avatar_profile.dart';

void main() {
  test('legacy avatar profile maps useful appearance data into Avatar V4 config', () {
    const legacy = UserAvatarProfile(
      mode: AvatarMode.inspiredByMe,
      renderMode: AvatarRenderMode.premiumPortrait,
      realismLevel: AvatarRealismLevel.soft,
      lightingStyle: AvatarLightingStyle.softNatural,
      cameraStyle: AvatarCameraStyle.shoulders,
      agePresentation: AvatarAgePresentation.adult,
      bodyPresentation: AvatarBodyPresentation.average,
      skinTone: Color(0xFFB87952),
      skinDetail: AvatarSkinDetail.freckles,
      hairType: AvatarHairType.afro,
      hairLength: AvatarHairLength.long,
      hairStyle: AvatarHairStyle.longRinglets,
      hairColor: Color(0xFFA04000),
      facialHair: AvatarFacialHair.none,
      faceShape: AvatarFaceShape.oval,
      expression: AvatarExpression.calm,
      accessibilityItems: <AvatarAccessibilityItem>[AvatarAccessibilityItem.glasses],
    );

    final config = AvatarV4ProfileMapper.fromAny(legacy);

    expect(config.skinTone, 'tan_warm');
    expect(config.faceShape, 'soft_oval');
    expect(config.hairPackId, 'hair_ringlet_afro_v1');
    expect(config.hairStyleId, 'long_copper_ringlet_afro');
    expect(config.hairColor, 'copper_brown');
    expect(config.freckles, isTrue);
    expect(config.accessoryIds, contains('glasses'));
  });

  test('ringlet afro geometry migrated to Avatar V4 keeps the face clear', () {
    expect(AvatarV4RingletAfroGeometry.hasLeftSideVolume, isTrue);
    expect(AvatarV4RingletAfroGeometry.hasRightSideVolume, isTrue);
    expect(AvatarV4RingletAfroGeometry.hasRearHalo, isTrue);
    expect(AvatarV4RingletAfroGeometry.hasTopCrownVolume, isTrue);
    expect(AvatarV4RingletAfroGeometry.usesSmallNaturalCurls, isTrue);
    expect(AvatarV4RingletAfroGeometry.allCurls.length, greaterThanOrEqualTo(30));

    for (final curl in AvatarV4RingletAfroGeometry.allCurls) {
      expect(
        curl.violatesMouthChinExclusion,
        isFalse,
        reason: '${curl.region} at (${curl.x}, ${curl.y}) enters the mouth/chin zone',
      );
    }
  });
}
