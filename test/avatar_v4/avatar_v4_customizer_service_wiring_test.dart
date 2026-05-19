import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  testWidgets('customizer shows reference panel with offline state by default',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AvatarCustomizerScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Avatar'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('avatar-v4-reference-image-panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('avatar-v4-reference-offline-message')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('avatar-v4-reference-service-missing')),
      findsOneWidget,
    );
  });

  testWidgets('customizer uses injected online/user/service providers',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = _NeverCalledReferenceImageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          avatarV4CurrentUserIdProvider.overrideWithValue('user-1'),
          avatarV4OnlineProvider.overrideWith(
            (ref) async => true,
          ),
          avatarV4ReferenceImageServiceProvider.overrideWithValue(service),
          avatarV4EffectiveConfigProvider.overrideWith(
            (ref) async => const AvatarV4Config(),
          ),
        ],
        child: const MaterialApp(
          home: AvatarCustomizerScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byKey(const ValueKey<String>('avatar-v4-reference-image-panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('avatar-v4-reference-offline-message')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('avatar-v4-reference-service-missing')),
      findsNothing,
    );

    var button = tester.widget<FilledButton>(
      find.byKey(const ValueKey<String>('avatar-v4-reference-upload-button')),
    );
    expect(button.onPressed, isNull);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('avatar-v4-reference-consent')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('avatar-v4-reference-consent')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    button = tester.widget<FilledButton>(
      find.byKey(const ValueKey<String>('avatar-v4-reference-upload-button')),
    );
    expect(button.onPressed, isNotNull);
  });
}

class _NeverCalledReferenceImageService extends AvatarV4ReferenceImageService {
  _NeverCalledReferenceImageService()
      : super(
          storage: _ThrowingStorage(),
          repository: const AvatarV4RepositoryUnavailable(),
        );
}

class _ThrowingStorage implements AvatarV4ReferenceImageStorage {
  @override
  Future<AvatarV4ReferenceImageStorageResult> uploadReferenceImageBytes({
    required String storagePath,
    required Uint8List bytes,
    required String? mimeType,
  }) {
    throw UnimplementedError();
  }
}
