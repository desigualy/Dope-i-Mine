import 'package:dope_i_mine/domain/user_avatar/user_avatar_options.dart';
import 'package:dope_i_mine/domain/user_avatar/user_avatar_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('supports inclusive defaults and JSON round trip', () {
    const profile = UserAvatarProfile(
      skinTone: 'deep_brown',
      hairType: 'coily',
      hairStyle: 'afro',
      hairColor: 'black',
      bodyShape: 'larger_body',
      accessibilityItems: <String>['sensory_headphones'],
      culturalItems: <String>['headwrap'],
      pronouns: 'they/them',
    );

    final roundTrip = UserAvatarProfile.fromJson(profile.toJson());

    expect(roundTrip.skinTone, 'deep_brown');
    expect(roundTrip.hairType, 'coily');
    expect(roundTrip.bodyShape, 'larger_body');
    expect(roundTrip.accessibilityItems, contains('sensory_headphones'));
    expect(roundTrip.culturalItems, contains('headwrap'));
    expect(roundTrip.pronouns, 'they/them');
    expect(roundTrip.isHumanLike, isTrue);
    expect(roundTrip.isPortrait, isTrue);
  });

  test('supports exactly three avatar modes and normalizes legacy modes', () {
    expect(
        UserAvatarOptions.avatarTypes.map((option) => option.label), <String>[
      'Looks like me',
      'Inspired by me',
      'Private / abstract',
    ]);

    final legacy = UserAvatarProfile.fromJson(const <String, dynamic>{
      'avatarType': UserAvatarProfile.legacyAvatarTypeFantasyVersion,
    });

    expect(legacy.avatarType, UserAvatarProfile.avatarTypeInspiredByMe);
    expect(
      UserAvatarOptions.avatarTypes.map((option) => option.label),
      isNot(contains('Fantasy version')),
    );
  });

  test('privacy-first profile avoids human-like representation layers', () {
    const profile = UserAvatarProfile.privateAbstract(moodStyle: 'calm');
    final layers = const UserAvatarLayerResolver().layersFor(profile);

    expect(profile.isPrivacyFirst, isTrue);
    expect(layers, hasLength(2));
    expect(layers.map((layer) => layer.assetPath), <String>[
      'assets/user_avatar/backgrounds/soft_teal.png',
      'assets/user_avatar/abstract/orbs/calm.png',
    ]);
  });

  test('layer resolver maps accessibility and cultural items respectfully', () {
    const profile = UserAvatarProfile(
      clothingItems: <String>['school_uniform'],
      culturalItems: <String>['hijab'],
      accessibilityItems: <String>[
        'hearing_aids',
        'wheelchair',
        'glucose_monitor',
      ],
    );

    final paths = const UserAvatarLayerResolver()
        .layersFor(profile)
        .map((layer) => layer.assetPath)
        .toList();

    expect(paths,
        contains('assets/user_avatar/clothing/school/school_uniform.png'));
    expect(paths, contains('assets/user_avatar/cultural/hijab/hijab.png'));
    expect(
        paths,
        contains(
            'assets/user_avatar/accessibility/hearing_aids/hearing_aids.png'));
    expect(
        paths,
        contains(
            'assets/user_avatar/accessibility/wheelchairs/wheelchair.png'));
    expect(
        paths,
        contains(
            'assets/user_avatar/accessibility/medical_devices/glucose_monitor.png'));
  });

  test('identity representation categories cannot be premium-only', () {
    expect(UserAvatarOptions.canBePremiumOnly('skin_tone'), isFalse);
    expect(UserAvatarOptions.canBePremiumOnly('body_shape'), isFalse);
    expect(
      UserAvatarOptions.canBePremiumOnly('disability_representation'),
      isFalse,
    );
    expect(
      UserAvatarOptions.canBePremiumOnly('cultural_clothing_basics'),
      isFalse,
    );
    expect(
        UserAvatarOptions.canBePremiumOnly('premium_clothing_styles'), isTrue);
    expect(UserAvatarOptions.canBePremiumOnly('seasonal_effects'), isTrue);
  });
}
