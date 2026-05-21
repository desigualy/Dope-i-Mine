import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sync/sync_queue_item.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../data/local/local_notification_preferences_store.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/notifications/notification_preferences_model.dart';
import '../../providers.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  bool _loading = true;
  NotificationPreferencesModel? _preferences;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) {
      setState(() {
        _loading = false;
        _statusMessage = 'Sign in to manage notification preferences.';
      });
      return;
    }

    final localPreferences = await ref
        .read(localNotificationPreferencesStoreProvider)
        .load(authUser.id);
    if (localPreferences != null) {
      setState(() {
        _preferences = localPreferences;
        _loading = false;
      });
    }

    try {
      final preferences = await ref
          .read(notificationRepositoryProvider)
          .getPreferences(authUser.id);
      setState(() {
        _preferences = preferences;
        _loading = false;
      });
      if (preferences != null) {
        await ref
            .read(localNotificationPreferencesStoreProvider)
            .save(preferences);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _statusMessage = _preferences == null
            ? 'Unable to load remote preferences. Showing local values.'
            : _statusMessage;
      });
    }
  }

  Future<void> _savePreferences() async {
    final preferences = _preferences;
    if (preferences == null) return;

    setState(() => _loading = true);
    await ref
        .read(localNotificationPreferencesStoreProvider)
        .save(preferences.copyWith(updatedAt: DateTime.now()));

    try {
      final saved = await ref
          .read(notificationRepositoryProvider)
          .savePreferences(preferences.copyWith(updatedAt: DateTime.now()));
      setState(() {
        _preferences = saved ?? preferences;
        _loading = false;
        _statusMessage = 'Preferences saved.';
      });
      if (saved != null) {
        await ref
            .read(localNotificationPreferencesStoreProvider)
            .save(saved);
      }
    } catch (error) {
      await ref.read(syncQueueServiceProvider).enqueue(
            SyncQueueItem.create(
              type: 'save_notification_preferences',
              idempotencyKey: 'save_notification_preferences_${preferences.userId}',
              payload: <String, dynamic>{
                'userId': preferences.userId,
                'enabled': preferences.enabled,
                'quietHoursStart': preferences.quietHoursStart,
                'quietHoursEnd': preferences.quietHoursEnd,
                'allowTaskReminders': preferences.allowTaskReminders,
                'allowCaregiverNotifications':
                    preferences.allowCaregiverNotifications,
                'allowBodyDoubleNotifications':
                    preferences.allowBodyDoubleNotifications,
                'allowSideQuests': preferences.allowSideQuests,
                'allowModerationUpdates': preferences.allowModerationUpdates,
              },
            ),
          );
      setState(() {
        _loading = false;
        _statusMessage =
            'Preferences saved locally; will sync when online.';
      });
    }
  }

  Future<void> _requestPermission() async {
    final granted = await ref.read(permissionsServiceProvider).requestNotifications();
    setState(() {
      _statusMessage = granted
          ? 'Notification access granted.'
          : 'Notification permission was not granted.';
    });
  }

  void _updatePreference({
    bool? enabled,
    bool? allowTaskReminders,
    bool? allowCaregiverNotifications,
    bool? allowBodyDoubleNotifications,
    bool? allowSideQuests,
    bool? allowModerationUpdates,
  }) {
    final current = _preferences;
    if (current == null) return;
    setState(() {
      _preferences = current.copyWith(
        enabled: enabled,
        allowTaskReminders: allowTaskReminders,
        allowCaregiverNotifications: allowCaregiverNotifications,
        allowBodyDoubleNotifications: allowBodyDoubleNotifications,
        allowSideQuests: allowSideQuests,
        allowModerationUpdates: allowModerationUpdates,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_statusMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(_statusMessage!),
                    ),
                  SwitchListTile(
                    title: const Text('Enable notifications'),
                    subtitle: const Text(
                      'Receive reminders, caregiver updates, and body double alerts.',
                    ),
                    value: _preferences?.enabled ?? false,
                    onChanged: (value) {
                      _updatePreference(enabled: value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Task reminders'),
                    value: _preferences?.allowTaskReminders ?? false,
                    onChanged: (value) {
                      _updatePreference(allowTaskReminders: value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Caregiver updates'),
                    value: _preferences?.allowCaregiverNotifications ?? false,
                    onChanged: (value) {
                      _updatePreference(allowCaregiverNotifications: value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Body double alerts'),
                    value: _preferences?.allowBodyDoubleNotifications ?? false,
                    onChanged: (value) {
                      _updatePreference(allowBodyDoubleNotifications: value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Side quest suggestions'),
                    value: _preferences?.allowSideQuests ?? false,
                    onChanged: (value) {
                      _updatePreference(allowSideQuests: value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Moderation notifications'),
                    value: _preferences?.allowModerationUpdates ?? false,
                    onChanged: (value) {
                      _updatePreference(allowModerationUpdates: value);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _savePreferences,
                    child: const Text('Save preferences'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _requestPermission,
                    child: const Text('Request notification permission'),
                  ),
                ],
              ),
            ),
    );
  }
}
