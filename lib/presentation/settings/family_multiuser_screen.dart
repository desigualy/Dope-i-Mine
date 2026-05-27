import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';

class FamilyMultiuserScreen extends ConsumerStatefulWidget {
  const FamilyMultiuserScreen({super.key});

  @override
  ConsumerState<FamilyMultiuserScreen> createState() =>
      _FamilyMultiuserScreenState();
}

class _FamilyMultiuserScreenState extends ConsumerState<FamilyMultiuserScreen> {
  bool _profileSwitching = true;
  bool _guardianLock = false;
  bool _restrictSettings = false;
  bool _restrictDataExport = false;
  final TextEditingController _pinCtrl = TextEditingController();
  late Future<List<_UserProfile>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _profilesFuture = _loadProfiles();
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<List<_UserProfile>> _loadProfiles() async {
    final client = ref.read(supabaseProvider);
    final currentUser = client?.auth.currentUser;
    if (client == null || currentUser == null) return const <_UserProfile>[];

    final profiles = <_UserProfile>[];
    try {
      final currentProfile =
          await ref.read(profileRepositoryProvider).getProfile(currentUser.id);
      profiles.add(_UserProfile(
        id: currentUser.id,
        name: currentProfile?.displayName ?? currentUser.email ?? 'Me',
        avatar: Icons.person,
        isActive: true,
      ));
    } catch (_) {
      profiles.add(_UserProfile(
        id: currentUser.id,
        name: currentUser.email ?? 'Me',
        avatar: Icons.person,
        isActive: true,
      ));
    }

    try {
      final relationships =
          await ref.read(caregiverRepositoryProvider).loadRelationships();
      for (final relationship in relationships) {
        final isCurrentCaregiver =
            relationship.caregiverUserId == currentUser.id;
        final linkedUserId = isCurrentCaregiver
            ? relationship.supportedUserId
            : relationship.caregiverUserId;
        final linkedName = isCurrentCaregiver
            ? relationship.supportedName
            : relationship.caregiverName;
        profiles.add(_UserProfile(
          id: linkedUserId,
          name: linkedName ?? relationship.relationshipLabel ?? 'Linked user',
          avatar: isCurrentCaregiver
              ? Icons.family_restroom_rounded
              : Icons.health_and_safety_rounded,
          isActive: false,
        ));
      }
    } catch (_) {
      // Keep the current signed-in user visible even if caregiver tables are
      // unavailable in older/staged Supabase environments.
    }

    return profiles;
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Family & Multi-User',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Manage profiles on shared devices and set up parental controls.',
            ),
          ),

          // Profile Switching
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Profile Switching',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Quick Profile Switch'),
            subtitle: const Text(
              'Netflix-style fast profile switching for shared devices.',
            ),
            value: _profileSwitching,
            secondary: const Icon(Icons.switch_account_rounded),
            onChanged: (val) {
              setState(() => _profileSwitching = val);
            },
          ),
          if (_profileSwitching) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                'Managed Profiles',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            FutureBuilder<List<_UserProfile>>(
              future: _profilesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final profiles = snapshot.data ?? const <_UserProfile>[];
                if (profiles.isEmpty) {
                  return const ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('No signed-in profile found'),
                    subtitle: Text(
                        'Sign in to load your real shared-device profiles.'),
                  );
                }

                return Column(
                  children: [
                    ...profiles.map((profile) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(profile.avatar),
                        ),
                        title: Text(profile.name),
                        subtitle: profile.isActive
                            ? const Text('Current signed-in account')
                            : Text('Linked account • ${profile.id}'),
                        trailing: profile.isActive
                            ? Chip(
                                label: const Text('Active'),
                                backgroundColor:
                                    Colors.greenAccent.withValues(alpha: 0.3),
                              )
                            : OutlinedButton(
                                onPressed: null,
                                child: const Text('Switch'),
                              ),
                      );
                    }),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Use Caregiver & trusted links to add real linked profiles.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Add Profile'),
              ),
            ),
          ],

          const Divider(),

          // Guardian Lock / Parental Controls
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Guardian Lock / Parental Controls',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Guardian Lock'),
            subtitle: const Text(
              'PIN-protect specific settings to prevent children from changing them.',
            ),
            value: _guardianLock,
            secondary: const Icon(Icons.lock_person_rounded),
            onChanged: (val) {
              setState(() => _guardianLock = val);
            },
          ),
          if (_guardianLock) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _pinCtrl,
                decoration: const InputDecoration(
                  labelText: 'Set Guardian PIN',
                  hintText: '4-digit PIN',
                  prefixIcon: Icon(Icons.pin_rounded),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                'Protected Sections',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SwitchListTile(
              title: const Text('Lock Settings Changes'),
              subtitle: const Text('Require PIN to modify any settings.'),
              value: _restrictSettings,
              secondary: const Icon(Icons.settings_rounded),
              onChanged: (val) {
                setState(() => _restrictSettings = val);
              },
            ),
            SwitchListTile(
              title: const Text('Lock Data Export & Deletion'),
              subtitle: const Text(
                'Require PIN to export data or delete the account.',
              ),
              value: _restrictDataExport,
              secondary: const Icon(Icons.file_download_off_rounded),
              onChanged: (val) {
                setState(() => _restrictDataExport = val);
              },
            ),
          ],

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Family & multi-user settings saved.'),
                  ),
                );
              },
              child: const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _UserProfile {
  final String id;
  final String name;
  final IconData avatar;
  final bool isActive;
  const _UserProfile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.isActive,
  });
}
