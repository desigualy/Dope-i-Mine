import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('base Rive acquisition workflow docs and tools exist', () {
    final paths = <String>[
      'docs/avatar_v4/AVATAR_V4_BASE_RIVE_BUILD_WORKFLOW.md',
      'docs/avatar_v4/AVATAR_V4_RIVE_ARTIST_DELIVERY_CHECKLIST.md',
      'docs/avatar_v4/AVATAR_V4_RIVE_IMPORT_QA_RUNBOOK.md',
      'assets/avatar_rive/base_avatar_import_manifest.json',
      'tools/import_avatar_v4_base_rive.ps1',
      'tools/verify_avatar_v4_base_rive.ps1',
    ];

    for (final path in paths) {
      expect(File(path).existsSync(), isTrue, reason: '$path should exist');
    }
  });

  test('base Rive import manifest keeps runtime contract stable', () {
    final manifest = jsonDecode(
      File('assets/avatar_rive/base_avatar_import_manifest.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(manifest['assetPath'], 'assets/avatar_rive/base_avatar.riv');
    expect(manifest['requiredArtboard'], 'Avatar');
    expect(manifest['requiredStateMachine'], 'AvatarState');

    expect(
      manifest['requiredNumberInputs'],
      containsAll(<String>[
        'skinTone',
        'faceShape',
        'hairPack',
        'hairStyle',
        'hairColor',
        'bodyPreset',
      ]),
    );

    expect(
      manifest['requiredBooleanInputs'],
      containsAll(<String>[
        'freckles',
        'vitiligo',
        'hasFacialHair',
        'hasGlasses',
      ]),
    );

    expect(
      manifest['fallbackRule'],
      contains('Do not restore the V3 blob renderer'),
    );
  });
}
