import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  test('V3 public retirement policy names active and retired engines', () {
    expect(AvatarV4RetirementPolicy.activePublicEngine, contains('V4'));
    expect(
      AvatarV4RetirementPolicy.retiredPublicEngines,
      contains('Avatar V3 SVG/blob/layer renderer'),
    );
    expect(
      AvatarV4RetirementPolicy.blockedPublicSymbols,
      contains('UnifiedUserAvatar'),
    );
  });

  test('public avatar surfaces do not import retired V3/avatar fallback files',
      () {
    for (final relativePath in AvatarV4RetirementPolicy.publicSurfaceFiles) {
      final file = File(relativePath);
      expect(file.existsSync(), isTrue, reason: '$relativePath should exist');

      final content = file.readAsStringSync();

      for (final importFragment
          in AvatarV4RetirementPolicy.blockedPublicImportFragments) {
        expect(
          content.contains(importFragment),
          isFalse,
          reason:
              '$relativePath must not import retired public avatar surface $importFragment',
        );
      }
    }
  });

  test('public avatar surfaces do not reference retired public symbols', () {
    for (final relativePath in AvatarV4RetirementPolicy.publicSurfaceFiles) {
      final file = File(relativePath);
      expect(file.existsSync(), isTrue, reason: '$relativePath should exist');

      final content = file.readAsStringSync();

      for (final symbol in AvatarV4RetirementPolicy.blockedPublicSymbols) {
        expect(
          RegExp(r'\b' + RegExp.escape(symbol) + r'\b').hasMatch(content),
          isFalse,
          reason:
              '$relativePath must not reference retired public avatar symbol $symbol',
        );
      }
    }
  });

  test('home screen remains wired to Avatar Engine V4 public key', () {
    final home = File('lib/presentation/home/home_screen.dart');
    expect(home.existsSync(), isTrue);

    final content = home.readAsStringSync();

    expect(content, contains('home-avatar-v4-rive'));
    expect(content, contains('AvatarRiveView'));
  });
}
