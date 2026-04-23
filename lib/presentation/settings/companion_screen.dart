import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../domain/companion/avatar_config_model.dart';
import '../../providers.dart';

class CompanionScreen extends ConsumerStatefulWidget {
  const CompanionScreen({super.key});

  @override
  ConsumerState<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends ConsumerState<CompanionScreen> {
  bool loading = true;
  List<Map<String, String>> companionOptions = const <Map<String, String>>[];
  String? selectedCompanionId;
  String avatarStyle = 'calm_orb';
  String avatarPalette = 'soft';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser == null) return;
      final repo = ref.read(companionRepositoryProvider);
      final companions = await repo.getCompanions();
      final avatar = await repo.getAvatarConfig(authUser.id);
      if (!mounted) return;
      setState(() {
        companionOptions = companions
            .map((dynamic c) => <String, String>{
                  'id': c.id as String,
                  'name': c.name as String,
                  'style': c.style as String,
                })
            .toList();
        avatarStyle = avatar?.avatarStyle ?? 'calm_orb';
        avatarPalette = avatar?.avatarPalette ?? 'soft';
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Companion and avatar',
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: selectedCompanionId,
                  items: companionOptions
                      .map((c) => DropdownMenuItem<String>(
                            value: c['id'],
                            child: Text('${c['name']} (${c['style']})'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCompanionId = value),
                  decoration: const InputDecoration(labelText: 'Companion'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: avatarStyle,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(value: 'calm_orb', child: Text('Calm orb')),
                    DropdownMenuItem(value: 'fox', child: Text('Fox')),
                    DropdownMenuItem(value: 'owl', child: Text('Owl')),
                    DropdownMenuItem(value: 'robot', child: Text('Robot')),
                  ],
                  onChanged: (value) => setState(() => avatarStyle = value ?? 'calm_orb'),
                  decoration: const InputDecoration(labelText: 'Avatar style'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: avatarPalette,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(value: 'soft', child: Text('Soft')),
                    DropdownMenuItem(value: 'bright', child: Text('Bright')),
                    DropdownMenuItem(value: 'neutral', child: Text('Neutral')),
                  ],
                  onChanged: (value) => setState(() => avatarPalette = value ?? 'soft'),
                  decoration: const InputDecoration(labelText: 'Avatar palette'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
                    if (authUser == null) return;
                    final repo = ref.read(companionRepositoryProvider);
                    if (selectedCompanionId != null) {
                      await repo.setActiveCompanion(
                        userId: authUser.id,
                        companionId: selectedCompanionId!,
                      );
                    }
                    await repo.saveAvatarConfig(
                      userId: authUser.id,
                      config: AvatarConfigModel(
                        avatarStyle: avatarStyle,
                        avatarPalette: avatarPalette,
                        accessoryConfig: const <String, dynamic>{},
                      ),
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
    );
  }
}
