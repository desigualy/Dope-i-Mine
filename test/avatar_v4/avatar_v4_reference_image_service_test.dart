import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  test('reference image upload is blocked while offline', () async {
    final service = AvatarV4ReferenceImageService(
      storage: _FakeReferenceImageStorage(),
      repository: _FakeAvatarV4Repository(),
      now: () => DateTime.utc(2026, 5, 6, 12),
    );

    expect(
      () => service.uploadReferenceImageBytesOnlineRequired(
        userId: 'user-1',
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        originalFileName: 'face.png',
        mimeType: 'image/png',
        isOnline: false,
      ),
      throwsA(isA<AvatarV4OfflineUpdateFailure>()),
    );
  });

  test('reference image upload stores bytes and registers metadata online',
      () async {
    final storage = _FakeReferenceImageStorage();
    final repository = _FakeAvatarV4Repository();
    final service = AvatarV4ReferenceImageService(
      storage: storage,
      repository: repository,
      now: () => DateTime.utc(2026, 5, 6, 12, 30, 45),
    );

    final upload = await service.uploadReferenceImageBytesOnlineRequired(
      userId: 'user-1',
      bytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
      originalFileName: 'face.png',
      mimeType: 'image/png',
      isOnline: true,
    );

    expect(storage.lastPath, 'avatar_uploads/user-1/20260506123045000_reference.png');
    expect(storage.lastMimeType, 'image/png');
    expect(repository.uploadedStoragePath, upload.storagePath);
    expect(repository.uploadedConsentVersion,
        AvatarV4ReferenceImageService.currentConsentVersion);
  });

  test('reference image path sanitizes user id and unsupported extension', () {
    final path = AvatarV4ReferenceImageService.buildReferenceImageStoragePath(
      userId: 'user / weird',
      originalFileName: 'photo.gif',
      timestamp: DateTime.utc(2026, 5, 6, 1, 2, 3),
    );

    expect(path, 'avatar_uploads/user___weird/20260506010203000_reference.jpg');
  });
}

class _FakeReferenceImageStorage implements AvatarV4ReferenceImageStorage {
  String? lastPath;
  String? lastMimeType;
  Uint8List? lastBytes;

  @override
  Future<AvatarV4ReferenceImageStorageResult> uploadReferenceImageBytes({
    required String storagePath,
    required Uint8List bytes,
    required String? mimeType,
  }) async {
    lastPath = storagePath;
    lastMimeType = mimeType;
    lastBytes = bytes;
    return AvatarV4ReferenceImageStorageResult(storagePath: storagePath);
  }
}

class _FakeAvatarV4Repository implements AvatarV4Repository {
  String? uploadedUserId;
  String? uploadedStoragePath;
  String? uploadedConsentVersion;

  @override
  Future<AvatarV4Config?> loadRemoteConfig(String userId) async => null;

  @override
  Future<void> saveRemoteConfig(String userId, AvatarV4Config config) async {}

  @override
  Future<AvatarV4Inventory> loadRemoteInventory(String userId) async {
    return const AvatarV4Inventory();
  }

  @override
  Future<void> saveRemoteInventory(
    String userId,
    AvatarV4Inventory inventory,
  ) async {}

  @override
  Future<void> registerUploadedReferenceImage({
    required String userId,
    required String storagePath,
    required String consentVersion,
  }) async {
    uploadedUserId = userId;
    uploadedStoragePath = storagePath;
    uploadedConsentVersion = consentVersion;
  }
}
