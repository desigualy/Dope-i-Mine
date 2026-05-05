import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_enums.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_options.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_profile.dart';

void main() {
  test('every hair type has at least one valid style', () {
    for (final type in AvatarV3HairType.values) {
      final styles = AvatarV3Options.hairStylesFor(type);
      expect(styles, isNotEmpty, reason: '$type has no styles');
      expect(
        styles,
        contains(AvatarV3Options.defaultHairStyleFor(type)),
        reason: '$type default style is invalid',
      );
    }
  });

  test('ringlet afro includes the requested long ringlet afro style', () {
    expect(
      AvatarV3Options.hairStylesFor(AvatarV3HairType.ringletAfro),
      contains(AvatarV3HairStyle.longRingletAfro),
    );
  });

  test('child and pre-teen profiles normalize facial hair to none', () {
    final child = AvatarV3Options.normalize(
      const AvatarV3Profile(
        agePresentation: AvatarV3AgePresentation.child,
        facialHair: AvatarV3FacialHairProfile(
          type: AvatarV3FacialHair.fullBeard,
        ),
      ),
    );

    expect(child.facialHair.type, AvatarV3FacialHair.none);
  });
}
