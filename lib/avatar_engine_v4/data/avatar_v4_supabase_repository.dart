import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/avatar_v4_config.dart';
import '../domain/avatar_v4_inventory.dart';
import 'avatar_v4_repository.dart';

class AvatarV4SupabaseTables {
  const AvatarV4SupabaseTables._();

  static const String profiles = 'avatar_profiles';
  static const String inventory = 'avatar_inventory';
  static const String purchases = 'avatar_purchases';
  static const String uploads = 'avatar_uploads';
}

class AvatarV4SupabaseRepository implements AvatarV4Repository {
  const AvatarV4SupabaseRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AvatarV4Config?> loadRemoteConfig(String userId) async {
    final row = await _client
        .from(AvatarV4SupabaseTables.profiles)
        .select('config')
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) return null;

    final rawConfig = row['config'];
    if (rawConfig is Map<String, dynamic>) {
      return AvatarV4Config.fromJson(rawConfig);
    }
    if (rawConfig is Map) {
      return AvatarV4Config.fromJson(Map<String, dynamic>.from(rawConfig));
    }

    return null;
  }

  @override
  Future<void> saveRemoteConfig(String userId, AvatarV4Config config) async {
    await _client.from(AvatarV4SupabaseTables.profiles).upsert(
      <String, dynamic>{
        'user_id': userId,
        'config': config.toJson(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  @override
  Future<AvatarV4Inventory> loadRemoteInventory(String userId) async {
    final row = await _client
        .from(AvatarV4SupabaseTables.inventory)
        .select('owned_item_ids,cached_pack_ids,last_synced_at')
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) return const AvatarV4Inventory();

    return AvatarV4Inventory(
      ownedItemIds: _strings(row['owned_item_ids']),
      cachedPackIds: _strings(row['cached_pack_ids']),
      lastSyncedAtIso: row['last_synced_at'] is String
          ? row['last_synced_at'] as String
          : null,
    );
  }

  @override
  Future<void> saveRemoteInventory(
    String userId,
    AvatarV4Inventory inventory,
  ) async {
    await _client.from(AvatarV4SupabaseTables.inventory).upsert(
      <String, dynamic>{
        'user_id': userId,
        'owned_item_ids': inventory.ownedItemIds,
        'cached_pack_ids': inventory.cachedPackIds,
        'last_synced_at':
            inventory.lastSyncedAtIso ?? DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  @override
  Future<void> registerUploadedReferenceImage({
    required String userId,
    required String storagePath,
    required String consentVersion,
  }) async {
    await _client.from(AvatarV4SupabaseTables.uploads).insert(
      <String, dynamic>{
        'user_id': userId,
        'storage_path': storagePath,
        'consent_version': consentVersion,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  static List<String> _strings(Object? value) {
    if (value is Iterable) {
      return value
          .whereType<String>()
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }
}
