import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/presentation/avatar_v3/hair/ringlet_afro/ringlet_hair_geometry.dart';

void main() {
  test('ringlet afro geometry has separated left and right side volume', () {
    expect(RingletAfroGeometry.hasLeftSideVolume, isTrue);
    expect(RingletAfroGeometry.hasRightSideVolume, isTrue);
    expect(RingletAfroGeometry.leftSideVolume.length, greaterThanOrEqualTo(4));
    expect(RingletAfroGeometry.rightSideVolume.length, greaterThanOrEqualTo(4));
  });

  test('ringlet afro geometry has rear halo and crown volume', () {
    expect(RingletAfroGeometry.hasRearHalo, isTrue);
    expect(RingletAfroGeometry.hasTopCrownVolume, isTrue);
    expect(RingletAfroGeometry.rearHalo.length, greaterThanOrEqualTo(8));
    expect(RingletAfroGeometry.crownVolume.length, greaterThanOrEqualTo(5));
  });

  test('ringlet afro geometry keeps mouth and chin zone clear', () {
    expect(RingletAfroGeometry.keepsMouthAndChinClear, isTrue);

    for (final curl in RingletAfroGeometry.allCurls) {
      expect(
        curl.violatesMouthChinExclusion,
        isFalse,
        reason: '${curl.region} at ${curl.center} enters the mouth/chin zone',
      );
    }
  });

  test('ringlet afro uses small natural curls instead of giant hoops', () {
    expect(RingletAfroGeometry.allCurls.length, greaterThanOrEqualTo(30));
    expect(RingletAfroGeometry.usesSmallNaturalCurls, isTrue);
  });
}
