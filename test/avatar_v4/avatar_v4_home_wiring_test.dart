import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home hero is wired to Avatar Engine V4', () {
    final home = File('lib/presentation/home/home_screen.dart').readAsStringSync();

    expect(home, contains('AvatarRiveView'));
    expect(home, contains("ValueKey<String>('home-avatar-v4-rive')"));
    expect(home, isNot(contains('UnifiedUserAvatar(')));
    expect(home, isNot(contains('FloatingDopeiAvatar(')));
  });

  test('Home avatar studio no longer previews the old portrait renderer', () {
    final studio = File('lib/presentation/user_avatar/user_avatar_studio.dart')
        .readAsStringSync();

    expect(studio, contains('AvatarRiveView'));
    expect(studio, contains('home-avatar-studio-v4-preview'));
    expect(studio, isNot(contains('PremiumPortraitAvatar(')));
    expect(studio, isNot(contains('AvatarCreatorScreen')));
  });

  test('Main router exposes the Avatar V4 customizer route', () {
    final router = File('lib/app/router.dart').readAsStringSync();

    expect(router, contains("path: '/avatar/customize'"));
    expect(router, contains('AvatarCustomizerScreen'));
  });
}
