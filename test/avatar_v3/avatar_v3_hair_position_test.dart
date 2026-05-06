// ignore_for_file: prefer_const_declarations
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/presentation/avatar_v3/avatar_v3_inline_assets.dart';

void main() {
  test('Pass 2C ringlet afro back hair has separated side volumes', () {
    final svg = AvatarV3InlineAssets.ringletAfroBackLongCopper;

    expect(svg, contains('left side volume'));
    expect(svg, contains('right side volume'));
    expect(svg, contains('rear halo'));
    expect(svg, contains('top crown volume'));
    expect(svg, contains('not over mouth/chin'));
    expect(svg, contains('clear centre face'));
  });

  test('Pass 2C front hair stays above the face', () {
    final svg = AvatarV3InlineAssets.ringletAfroFrontLongCopper;

    expect(svg, contains('soft hairline crown sitting on head, not face'));
    expect(svg, contains('small ringlets at temples only'));
    expect(svg, contains('kept above eyebrows'));
  });
}
