import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  test('starter config is Rive primary and uses ringlet afro default', () {
    final config = AvatarV4Config.starter();

    expect(config.engineMode, AvatarEngineMode.rivePrimary);
    expect(config.rigAssetPath, AvatarV4Config.defaultBaseRigAssetPath);
    expect(config.hairPackId, 'hair_ringlet_afro_v1');
    expect(config.hairStyleId, 'long_copper_ringlet_afro');
    expect(config.hairColor, 'copper_brown');
  });

  test('config round trips through json', () {
    final config = AvatarV4Config.starter().copyWith(
      accessoryIds: const <String>['glasses', 'hearing_aid_left'],
      ownedItemIds: const <String>['starter_black_top'],
    );

    final restored = AvatarV4Config.fromJson(config.toJson());

    expect(restored.engineMode, config.engineMode);
    expect(restored.hairStyleId, config.hairStyleId);
    expect(restored.accessoryIds, config.accessoryIds);
    expect(restored.ownedItemIds, config.ownedItemIds);
  });
}
