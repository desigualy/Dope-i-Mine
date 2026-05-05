import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_enums.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_migration.dart';

void main() {
  test('default reference profile matches requested ringlet afro direction', () {
    final profile = AvatarV3Migration.defaultReferenceProfile;

    expect(profile.hair.type, AvatarV3HairType.ringletAfro);
    expect(profile.hair.style, AvatarV3HairStyle.longRingletAfro);
    expect(profile.hair.frontPolicy, AvatarV3HairFrontPolicy.noFaceOverlap);
  });
}
