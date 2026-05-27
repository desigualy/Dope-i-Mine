import 'package:dope_i_mine/data/repositories/auth_repository_impl.dart';
import 'package:dope_i_mine/data/repositories/voice_settings_repository_impl.dart';
import 'package:dope_i_mine/domain/auth/auth_user.dart';
import 'package:dope_i_mine/domain/voice/voice_profile_model.dart';
import 'package:dope_i_mine/domain/voice/voice_settings_model.dart';
import 'package:dope_i_mine/presentation/settings/voice_profile_screen.dart';
import 'package:dope_i_mine/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepositoryImpl {
  @override
  AuthUser? getCurrentUser() {
    return const AuthUser(id: 'tester', email: 'tester@example.com');
  }

  @override
  Future<void> completeForcedPasswordChange(String password) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) async {
    return getCurrentUser();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser?> signUp({
    required String email,
    required String password,
    String accountType = 'user',
  }) async {
    return getCurrentUser();
  }

  @override
  Future<void> updatePassword(String password) async {}
}

class _FakeVoiceSettingsRepository implements VoiceSettingsRepositoryImpl {
  VoiceSettingsModel? savedSettings;

  @override
  Future<VoiceSettingsModel?> getSettings(String userId) async => null;

  @override
  Future<VoiceProfileModel?> getVoiceProfile(String? profileId) async {
    if (profileId == null) return null;
    for (final profile in await getVoiceProfiles()) {
      if (profile.id == profileId) return profile;
    }
    return null;
  }

  @override
  Future<List<VoiceProfileModel>> getVoiceProfiles() async {
    return const <VoiceProfileModel>[
      VoiceProfileModel(
        id: 'calm',
        provider: 'system',
        label: 'Calm Guide',
        localeId: 'en-GB',
        accent: 'UK',
        gender: 'female',
        pace: 'slow',
        warmth: 'high',
        firmness: 'low',
        tonePreset: 'calm',
      ),
      VoiceProfileModel(
        id: 'bright',
        provider: 'system',
        label: 'Bright Coach',
        localeId: 'en-US',
        accent: 'US',
        gender: 'female',
        pace: 'bright',
        warmth: 'medium',
        firmness: 'medium',
        tonePreset: 'bright',
      ),
    ];
  }

  @override
  Future<void> save({
    required String userId,
    required VoiceSettingsModel settings,
  }) async {
    savedSettings = settings;
  }
}

void main() {
  testWidgets('voice settings recovers when saved voice id is unavailable',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'settings.voice.tester':
          '{"activeVoiceProfileId":"removed_voice","localeId":"en-AU","speechRate":0.7,"autoReadSteps":true,"autoReadSidequests":false}',
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          voiceSettingsRepositoryProvider
              .overrideWithValue(_FakeVoiceSettingsRepository()),
        ],
        child: const MaterialApp(home: VoiceProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Voice settings'), findsOneWidget);
    expect(find.text('Calm Guide'), findsOneWidget);
  });

  testWidgets('voice settings can change selected voice without crashing',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          voiceSettingsRepositoryProvider
              .overrideWithValue(_FakeVoiceSettingsRepository()),
        ],
        child: const MaterialApp(home: VoiceProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Calm Guide'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bright Coach').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Bright Coach'), findsOneWidget);
  });

  testWidgets('voice settings clamps profile rates to slider bounds',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          voiceSettingsRepositoryProvider
              .overrideWithValue(_FakeVoiceSettingsRepository()),
        ],
        child: const MaterialApp(home: VoiceProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, greaterThanOrEqualTo(slider.min));
    expect(slider.value, lessThanOrEqualTo(slider.max));
  });
}
