import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers.dart' as app_providers;
import '../data/avatar_v4_local_cache.dart';
import '../data/avatar_v4_reference_image_service.dart';
import '../data/avatar_v4_reference_image_storage.dart';
import '../data/avatar_v4_repository.dart';
import '../data/avatar_v4_supabase_repository.dart';
import '../data/avatar_v4_sync_service.dart';
import '../domain/avatar_v4_config.dart';

final avatarV4OnlineProvider = FutureProvider<bool>((ref) async {
  final results = await Connectivity().checkConnectivity();
  return results.any((result) => result != ConnectivityResult.none);
});

final avatarV4CurrentUserIdProvider = Provider<String?>((ref) {
  final client = ref.watch(app_providers.supabaseProvider);
  return client?.auth.currentUser?.id;
});

final avatarV4LocalCacheProvider =
    FutureProvider<AvatarV4LocalCache>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return AvatarV4LocalCache(prefs);
});

final avatarV4RepositoryProvider = Provider<AvatarV4Repository>((ref) {
  final client = ref.watch(app_providers.supabaseProvider);
  if (client == null) {
    return const AvatarV4RepositoryUnavailable();
  }
  return AvatarV4SupabaseRepository(client);
});

final avatarV4ReferenceImageStorageProvider =
    Provider<AvatarV4ReferenceImageStorage?>((ref) {
  final client = ref.watch(app_providers.supabaseProvider);
  if (client == null) return null;
  return AvatarV4SupabaseReferenceImageStorage(client);
});

final avatarV4SyncServiceProvider =
    FutureProvider<AvatarV4SyncService>((ref) async {
  final localCache = await ref.watch(avatarV4LocalCacheProvider.future);
  final repository = ref.watch(avatarV4RepositoryProvider);

  return AvatarV4SyncService(
    localCache: localCache,
    repository: repository,
  );
});

final avatarV4EffectiveConfigProvider =
    FutureProvider<AvatarV4Config>((ref) async {
  final userId = ref.watch(avatarV4CurrentUserIdProvider);
  final isOnline = await ref.watch(avatarV4OnlineProvider.future);
  final syncService = await ref.watch(avatarV4SyncServiceProvider.future);

  return syncService.loadEffectiveConfig(
    userId: userId,
    isOnline: isOnline,
  );
});

final avatarV4ReferenceImageServiceProvider =
    Provider<AvatarV4ReferenceImageService?>((ref) {
  final storage = ref.watch(avatarV4ReferenceImageStorageProvider);
  if (storage == null) return null;

  return AvatarV4ReferenceImageService(
    storage: storage,
    repository: ref.watch(avatarV4RepositoryProvider),
  );
});
