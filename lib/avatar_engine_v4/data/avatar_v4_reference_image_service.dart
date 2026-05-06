import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../domain/avatar_v4_reference_image_upload.dart';
import '../domain/avatar_v4_sync_failure.dart';
import 'avatar_v4_reference_image_storage.dart';
import 'avatar_v4_repository.dart';

class AvatarV4ReferenceImageService {
  const AvatarV4ReferenceImageService({
    required AvatarV4ReferenceImageStorage storage,
    required AvatarV4Repository repository,
    DateTime Function()? now,
  })  : _storage = storage,
        _repository = repository,
        _now = now;

  static const String currentConsentVersion = 'avatar_reference_image_v1';

  final AvatarV4ReferenceImageStorage _storage;
  final AvatarV4Repository _repository;
  final DateTime Function()? _now;

  Future<AvatarV4ReferenceImageUpload> uploadPickedReferenceImageOnlineRequired({
    required String userId,
    required XFile file,
    required bool isOnline,
    String consentVersion = currentConsentVersion,
  }) async {
    final bytes = await file.readAsBytes();

    return uploadReferenceImageBytesOnlineRequired(
      userId: userId,
      bytes: bytes,
      originalFileName: file.name,
      mimeType: file.mimeType,
      isOnline: isOnline,
      consentVersion: consentVersion,
    );
  }

  Future<AvatarV4ReferenceImageUpload> uploadReferenceImageBytesOnlineRequired({
    required String userId,
    required Uint8List bytes,
    required String originalFileName,
    required String? mimeType,
    required bool isOnline,
    String consentVersion = currentConsentVersion,
  }) async {
    if (!isOnline) {
      throw const AvatarV4OfflineUpdateFailure();
    }

    final cleanUserId = userId.trim();
    if (cleanUserId.isEmpty) {
      throw const AvatarV4SyncFailure(
        'A signed-in user is required before uploading an avatar reference image.',
        code: 'avatar_upload_requires_user',
      );
    }

    if (bytes.isEmpty) {
      throw const AvatarV4SyncFailure(
        'The selected avatar reference image is empty.',
        code: 'avatar_upload_empty_file',
      );
    }

    final now = (_now ?? DateTime.now)().toUtc();
    final uploadedAtIso = now.toIso8601String();
    final storagePath = buildReferenceImageStoragePath(
      userId: cleanUserId,
      originalFileName: originalFileName,
      timestamp: now,
    );

    final storageResult = await _storage.uploadReferenceImageBytes(
      storagePath: storagePath,
      bytes: bytes,
      mimeType: mimeType,
    );

    await _repository.registerUploadedReferenceImage(
      userId: cleanUserId,
      storagePath: storageResult.storagePath,
      consentVersion: consentVersion,
    );

    return AvatarV4ReferenceImageUpload(
      userId: cleanUserId,
      storagePath: storageResult.storagePath,
      consentVersion: consentVersion,
      uploadedAtIso: uploadedAtIso,
      originalFileName: originalFileName,
      mimeType: mimeType,
    );
  }

  static String buildReferenceImageStoragePath({
    required String userId,
    required String originalFileName,
    required DateTime timestamp,
  }) {
    final safeUserId = _safeSegment(userId);
    final extension = _safeExtension(originalFileName);
    final stamp = timestamp.toUtc().toIso8601String().replaceAll(RegExp(r'[^0-9]'), '');

    return 'avatar_uploads/$safeUserId/${stamp}_reference$extension';
  }

  static String _safeSegment(String value) {
    final safe = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return safe.isEmpty ? 'unknown_user' : safe;
  }

  static String _safeExtension(String fileName) {
    final lower = fileName.toLowerCase();
    final dot = lower.lastIndexOf('.');
    if (dot < 0 || dot == lower.length - 1) return '.jpg';

    final raw = lower.substring(dot);
    if (raw == '.jpeg' || raw == '.jpg' || raw == '.png' || raw == '.webp') {
      return raw;
    }

    return '.jpg';
  }
}
