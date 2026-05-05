import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/avatar_v3/avatar_v3_options.dart';
import '../../domain/avatar_v3/avatar_v3_profile.dart';
import '../local/local_avatar_v3_inventory_store.dart';
import 'avatar_v3_repository.dart';

class SupabaseAvatarV3Repository implements AvatarV3Repository {
  SupabaseAvatarV3Repository({
    SupabaseClient? client,
    required this.userId,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final String userId;

  @override
  Future<AvatarV3Profile?> loadProfile() async {
    final data = await _client
        .from('avatar_v3_profiles')
        .select('profile_json')
        .eq('user_id', userId)
        .maybeSingle();

    final json = data?['profile_json'];
    if (json is Map<String, dynamic>) {
      return AvatarV3Options.normalize(AvatarV3Profile.fromJson(json));
    }
    if (json is Map) {
      return AvatarV3Options.normalize(
        AvatarV3Profile.fromJson(Map<String, dynamic>.from(json)),
      );
    }
    return null;
  }

  @override
  Future<void> saveProfile(AvatarV3Profile profile) async {
    final normalized = AvatarV3Options.normalize(profile);
    await _client.from('avatar_v3_profiles').upsert(<String, dynamic>{
      'user_id': userId,
      'profile_json': normalized.toJson(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  @override
  Future<AvatarV3Inventory> loadInventory() async {
    final data = await _client
        .from('avatar_v3_inventory')
        .select('owned_asset_ids, owned_pack_ids, updated_at')
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return const AvatarV3Inventory();

    return AvatarV3Inventory(
      ownedAssetIds: (data['owned_asset_ids'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(),
      ownedPackIds: (data['owned_pack_ids'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(),
      updatedAt: data['updated_at'] is String
          ? DateTime.tryParse(data['updated_at'] as String)
          : null,
    );
  }

  @override
  Future<void> saveInventory(AvatarV3Inventory inventory) async {
    await _client.from('avatar_v3_inventory').upsert(<String, dynamic>{
      'user_id': userId,
      'owned_asset_ids': inventory.ownedAssetIds,
      'owned_pack_ids': inventory.ownedPackIds,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }
}
