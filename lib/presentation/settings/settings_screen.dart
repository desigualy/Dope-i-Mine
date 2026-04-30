import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';
import '../auth/auth_controller.dart';
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
  String assistantName = 'Dope-i';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null) return;
    userId = authUser.id;

    final profileRepo = ref.read(profileRepositoryProvider);
    final sensory = await profileRepo.getSensorySettings(userId!);
    // We don't have a direct get for assistant name yet, but it's in a table.
    // For now, let's just focus on sensory.

    if (!mounted) return;
    setState(() {
      reducedAnimation = sensory?.reducedAnimation ?? false;
      largeText = sensory?.largeText ?? false;
      soundEnabled = sensory?.soundEnabled ?? true;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Settings',
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                const _SectionHeader(title: 'Sensory preferences'),
                SwitchListTile(
                  title: const Text('Reduced animations'),
                  value: reducedAnimation,
                  onChanged: (val) async {
                    setState(() => reducedAnimation = val);
                    await ref
                        .read(profileRepositoryProvider)
                        .updateSensorySettings(
                          userId!,
                          reducedAnimation: val,
                        );
                  },
                ),
                SwitchListTile(
                  title: const Text('Large text'),
                  value: largeText,
                  onChanged: (val) async {
                    setState(() => largeText = val);
                    await ref
                        .read(profileRepositoryProvider)
                        .updateSensorySettings(
                          userId!,
                          largeText: val,
                        );
                  },
                ),
                SwitchListTile(
                  title: const Text('Sound enabled'),
                  value: soundEnabled,
                  onChanged: (val) async {
                    setState(() => soundEnabled = val);
                    await ref
                        .read(profileRepositoryProvider)
                        .updateSensorySettings(
                          userId!,
                          soundEnabled: val,
                        );
                  },
                ),
                const Divider(),
                const _SectionHeader(title: 'Appearance'),
                SwitchListTile(
                  title: const Text('Dark mode'),
                  secondary: const Icon(Icons.dark_mode_rounded),
                  value: ref.watch(themeControllerProvider) == ThemeMode.dark ||
                      (ref.watch(themeControllerProvider) == ThemeMode.system &&
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark),
                  onChanged: (val) {
                    ref.read(themeControllerProvider.notifier).toggleTheme(val);
                  },
                ),
                const Divider(),
                const _SectionHeader(title: 'Account'),
                ListTile(
                  title: const Text('Assistant and avatar portraits'),
                  subtitle: const Text(
                      'Choose Looks like me, Inspired by me, or Private / abstract'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/companion'),
                ),
                ListTile(
                  title: const Text('Restart onboarding'),
                  subtitle: const Text('Go through the setup again'),
                  trailing: const Icon(Icons.refresh),
                  onTap: () async {
                    if (userId != null) {
                      await ref
                          .read(profileRepositoryProvider)
                          .setOnboardingCompleted(
                            userId: userId!,
                            completed: false,
                          );
                      if (context.mounted) context.go('/branding/intro');
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
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
