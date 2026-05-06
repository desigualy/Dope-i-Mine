import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  test('asset handoff points to the locked production Rive rig path', () {
    expect(
      AvatarV4AssetHandoff.productionRigPath,
      AvatarV4RiveContract.baseRigAssetPath,
    );
    expect(
      AvatarV4AssetHandoff.productionRigPath,
      'assets/avatar_rive/base_avatar.riv',
    );
  });

  test('asset handoff files exist', () {
    for (final path in AvatarV4AssetHandoff.requiredHandoffFiles) {
      expect(File(path).existsSync(), isTrue, reason: '$path should exist');
    }
  });

  test('artist brief contains hard rejection rule for beard-like hair', () {
    final brief = File(AvatarV4AssetHandoff.artistBriefPath).readAsStringSync();

    expect(brief, contains('hair appears like a beard'));
    expect(brief, contains('Apple Memoji / Meta Avatar quality target'));
  });

  test('technical contract contains required Rive input names', () {
    final contract =
        File(AvatarV4AssetHandoff.technicalContractPath).readAsStringSync();

    for (final input in AvatarV4RiveContract.requiredInputs) {
      expect(contract, contains(input), reason: '$input should be documented');
    }
  });
}
