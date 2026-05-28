import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/network/connectivity_controller.dart';
import 'core/network/connectivity_status.dart';
import 'core/services/local_task_session_cache_service.dart';
import 'core/services/neural_tts_service.dart';
import 'core/services/permissions_service.dart';
import 'core/services/reminder_service.dart';
import 'core/services/sherpa_onnx_text_to_speech_service.dart';
import 'core/services/speech_to_text_service.dart';
import 'core/services/text_to_speech_service.dart';
import 'core/sync/sync_engine.dart';
import 'core/sync/sync_queue_service.dart';
import 'core/sync/sync_status_controller.dart';
import 'data/local/local_body_double_store.dart';
import 'data/local/local_notification_preferences_store.dart';
import 'data/local/local_voice_settings_store.dart';
import 'data/local/local_reward_store.dart';
import 'data/local/local_feedback_store.dart';
import 'data/local/local_settings_cache.dart';
import 'data/local/local_task_store.dart';
import 'data/repositories/analytics_repository_impl.dart';
import 'data/repositories/body_double_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/branding_repository_impl.dart';
import 'data/repositories/caregiver_assignments_repository_impl.dart';
import 'data/repositories/caregiver_repository_impl.dart';
import 'data/repositories/companion_repository_impl.dart';
import 'data/repositories/offline_first_task_repository.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'data/repositories/reminder_repository_impl.dart';
import 'data/repositories/routine_repository_impl.dart';
import 'data/repositories/side_quest_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/voice_settings_repository_impl.dart';
import 'domain/voice/installed_tts_voice_model.dart';
import 'data/repositories/reward_repository_impl.dart';
import 'domain/voice/voice_settings_model.dart';

final supabaseProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

T _requireClientRepo<T>(
    SupabaseClient? client, T Function(SupabaseClient c) build) {
  if (client == null) {
    throw StateError(
      'Supabase is not initialized. Run the app with '
      '--dart-define-from-file=.env.json or provide SUPABASE_URL and '
      'SUPABASE_ANON_KEY.',
    );
  }
  return build(client);
}

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return _requireClientRepo(
      ref.watch(supabaseProvider), AuthRepositoryImpl.new);
});

final profileRepositoryProvider = Provider<ProfileRepositoryImpl>((ref) {
  return _requireClientRepo(
      ref.watch(supabaseProvider), ProfileRepositoryImpl.new);
});

final localSettingsCacheProvider =
    FutureProvider<LocalSettingsCache>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return LocalSettingsCache(prefs);
});

final localNotificationPreferencesStoreProvider =
    Provider<LocalNotificationPreferencesStore>((ref) {
  return LocalNotificationPreferencesStore();
});

final localVoiceSettingsStoreProvider =
    Provider<LocalVoiceSettingsStore>((ref) {
  return LocalVoiceSettingsStore();
});

final bodyDoubleRepositoryProvider = Provider<BodyDoubleRepositoryImpl>((ref) {
  final client = ref.watch(supabaseProvider);
  return BodyDoubleRepositoryImpl(
    localStore: ref.watch(localBodyDoubleStoreProvider),
    client: client,
    userId: client?.auth.currentUser?.id,
  );
});

final taskRepositoryProvider = Provider<dynamic>((ref) {
  final client = ref.watch(supabaseProvider);
  return OfflineFirstTaskRepository(
    remote: client == null ? null : TaskRepositoryImpl(client),
    localTaskStore: ref.watch(localTaskStoreProvider),
    localRewardStore: ref.watch(localRewardStoreProvider),
    syncQueue: ref.watch(syncQueueServiceProvider),
    connectivityController: ref.watch(connectivityControllerProvider.notifier),
  );
});

final routineRepositoryProvider = Provider<RoutineRepositoryImpl>((ref) {
  return _requireClientRepo(
      ref.watch(supabaseProvider), RoutineRepositoryImpl.new);
});

final sideQuestRepositoryProvider = Provider<SideQuestRepositoryImpl>((ref) {
  return _requireClientRepo(
      ref.watch(supabaseProvider), SideQuestRepositoryImpl.new);
});

final rewardRepositoryProvider = Provider<RewardRepositoryImpl>((ref) {
  return _requireClientRepo(
      ref.watch(supabaseProvider), RewardRepositoryImpl.new);
});

final progressRepositoryProvider = Provider<ProgressRepositoryImpl>((ref) {
  return _requireClientRepo(
      ref.watch(supabaseProvider), ProgressRepositoryImpl.new);
});

