import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/local_task_session_cache_service.dart';
import 'core/services/reminder_service.dart';
import 'core/services/speech_to_text_service.dart';
import 'core/services/text_to_speech_service.dart';
import 'data/repositories/analytics_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/branding_repository_impl.dart';
import 'data/repositories/caregiver_assignments_repository_impl.dart';
import 'data/repositories/caregiver_repository_impl.dart';
import 'data/repositories/companion_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'data/repositories/reminder_repository_impl.dart';
import 'data/repositories/routine_repository_impl.dart';
import 'data/repositories/side_quest_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/voice_settings_repository_impl.dart';

final supabaseProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

T _requireClientRepo<T>(SupabaseClient? client, T Function(SupabaseClient c) build) {
  if (client == null) {
    throw StateError('Supabase is not initialized.');
  }
  return build(client);
}

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return _requireClientRepo(ref.watch(supabaseProvider), AuthRepositoryImpl.new);
});

final profileRepositoryProvider = Provider<ProfileRepositoryImpl>((ref) {
  return _requireClientRepo(ref.watch(supabaseProvider), ProfileRepositoryImpl.new);
});

final taskRepositoryProvider = Provider<TaskRepositoryImpl>((ref) {
  return _requireClientRepo(ref.watch(supabaseProvider), TaskRepositoryImpl.new);
});

final routineRepositoryProvider = Provider<RoutineRepositoryImpl>((ref) {
  return _requireClientRepo(ref.watch(supabaseProvider), RoutineRepositoryImpl.new);
});

final sideQuestRepositoryProvider = Provider<SideQuestRepositoryImpl>((ref) {
  return _requireClientRepo(ref.watch(supabaseProvider), SideQuestRepositoryImpl.new);
});

final rewardRepositoryProvider = Provider<RewardRepositoryImpl>((ref) {
  return _requireClientRepo(ref.watch(supabaseProvider), RewardRepositoryImpl.new);
});

final progressRepositoryProvider = Provider<ProgressRepositoryImpl>((ref) {
  return _requireClientRepo(ref.watch(supabaseProvider), ProgressRepositoryImpl.new);
});

final caregiverRepositoryProvider = Provider<CaregiverRepositoryImpl>((ref) {
  return _requireClientRepo(ref.watch(supabaseProvider), CaregiverRepositoryImpl.new);
});

final caregiverAssignmentsRepositoryProvider =
    Provider<CaregiverAssignmentsRepositoryImpl>((ref) {
  return _requireClientRepo(
    ref.watch(supabaseProvider),
    CaregiverAssignmentsRepositoryImpl.new,
  );
});

final companionRepositoryProvider = Provider<CompanionRepositoryImpl>((ref) {
  return _requireClientRepo(ref.watch(supabaseProvider), CompanionRepositoryImpl.new);
});

final voiceSettingsRepositoryProvider =
    Provider<VoiceSettingsRepositoryImpl>((ref) {
  return _requireClientRepo(
    ref.watch(supabaseProvider),
    VoiceSettingsRepositoryImpl.new,
  );
});

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

final localTaskSessionCacheProvider =
    Provider<LocalTaskSessionCacheService>((ref) {
  return LocalTaskSessionCacheService();
});

final flutterLocalNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(ref.watch(flutterLocalNotificationsPluginProvider));
});
