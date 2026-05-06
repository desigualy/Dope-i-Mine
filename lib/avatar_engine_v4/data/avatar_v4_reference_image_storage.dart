import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarV4ReferenceImageStorageResult {
  const AvatarV4ReferenceImageStorageResult({
    required this.storagePath,
  });

  final String storagePath;
}

abstract class AvatarV4ReferenceImageStorage {
  Future<AvatarV4ReferenceImageStorageResult> uploadReferenceImageBytes({
    required String storagePath,
    required Uint8List bytes,
    required String? mimeType,
  });
}

class AvatarV4SupabaseReferenceImageStorage
    implements AvatarV4ReferenceImageStorage {
  const AvatarV4SupabaseReferenceImageStorage(
    this._client, {
    this.bucketId = defaultBucketId,
  });

  static const String defaultBucketId = 'avatar-reference-images';

  final SupabaseClient _client;
  final String bucketId;

  @override
  Future<AvatarV4ReferenceImageStorageResult> uploadReferenceImageBytes({
    required String storagePath,
    required Uint8List bytes,
    required String? mimeType,
  }) async {
    await _client.storage.from(bucketId).uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            contentType: mimeType,
            upsert: false,
          ),
        );

    return AvatarV4ReferenceImageStorageResult(storagePath: storagePath);
  }
}