final caregiverRepositoryProvider = Provider<CaregiverRepositoryImpl>((ref) {
  final client = ref.watch(supabaseProvider);
  if (client == null) throw StateError('Supabase client is required');
  return CaregiverRepositoryImpl(
    client: client,
    userId: client.auth.currentUser?.id,
  );
});

final caregiverAssignmentsRepositoryProvider =
    Provider<CaregiverAssignmentsRepositoryImpl>((ref) {
  return _requireClientRepo(
    ref.watch(supabaseProvider),
    CaregiverAssignmentsRepositoryImpl.new,
  );
});

final companionRepositoryProvider = Provider<CompanionRepositoryImpl>((ref) {
  return _requireClientRepo(
      ref.watch(supabaseProvider), CompanionRepositoryImpl.new);
});

final voiceSettingsRepositoryProvider =
    Provider<VoiceSettingsRepositoryImpl>((ref) {
  return _requireClientRepo(
    ref.watch(supabaseProvider),
    VoiceSettingsRepositoryImpl.new,
  );
});

final voiceSettingsProvider = FutureProvider<VoiceSettingsModel?>((ref) async {
  final auth = ref.watch(authRepositoryProvider);
  final user = auth.getCurrentUser();
  if (user == null) return null;

  final localStore = ref.watch(localVoiceSettingsStoreProvider);
  final localSettings = await localStore.load(user.id);
  final repo = ref.watch(voiceSettingsRepositoryProvider);
  try {
    final remoteSettings = await repo.getSettings(user.id);
    if (remoteSettings != null) {
      await localStore.save(userId: user.id, settings: remoteSettings);
      return remoteSettings;
    }
  } catch (_) {
    return localSettings;
  }
  return localSettings;
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    queueService: ref.watch(syncQueueServiceProvider),
    connectivityController: ref.watch(connectivityControllerProvider.notifier),
    supabaseClient: ref.watch(supabaseProvider),
    localTaskStore: ref.watch(localTaskStoreProvider),
  );
});

final syncAutoRunnerProvider = Provider<SyncAutoRunner>((ref) {
  final syncEngine = ref.watch(syncEngineProvider);
  final statusNotifier = ref.watch(syncStatusControllerProvider.notifier);

  ref.listen<ConnectivityStatus>(connectivityControllerProvider,
      (previous, next) async {
    if (next == ConnectivityStatus.online) {
      await syncEngine.syncNow();
      await statusNotifier.refresh();
    }
  });

  return SyncAutoRunner();
});

class SyncAutoRunner {}

final reminderRepositoryProvider = Provider<ReminderRepositoryImpl>((ref) {
  return ReminderRepositoryImpl();
});

final brandingRepositoryProvider = Provider<BrandingRepositoryImpl>((ref) {
  return BrandingRepositoryImpl();
});

final analyticsRepositoryProvider = Provider<AnalyticsRepositoryImpl>((ref) {
  return AnalyticsRepositoryImpl();
});

final speechToTextServiceProvider = Provider<SpeechToTextService>((ref) {
  return SpeechToTextService();
});

final textToSpeechServiceProvider = Provider<TextToSpeechService>((ref) {
  return TextToSpeechService();
});

final installedTtsVoicesProvider =
    FutureProvider<List<InstalledTtsVoiceModel>>((ref) async {
  return ref.watch(textToSpeechServiceProvider).installedVoices();
});

final neuralTtsServiceProvider = Provider<NeuralTtsService>((ref) {
  return NeuralTtsService(
    client: HttpNeuralTtsClient(),
    cache: NeuralTtsAudioCache(),
    player: const MethodChannelCachedAudioPlayer(),
  );
});

final sherpaOnnxTextToSpeechServiceProvider =
    Provider<SherpaOnnxTextToSpeechService>((ref) {
  return SherpaOnnxTextToSpeechService(
    modelManager: SherpaOnnxTtsModelManager(),
    cache: SherpaOnnxAudioCache(),
    player: const MethodChannelCachedAudioPlayer(),
  );
});

final localTaskSessionCacheProvider =
    Provider<LocalTaskSessionCacheService>((ref) {
  return LocalTaskSessionCacheService();
});

final localFeedbackStoreProvider = Provider<LocalFeedbackStore>((ref) {
  return LocalFeedbackStore();
});

final flutterLocalNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

final permissionsServiceProvider = Provider<PermissionsService>((ref) {
  return PermissionsService(ref.watch(flutterLocalNotificationsPluginProvider));
});

final notificationRepositoryProvider =
    Provider<NotificationRepositoryImpl>((ref) {
  return NotificationRepositoryImpl(ref.watch(supabaseProvider));
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(ref.watch(flutterLocalNotificationsPluginProvider));
});
