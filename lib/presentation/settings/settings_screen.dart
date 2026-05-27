import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sync/sync_queue_service.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../core/sync/sync_queue_item.dart';
import '../../domain/profile/sensory_settings_model.dart';
import '../../providers.dart';
import '../auth/auth_controller.dart';
import '../onboarding/onboarding_controller.dart';
import 'offline_sync_panel.dart';
import 'theme_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool loading = true;
  String? userId;
  int _versionTapCount = 0;
  bool _devToolsUnlocked = false;

  bool reducedAnimation = false;
  bool largeText = false;
  bool soundEnabled = true;
  SensorySettingsModel? _lastSensorySettings;
  String accountType = 'user';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();

    if (authUser == null) {
      if (!mounted) return;
      setState(() => loading = false);
      return;
    }

    userId = authUser.id;

    final cachedSensory =
        await ref.read(localSettingsCacheProvider.future).then(
              (cache) => cache.loadSensorySettings(authUser.id),
            );

    if (mounted && cachedSensory != null) {
      setState(() {
        reducedAnimation = cachedSensory.reducedAnimation;
        largeText = cachedSensory.largeText;
        soundEnabled = cachedSensory.soundEnabled;
        _lastSensorySettings = cachedSensory;
        loading = false;
      });
    }

    try {
      final resolvedAccountType =
          await ref.read(profileRepositoryProvider).getAccountType(userId!);
      final sensory =
          await ref.read(profileRepositoryProvider).getSensorySettings(userId!);

      if (!mounted) return;
      setState(() {
        accountType = resolvedAccountType;
        reducedAnimation = sensory?.reducedAnimation ?? false;
        largeText = sensory?.largeText ?? false;
        soundEnabled = sensory?.soundEnabled ?? true;
        _lastSensorySettings = sensory;
        loading = false;
      });
      if (sensory != null) {
        await ref
            .read(localSettingsCacheProvider.future)
            .then((cache) => cache.saveSensorySettings(userId!, sensory));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> _updateSensory({
    bool? reducedAnimation,
    bool? largeText,
    bool? soundEnabled,
  }) async {
    final id = userId;
    if (id == null) return;

    final currentSettings = _lastSensorySettings;
    final nextSettings = SensorySettingsModel(
      reducedAnimation: reducedAnimation ?? this.reducedAnimation,
      largeText: largeText ?? this.largeText,
      softColors: currentSettings?.softColors ?? true,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      praiseLevel: currentSettings?.praiseLevel ?? 'medium',
      iconMode: currentSettings?.iconMode ?? false,
      reduceSurprises: currentSettings?.reduceSurprises ?? true,
    );
    _lastSensorySettings = nextSettings;

    await ref
        .read(localSettingsCacheProvider.future)
        .then((cache) => cache.saveSensorySettings(id, nextSettings));

    try {
      await ref.read(profileRepositoryProvider).updateSensorySettings(
            id,
            reducedAnimation: reducedAnimation,
            largeText: largeText,
            soundEnabled: soundEnabled,
          );
    } catch (error) {
      debugPrint('Saved sensory setting locally; remote sync failed: $error');
      await ref.read(syncQueueServiceProvider).enqueue(SyncQueueItem.create(
            type: 'update_sensory_settings',
            idempotencyKey: 'update_sensory_settings_$id',
            payload: <String, dynamic>{
              'userId': id,
              if (reducedAnimation != null)
                'reducedAnimation': reducedAnimation,
              if (largeText != null) 'largeText': largeText,
              if (soundEnabled != null) 'soundEnabled': soundEnabled,
            },
          ));
    }
  }

  Future<void> _restartOnboarding(BuildContext context) async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    final id = authUser?.id ?? userId;

    if (id != null) {
      try {
        await ref.read(profileRepositoryProvider).setOnboardingCompleted(
              userId: id,
              completed: false,
            );
      } catch (e) {
        debugPrint('Failed to reset onboarding on backend: $e');
      }
    }

    // Reset the wizard controller so they start completely fresh
    ref.invalidate(onboardingControllerProvider);

    if (context.mounted) {
      context.go('/branding/intro');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeControllerProvider);
    final darkModeEnabled = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return PrimaryScaffold(
      title: 'Settings',
      child: loading
          ? const Center(child: CircularProgressIndicator())
            : ListView(
              children: <Widget>[
                const _SectionHeader(title: 'Account & Setup'),
                ListTile(
                  title: const Text('Assistant and avatar portraits'),
                  subtitle: const Text(
                    'Choose Looks like me, Inspired by me, or Private / abstract',
                  ),
                  leading: const Icon(Icons.portrait_rounded),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/companion'),
                ),
                ListTile(
                  title: const Text('Edit setup choices'),
                  subtitle: const Text(
                    'Review role, voice, notifications, accessibility, side quests, and body-double preferences.',
                  ),
                  leading: const Icon(Icons.tune_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.go('/settings/setup'),
                ),
                ListTile(
                  title: const Text('Restart onboarding'),
                  subtitle: const Text('Go through the setup again'),
                  leading: const Icon(Icons.refresh_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _restartOnboarding(context),
                ),

                if (accountType == 'caregiver') ...[
                  const Divider(),
                  const _SectionHeader(title: 'Caregiver Tools'),
                  ListTile(
                    title: const Text('Caregiver dashboard'),
                    subtitle: const Text(
                      'Return to caregiver support tools and linked people.',
                    ),
                    leading: const Icon(Icons.volunteer_activism_rounded),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go('/caregiver'),
                  ),
                ],

                const Divider(),
                const _SectionHeader(title: 'Personalization'),
                ListTile(
                  title: const Text('Theming & Appearance'),
                  subtitle: const Text('Custom colors, icons, fonts, and scaling'),
                  leading: const Icon(Icons.color_lens_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/appearance'),
                ),
                ListTile(
                  title: const Text('Avatar customizer'),
                  subtitle: const Text('Customize your avatar\'s appearance'),
                  leading: const Icon(Icons.face_retouching_natural_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/avatar/customize'),
                ),
                ListTile(
                  title: const Text('Avatar & Companion Tweaks'),
                  subtitle: const Text('Render quality, idle animations, and display size'),
                  leading: const Icon(Icons.auto_awesome_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/avatar-tweaks'),
                ),
                SwitchListTile(
                  title: const Text('Dark mode'),
                  secondary: const Icon(Icons.dark_mode_rounded),
                  value: darkModeEnabled,
                  onChanged: (val) {
                    ref.read(themeControllerProvider.notifier).toggleTheme(val);
                  },
                ),

                const Divider(),
                const _SectionHeader(title: 'AI & Personality Core'),
                ListTile(
                  title: const Text('AI Personality'),
                  subtitle: const Text('Tweak the AI model, tone, and verbosity'),
                  leading: const Icon(Icons.psychology_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/ai-personality'),
                ),

                const Divider(),
                const _SectionHeader(title: 'Gamification & Rewards'),
                ListTile(
                  title: const Text('Gamification Settings'),
                  subtitle: const Text('Tweak XP, confetti, and leaderboards'),
                  leading: const Icon(Icons.star_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/gamification'),
                ),

                const Divider(),
                const _SectionHeader(title: 'Integrations & External Sync'),
                ListTile(
                  title: const Text('Integrations'),
                  subtitle: const Text('Calendar sync, health apps, and wearables'),
                  leading: const Icon(Icons.sync_alt_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/integrations'),
                ),

                const Divider(),
                const _SectionHeader(title: 'Widgets, Automation & Shortcuts'),
                ListTile(
                  title: const Text('Automation & Shortcuts'),
                  subtitle: const Text('Voice assistants, widgets, and webhooks'),
                  leading: const Icon(Icons.auto_fix_high_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/automation-shortcuts'),
                ),

                const Divider(),
                const _SectionHeader(title: 'Family & Multi-User'),
                ListTile(
                  title: const Text('Family & Multi-User'),
                  subtitle: const Text('Profile switching and parental controls'),
                  leading: const Icon(Icons.family_restroom_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/family-multiuser'),
                ),

                const Divider(),
                const _SectionHeader(title: 'Voice & Audio'),
                ListTile(
                  title: const Text('Voice profile'),
                  subtitle: const Text('Change the assistant\'s voice'),
                  leading: const Icon(Icons.record_voice_over_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/voice'),
                ),
                ListTile(
                  title: const Text('Pronunciation'),
                  subtitle: const Text('Teach the assistant how to pronounce names'),
                  leading: const Icon(Icons.spatial_audio_off_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/pronunciation'),
                ),

                const Divider(),
                const _SectionHeader(title: 'Notifications & Reminders'),
                ListTile(
                  title: const Text('Notification preferences'),
                  subtitle: const Text('Manage when and how you are notified'),
                  leading: const Icon(Icons.notifications_active_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/notifications'),
                ),
                ListTile(
                  title: const Text('Reminder settings'),
                  subtitle: const Text('Configure default reminder options'),
                  leading: const Icon(Icons.alarm_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/reminders'),
                ),

                const Divider(),
                const _SectionHeader(title: 'Sensory preferences'),
                SwitchListTile(
                  title: const Text('Reduced animations'),
                  secondary: const Icon(Icons.animation_rounded),
                  value: reducedAnimation,
                  onChanged: userId == null
                      ? null
                      : (val) async {
                          setState(() => reducedAnimation = val);
                          await _updateSensory(reducedAnimation: val);
                        },
                ),
                SwitchListTile(
                  title: const Text('Large text'),
                  secondary: const Icon(Icons.format_size_rounded),
                  value: largeText,
                  onChanged: userId == null
                      ? null
                      : (val) async {
                          setState(() => largeText = val);
                          await _updateSensory(largeText: val);
                        },
                ),
                SwitchListTile(
                  title: const Text('Sound enabled'),
                  secondary: const Icon(Icons.volume_up_rounded),
                  value: soundEnabled,
                  onChanged: userId == null
                      ? null
                      : (val) async {
                          setState(() => soundEnabled = val);
                          await _updateSensory(soundEnabled: val);
                        },
                ),
                const Divider(),
                const _SectionHeader(title: 'Body doubling'),
                ListTile(
                  title: const Text('Random body double safety'),
                  subtitle: const Text(
                    'Manage opt-in, preset/silent modes, and guardian approval.',
                  ),
                  leading: const Icon(Icons.shield_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/body-double/random-settings'),
                ),
                ListTile(
                  title: const Text('Body double moderation'),
                  subtitle: const Text(
                    'Moderator report review, audit events, restrictions, and lifecycle cleanup.',
                  ),
                  leading: const Icon(Icons.admin_panel_settings_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/body-double/moderation'),
                ),
                const Divider(),
                const _SectionHeader(title: 'Offline mode'),
                const OfflineSyncPanel(),

                const Divider(),
                const _SectionHeader(title: 'Feedback'),
                ListTile(
                  title: const Text('Send Beta Feedback'),
                  subtitle: const Text('Report bugs or suggest features'),
                  leading: const Icon(Icons.bug_report_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/feedback/beta'),
                ),

                const Divider(),
                const _SectionHeader(title: 'Data & Privacy'),
                ListTile(
                  title: const Text('Storage & Performance'),
                  subtitle: const Text('Manage device storage and battery saver'),
                  leading: const Icon(Icons.storage_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/storage-performance'),
                ),
                ListTile(
                  title: const Text('Manage Data & Privacy'),
                  subtitle: const Text('Clear cache, export data, or delete account'),
                  leading: const Icon(Icons.privacy_tip_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/data-privacy'),
                ),
                ListTile(
                  title: const Text('Advanced Security'),
                  subtitle: const Text('App Lock and Active Sessions'),
                  leading: const Icon(Icons.security_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/advanced-security'),
                ),

                const Divider(),
                const _SectionHeader(title: 'About'),
                ListTile(
                  title: const Text('App Version'),
                  subtitle: const Text('v1.0.0 (Build 42)'),
                  leading: const Icon(Icons.info_outline_rounded),
                  onTap: () {
                    _versionTapCount++;
                    if (_versionTapCount == 7) {
                      setState(() {
                        _devToolsUnlocked = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Developer Mode Unlocked!')),
                      );
                    } else if (_versionTapCount > 3 && _versionTapCount < 7) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You are ${7 - _versionTapCount} steps away from being a developer.')),
                      );
                    }
                  },
                ),

                if (_devToolsUnlocked) ...[
                  const Divider(),
                  const _SectionHeader(title: 'Developer Options'),
                  ListTile(
                    title: const Text('Developer Tools'),
                    subtitle: const Text('Advanced diagnostic features'),
                    leading: const Icon(Icons.developer_mode_rounded),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/settings/developer-tools'),
                  ),
                ],

                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(authControllerProvider).signOut();
                      if (context.mounted) context.go('/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign out'),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.cyan,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
