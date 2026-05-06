// ignore_for_file: prefer_const_declarations
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_asset_manifest.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_enums.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_migration.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_profile.dart';

void main() {
  test('default starter profile resolves to long ringlet afro', () {
    final profile = AvatarV3Migration.defaultReferenceProfile;

    expect(profile.hair.type, AvatarV3HairType.ringletAfro);
    expect(profile.hair.style, AvatarV3HairStyle.longRingletAfro);
    expect(profile.hair.colour, AvatarV3HairColour.copper);
  });

  test('non-bald hair profile receives starter hair layers during Pass 2B', () {
    final profile = const AvatarV3Profile(
      hair: AvatarV3HairProfile(
        type: AvatarV3HairType.curly,
        style: AvatarV3HairStyle.shoulderCurls,
      ),
    );

    final layers = const AvatarV3LayerResolver().resolve(profile);
    final ids = layers.map((layer) => layer.id).toList();

    expect(ids, contains('hair.ringlet_afro.back.long_copper'));
    expect(ids, contains('hair.ringlet_afro.front.long_copper'));
  });

  test('deliberate bald profile does not receive starter hair layers', () {
    final profile = const AvatarV3Profile(
      hair: AvatarV3HairProfile(
        type: AvatarV3HairType.bald,
        style: AvatarV3HairStyle.none,
        length: AvatarV3HairLength.none,
      ),
    );

    final layers = const AvatarV3LayerResolver().resolve(profile);
    final ids = layers.map((layer) => layer.id).toList();

    expect(ids, isNot(contains('hair.ringlet_afro.back.long_copper')));
    expect(ids, isNot(contains('hair.ringlet_afro.front.long_copper')));
  });
}
