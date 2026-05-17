import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
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

  bool reducedAnimation = false;
  bool largeText = false;
  bool soundEnabled = true;
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
        loading = false;
      });
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

    await ref.read(profileRepositoryProvider).updateSensorySettings(
          id,
          reducedAnimation: reducedAnimation,
          largeText: largeText,
          soundEnabled: soundEnabled,
        );
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
                ListTile(
                  title: const Text('Restart onboarding'),
                  subtitle: const Text('Go through the setup again'),
                  leading: const Icon(Icons.refresh_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _restartOnboarding(context),
                ),
                if (accountType == 'caregiver')
                  ListTile(
                    title: const Text('Caregiver dashboard'),
                    subtitle: const Text(
                      'Return to caregiver support tools and linked people.',
                    ),
                    leading: const Icon(Icons.volunteer_activism_rounded),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go('/caregiver'),
                  ),
                const Divider(),
                const _SectionHeader(title: 'Sensory preferences'),
                SwitchListTile(
                  title: const Text('Reduced animations'),
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
                const _SectionHeader(title: 'Appearance'),
                SwitchListTile(
                  title: const Text('Dark mode'),
                  secondary: const Icon(Icons.dark_mode_rounded),
                  value: darkModeEnabled,
                  onChanged: (val) {
                    ref.read(themeControllerProvider.notifier).toggleTheme(val);
                  },
                ),
                const Divider(),
                const _SectionHeader(title: 'Account'),
                ListTile(
                  title: const Text('Assistant and avatar portraits'),
                  subtitle: const Text(
                    'Choose Looks like me, Inspired by me, or Private / abstract',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/companion'),
                ),
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
