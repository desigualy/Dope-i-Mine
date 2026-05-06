import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  testWidgets('reference image panel blocks upload while offline',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AvatarReferenceImagePanel(
            userId: 'user-1',
            isOnline: false,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('avatar-v4-reference-image-panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('avatar-v4-reference-offline-message')),
      findsOneWidget,
    );

    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey<String>('avatar-v4-reference-upload-button')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('reference image panel requires consent before upload',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AvatarReferenceImagePanel(
            userId: 'user-1',
            isOnline: true,
            service: _NeverCalledReferenceImageService(),
          ),
        ),
      ),
    );

    var button = tester.widget<FilledButton>(
      find.byKey(const ValueKey<String>('avatar-v4-reference-upload-button')),
    );
    expect(button.onPressed, isNull);

    await tester.tap(
      find.byKey(const ValueKey<String>('avatar-v4-reference-consent')),
    );
    await tester.pump();

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
