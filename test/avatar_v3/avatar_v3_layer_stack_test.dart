import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_asset_manifest.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_enums.dart';
import 'package:dope_i_mine/domain/avatar_v3/avatar_v3_migration.dart';

void main() {
  test('critical avatar layers are ordered anatomically', () {
    final layers = const AvatarV3LayerResolver().resolve(
      AvatarV3Migration.defaultReferenceProfile,
    );

    int z(AvatarV3LayerSlot slot) =>
        layers.firstWhere((layer) => layer.slot == slot).zIndex;

    expect(z(AvatarV3LayerSlot.backHair), lessThan(z(AvatarV3LayerSlot.head)));
    expect(z(AvatarV3LayerSlot.head), lessThan(z(AvatarV3LayerSlot.face)));
    expect(z(AvatarV3LayerSlot.face), lessThan(z(AvatarV3LayerSlot.frontHair)));
    expect(
      z(AvatarV3LayerSlot.facialHair),
      lessThan(z(AvatarV3LayerSlot.frontHair)),
    );
  });
}
