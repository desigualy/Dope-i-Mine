import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  test('Rive contract defines the expected base rig identity', () {
    expect(
      AvatarV4RiveContract.baseRigAssetPath,
      'assets/avatar_rive/base_avatar.riv',
    );
    expect(AvatarV4RiveContract.artboardName, 'Avatar');
    expect(AvatarV4RiveContract.stateMachineName, 'AvatarState');
  });

  test('Rive contract includes required number inputs', () {
    expect(
      AvatarV4RiveContract.requiredNumberInputs,
      containsAll(<String>[
        'skinTone',
        'faceShape',
        'hairPack',
        'hairStyle',
        'hairColor',
        'bodyPreset',
      ]),
    );
  });

  test('Rive contract includes required boolean inputs', () {
    expect(
      AvatarV4RiveContract.requiredBooleanInputs,
      containsAll(<String>[
        'freckles',
        'vitiligo',
        'hasFacialHair',
        'hasGlasses',
      ]),
    );
  });

  test('starter config follows the Rive contract defaults', () {
    const config = AvatarV4Config();

    expect(config.rigAssetPath, AvatarV4RiveContract.baseRigAssetPath);
    expect(config.artboardName, AvatarV4RiveContract.artboardName);
    expect(config.stateMachineName, AvatarV4RiveContract.stateMachineName);
  });
}
