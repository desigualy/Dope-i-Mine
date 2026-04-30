import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../domain/avatar/user_avatar_profile.dart' as avatar;
import '../../domain/companion/avatar_config_model.dart';
import '../../providers.dart';
import '../avatar/avatar_creator_screen.dart';
import '../avatar/avatar_preview_card.dart';
import '../avatar/current_user_avatar_provider.dart';

class CompanionScreen extends ConsumerStatefulWidget {
  const CompanionScreen({super.key});

  @override
  ConsumerState<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends ConsumerState<CompanionScreen> {
  bool loading = true;
  List<Map<String, String>> companionOptions = const <Map<String, String>>[];
  String? selectedCompanionId;
  String avatarStyle = AvatarConfigModel.defaultAvatarMode;
  String avatarPalette = AvatarConfigModel.defaultAvatarPalette;
  avatar.UserAvatarProfile userAvatarProfile =
      avatar.UserAvatarProfile.defaultAdult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
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
          avatarStyle =
              AvatarConfigModel.normalizeAvatarMode(avatar?.avatarStyle);
          avatarPalette =
              AvatarConfigModel.normalizeAvatarPalette(avatar?.avatarPalette);
          userAvatarProfile =
              (avatar ?? AvatarConfigModel.defaults).toUserAvatarProfile();
        });
      } catch (e) {
        debugPrint('Error initializing CompanionScreen: $e');
      } finally {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }
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
                AvatarPreviewCard(
                  key: const ValueKey<String>('settings-avatar-preview'),
                  profile: userAvatarProfile,
                  title: 'Your personal avatar',
                  subtitle: 'Saved changes appear on Home immediately.',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const ValueKey<String>(
                      'settings-customize-user-avatar-button'),
                  onPressed: _openAvatarCreator,
                  icon: const Icon(Icons.face_retouching_natural_rounded),
                  label: const Text('Customize portrait'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCompanionId,
                  items: companionOptions
                      .map((c) => DropdownMenuItem<String>(
                            value: c['id'],
                            child: Text('${c['name']} (${c['style']})'),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedCompanionId = value),
                  decoration: const InputDecoration(labelText: 'Companion'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: avatarStyle,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: AvatarConfigModel.modeLooksLikeMe,
                      child: Text('Looks like me'),
                    ),
                    DropdownMenuItem(
                      value: AvatarConfigModel.modeInspiredByMe,
                      child: Text('Inspired by me'),
                    ),
                    DropdownMenuItem(
                      value: AvatarConfigModel.modePrivateAbstract,
                      child: Text('Private / abstract'),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    avatarStyle = AvatarConfigModel.normalizeAvatarMode(value);
                    userAvatarProfile = _profileForCurrentSelections();
                  }),
                  decoration: const InputDecoration(
                    labelText: 'Avatar mode',
                    helperText:
                        'Soft portrait avatars only — no block, toy, or Lego styling.',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: avatarPalette,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: AvatarConfigModel.paletteSoftIllustrated,
                      child: Text('Soft illustrated portrait'),
                    ),
                    DropdownMenuItem(
                      value: AvatarConfigModel.paletteNatural,
                      child: Text('Natural portrait'),
                    ),
                    DropdownMenuItem(
                      value: AvatarConfigModel.paletteExpressiveNeon,
                      child: Text('Expressive neon portrait'),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    avatarPalette =
                        AvatarConfigModel.normalizeAvatarPalette(value);
                    userAvatarProfile = _profileForCurrentSelections();
                  }),
                  decoration:
                      const InputDecoration(labelText: 'Portrait palette'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final authUser =
                        ref.read(authRepositoryProvider).getCurrentUser();
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
                      config: AvatarConfigModel.fromUserAvatarProfile(
                          userAvatarProfile),
                    );
                    ref.invalidate(currentUserAvatarConfigProvider);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
    );
  }

  avatar.UserAvatarProfile _profileForCurrentSelections() {
    return AvatarConfigModel(
      avatarStyle: avatarStyle,
      avatarPalette: avatarPalette,
      accessoryConfig: <String, dynamic>{
        'profile': userAvatarProfile.toJson(),
      },
    ).toUserAvatarProfile();
  }

  Future<void> _openAvatarCreator() async {
    final edited = await Navigator.of(context).push<avatar.UserAvatarProfile>(
      MaterialPageRoute<avatar.UserAvatarProfile>(
        builder: (_) => AvatarCreatorScreen(initialProfile: userAvatarProfile),
      ),
    );
    if (edited == null || !mounted) return;

    final config = AvatarConfigModel.fromUserAvatarProfile(edited);
    setState(() {
      userAvatarProfile = edited;
      avatarStyle = config.normalizedAvatarStyle;
      avatarPalette = config.normalizedAvatarPalette;
    });
  }
}
