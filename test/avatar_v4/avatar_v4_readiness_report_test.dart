import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  test('readiness report marks code shell complete and real Rive asset required',
      () {
    expect(AvatarV4ReadinessReport.status, 'ready_for_real_rive_asset');
    expect(AvatarV4ReadinessReport.isCodeShellComplete, isTrue);
    expect(AvatarV4ReadinessReport.requiresRealRiveAsset, isTrue);
    expect(
      AvatarV4ReadinessReport.requiredRiveAssetPath,
      'assets/avatar_rive/base_avatar.riv',
    );
  });

  test('readiness report includes completed pass 3L', () {
    expect(
      AvatarV4ReadinessReport.completedPasses,
      contains('3L readiness report + runbook'),
    );
  });

  test('readiness report locks remaining required passes', () {
    expect(
      AvatarV4ReadinessReport.remainingRequiredPasses,
      containsAll(<String>[
        '4A Real Rive rig import',
        '4B Control binding QA',
        '4C Visual QA iteration',
      ]),
    );
  });

  test('readiness docs exist', () {
    for (final path in AvatarV4ReadinessReport.readinessDocs) {
      expect(File(path).existsSync(), isTrue, reason: '$path should exist');
    }
  });
}
