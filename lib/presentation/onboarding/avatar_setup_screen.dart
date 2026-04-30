import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/avatar/user_avatar_profile.dart' as avatar;
import '../../domain/companion/avatar_config_model.dart';
import '../../providers.dart';
import '../avatar/avatar_creator_screen.dart';
import '../avatar/avatar_preview_card.dart';
import '../avatar/current_user_avatar_provider.dart';
import 'widgets/onboarding_step_scaffold.dart';

class AvatarSetupScreen extends ConsumerStatefulWidget {
  const AvatarSetupScreen({super.key, this.returnToSummary = false});

  final bool returnToSummary;

  @override
  ConsumerState<AvatarSetupScreen> createState() => _AvatarSetupScreenState();
}

class _AvatarSetupScreenState extends ConsumerState<AvatarSetupScreen> {
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
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: 'Companion & avatar',
      stepNumber: 11,
      totalSteps: 12,
      onBack: () => context.go(
        widget.returnToSummary
            ? '/onboarding/summary'
            : '/onboarding/voice-setup',
      ),
      onNext: () => _saveAndContinue(),
      nextLabel: widget.returnToSummary ? 'Save' : 'Save and continue',
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                AvatarPreviewCard(
                  key: const ValueKey<String>('onboarding-avatar-preview'),
                  profile: userAvatarProfile,
                  title: 'Your personal avatar',
                  subtitle:
                      'This portrait is what Home and Settings will show.',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const ValueKey<String>('customize-user-avatar-button'),
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
                const _AvatarDirectionNote(),
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

  Future<void> _saveAndContinue() async {
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
      config: AvatarConfigModel.fromUserAvatarProfile(userAvatarProfile),
    );
    ref.invalidate(currentUserAvatarConfigProvider);
    if (mounted) context.go('/onboarding/summary');
  }
}

class _AvatarDirectionNote extends StatelessWidget {
  const _AvatarDirectionNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          'User avatars are inclusive head-and-shoulders portraits with natural proportions, broad skin tones, realistic hair textures, cultural headwear, glasses, hearing aids, mobility aids, and disability markers where chosen.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
