import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding avatar setup is Avatar V4 only', () {
    final file = File('lib/presentation/onboarding/avatar_setup_screen.dart');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();

    expect(content, contains('AvatarRiveView'));
    expect(content, contains('AvatarV4Config'));
    expect(content, contains('onboarding-avatar-preview'));

    expect(content, isNot(contains('AvatarCreatorScreen')));
    expect(content, isNot(contains('AvatarCandidateSelectorScreen')));
    expect(content, isNot(contains('AvatarPreviewCard')));
    expect(content, isNot(contains('currentUserAvatarConfigProvider')));
    expect(content, isNot(contains('domain/avatar/user_avatar_profile.dart')));
    expect(content, isNot(contains('data/avatar/')));
  });

  test('voice setup routes to identity before avatar', () {
    final file = File('lib/presentation/onboarding/voice_setup_screen.dart');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();

    expect(content, contains('/onboarding/identity'));
    expect(content, isNot(contains("'/onboarding/avatar'")));
    expect(content, isNot(contains('"/onboarding/avatar"')));
  });

  test('router exposes identity onboarding route', () {
    final file = File('lib/app/router.dart');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();

    expect(content, contains('identity_screen.dart'));
    expect(content, contains('/onboarding/identity'));
    expect(content, contains('IdentityScreen'));
  });

  test('identity screen exposes sex gender pronouns fields and routes onward',
      () {
    final file = File('lib/presentation/onboarding/identity_screen.dart');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();

    expect(content, contains('Sex, gender & pronouns'));
    expect(content, contains('onboarding-sex-at-birth-field'));
    expect(content, contains('onboarding-gender-identity-field'));
    expect(content, contains('onboarding-pronouns-field'));
    expect(content, contains('/onboarding/avatar'));
  });

  test('repository and onboarding state persist identity fields', () {
    final summary =
        File('lib/presentation/onboarding/onboarding_summary_screen.dart')
            .readAsStringSync();
    final repository =
        File('lib/data/repositories/profile_repository_impl.dart')
            .readAsStringSync();
    final state =
        File('lib/domain/onboarding/onboarding_state.dart').readAsStringSync();

    expect(summary, contains('sexAtBirth: state.sexAtBirth.name'));
    expect(summary, contains('genderIdentity: state.genderIdentity.name'));
    expect(summary, contains('pronouns: state.pronouns.name'));
    expect(summary, contains('customPronouns: state.customPronouns'));
    expect(summary, contains('identity, avatar, and voice details'));

    expect(repository, contains('sex_at_birth'));
    expect(repository, contains('gender_identity'));
    expect(repository, contains('pronouns'));
    expect(repository, contains('custom_pronouns'));

    expect(state, contains('enum SexAtBirth'));
    expect(state, contains('enum GenderIdentity'));
    expect(state, contains('enum PronounSet'));
    expect(state, contains('String get pronounDisplay'));
  });
}
