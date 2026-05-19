import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dope_i_mine/data/local/local_settings_cache.dart';
import 'package:dope_i_mine/domain/profile/sensory_settings_model.dart';

void main() {
  test('sensory settings persist across cache re-creation', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final prefs = await SharedPreferences.getInstance();
    final cache = LocalSettingsCache(prefs);

    const settings = SensorySettingsModel(
      reducedAnimation: true,
      largeText: true,
      softColors: false,
      soundEnabled: false,
      praiseLevel: 'low',
      iconMode: true,
      reduceSurprises: false,
    );

    await cache.saveSensorySettings('user-1', settings);

    final restoredCache =
        LocalSettingsCache(await SharedPreferences.getInstance());
    final restored = await restoredCache.loadSensorySettings('user-1');

    expect(restored, isNotNull);
    expect(restored!.reducedAnimation, isTrue);
    expect(restored.largeText, isTrue);
    expect(restored.softColors, isFalse);
    expect(restored.soundEnabled, isFalse);
    expect(restored.praiseLevel, 'low');
    expect(restored.iconMode, isTrue);
    expect(restored.reduceSurprises, isFalse);
  });

  test('missing sensory settings return null without throwing', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final cache = LocalSettingsCache(await SharedPreferences.getInstance());

    expect(await cache.loadSensorySettings('missing-user'), isNull);
  });
}
