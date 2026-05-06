import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Rive handoff documentation exists', () {
    final files = <String>[
      'docs/avatar_v4/AVATAR_V4_RIVE_HANDOFF_SPEC.md',
      'docs/avatar_v4/AVATAR_V4_RIVE_INPUT_MAP.md',
      'docs/avatar_v4/AVATAR_V4_LAYER_NAMING_CONTRACT.md',
      'docs/avatar_v4/AVATAR_V4_QA_CHECKLIST.md',
      'docs/avatar_v4/AVATAR_V4_ARTIST_BRIEF.md',
      'assets/avatar_rive/avatar_v4_rive_handoff.json',
      'assets/avatar_rive/base_avatar.riv.README_PLACEHOLDER.txt',
    ];

    for (final path in files) {
      expect(File(path).existsSync(), isTrue, reason: '$path should exist');
    }
  });

  test('Rive handoff JSON matches runtime contract names', () {
    final file = File('assets/avatar_rive/avatar_v4_rive_handoff.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    expect(json['file'], 'assets/avatar_rive/base_avatar.riv');
    expect(json['artboard'], 'Avatar');
    expect(json['stateMachine'], 'AvatarState');

    expect(
      json['requiredNumberInputs'],
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
      json['requiredBooleanInputs'],
      containsAll(<String>[
        'freckles',
        'vitiligo',
        'hasFacialHair',
        'hasGlasses',
      ]),
    );
  });
}
