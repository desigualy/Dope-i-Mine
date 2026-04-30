import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/user_avatar/user_avatar_options.dart';
import '../../domain/user_avatar/user_avatar_profile.dart';
import 'user_avatar_renderer.dart';

final userAvatarProfileProvider =
    StateNotifierProvider<UserAvatarProfileController, UserAvatarProfile>(
        (ref) {
  return UserAvatarProfileController();
});

class UserAvatarProfileController extends StateNotifier<UserAvatarProfile> {
  UserAvatarProfileController() : super(const UserAvatarProfile());

  void createNew() {
    state = const UserAvatarProfile();
  }

  void setAvatarType(String value) {
    if (value == UserAvatarProfile.avatarTypePrivateAbstract) {
      state = UserAvatarProfile.privateAbstract(
        moodStyle: state.moodStyle,
        backgroundColor: state.backgroundColor,
        pronouns: state.pronouns,
        displayName: state.displayName,
        avatarName: state.avatarName,
      );
      return;
    }

    if (state.isPrivacyFirst) {
      state = UserAvatarProfile(
        avatarType: value,
        moodStyle: state.moodStyle,
        backgroundColor: state.backgroundColor,
        pronouns: state.pronouns,
        displayName: state.displayName,
        avatarName: state.avatarName,
        stylePreference: 'soft_illustrated',
      );
      return;
    }

    state = state.copyWith(
      avatarType: value,
      stylePreference: value == UserAvatarProfile.avatarTypePrivateAbstract
          ? 'abstract'
          : state.stylePreference,
    );
  }

  void setDisplayName(String value) {
    state = state.copyWith(displayName: value.trim());
  }

  void setPronouns(String value) {
    state = state.copyWith(pronouns: value.trim());
  }

  void setAvatarName(String value) {
    state = state.copyWith(avatarName: value.trim());
  }

  void setAgePresentation(String value) {
    state = state.copyWith(agePresentation: value);
  }

  void setSkinTone(String value) {
    state = state.copyWith(skinTone: value);
  }

  void setBodyShape(String value) {
    state = state.copyWith(bodyShape: value);
  }

  void setHairType(String value) {
    state = state.copyWith(hairType: value);
  }

  void setHairStyle(String value) {
    state = state.copyWith(hairStyle: value);
  }

  void setHairColor(String value) {
    state = state.copyWith(hairColor: value);
  }

  void setMoodStyle(String value) {
    state = state.copyWith(moodStyle: value);
  }

  void setBackgroundColor(String value) {
    state = state.copyWith(backgroundColor: value);
  }

  void setStylePreference(String value) {
    state = state.copyWith(stylePreference: value);
  }

  void toggleAccessibilityItem(String value) {
    state = state.copyWith(
      accessibilityItems: _toggled(state.accessibilityItems, value),
    );
  }

  void toggleClothingItem(String value) {
    final next = _toggled(state.clothingItems, value);
    state = state.copyWith(
      clothingItems: next.isEmpty ? const <String>['hoodie'] : next,
    );
  }

  void toggleCulturalItem(String value) {
    state = state.copyWith(
      culturalItems: _toggled(state.culturalItems, value),
    );
  }

  List<String> _toggled(List<String> values, String value) {
    if (values.contains(value)) {
      return values.where((item) => item != value).toList(growable: false);
    }
    return <String>[...values, value];
  }
}

class UserAvatarStudioCard extends ConsumerStatefulWidget {
  const UserAvatarStudioCard({super.key});

  @override
  ConsumerState<UserAvatarStudioCard> createState() =>
      _UserAvatarStudioCardState();
}

class _UserAvatarStudioCardState extends ConsumerState<UserAvatarStudioCard> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _pronounsController;
  late final TextEditingController _avatarNameController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userAvatarProfileProvider);
    _displayNameController = TextEditingController(text: profile.displayName);
    _pronounsController = TextEditingController(text: profile.pronouns);
    _avatarNameController = TextEditingController(text: profile.avatarName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _pronounsController.dispose();
    _avatarNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userAvatarProfileProvider);
    final controller = ref.read(userAvatarProfileProvider.notifier);
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey<String>('home-user-avatar-studio'),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.face_retouching_natural_rounded,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your avatar studio',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Create a soft illustrated head-and-shoulders portrait. Identity, disability, body, skin tone, and cultural options stay free.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: UserAvatarRenderer(
                profile: profile,
                size: 132,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                profile.avatarName?.isNotEmpty == true
                    ? profile.avatarName!
                    : 'My avatar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                FilledButton.icon(
                  key: const ValueKey<String>('create-user-avatar-button'),
                  onPressed: () {
                    controller.createNew();
                    _clearTextFields();
                    _showMessage(context, 'Started a fresh avatar.');
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create avatar'),
                ),
                OutlinedButton.icon(
                  key: const ValueKey<String>('edit-user-avatar-button'),
                  onPressed: () => _showMessage(
                    context,
                    'Avatar editing tools are right here on Home.',
                  ),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit avatar'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _AvatarTextFields(
              displayNameController: _displayNameController,
              pronounsController: _pronounsController,
              avatarNameController: _avatarNameController,
              controller: controller,
            ),
            const SizedBox(height: 16),
            _AvatarSection(
              title: 'Avatar mode',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'No toy, block, or childish proportions. Choose how closely the portrait represents you.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SingleSelectChips(
                    options: UserAvatarOptions.avatarTypes,
                    selectedId: profile.normalizedAvatarType,
                    onSelected: controller.setAvatarType,
                  ),
                ],
              ),
            ),
            if (profile.isPrivacyFirst) ...<Widget>[
              _AvatarSection(
                title: 'Private / abstract avatar',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Use a non-identifying colour, pattern, initials, or symbol while keeping the same soft app style.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SubLabel('Mood'),
                    _SingleSelectChips(
                      options: _moodOptions,
                      selectedId: profile.moodStyle,
                      onSelected: controller.setMoodStyle,
                    ),
                    const SizedBox(height: 10),
                    _SubLabel('Background'),
                    _SingleSelectChips(
                      options: _backgroundOptions,
                      selectedId: profile.backgroundColor,
                      onSelected: controller.setBackgroundColor,
                    ),
                  ],
                ),
              ),
            ] else ...<Widget>[
              _AvatarSection(
                title: 'Portrait identity and body',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _SubLabel('Age presentation'),
                    _SingleSelectChips(
                      options: UserAvatarOptions.agePresentations,
                      selectedId: profile.agePresentation,
                      onSelected: controller.setAgePresentation,
                    ),
                    const SizedBox(height: 10),
                    _SubLabel('Skin tone'),
                    _SingleSelectChips(
                      options: UserAvatarOptions.skinTones,
                      selectedId: profile.skinTone,
                      onSelected: controller.setSkinTone,
                    ),
                    const SizedBox(height: 10),
                    _SubLabel('Head-and-shoulders body shape'),
                    _SingleSelectChips(
                      options: UserAvatarOptions.bodyShapes,
                      selectedId: profile.bodyShape,
                      onSelected: controller.setBodyShape,
                    ),
                  ],
                ),
              ),
              _AvatarSection(
                title: 'Hair texture and portrait style',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _SubLabel('Hair type'),
                    _SingleSelectChips(
                      options: UserAvatarOptions.hairTypes,
                      selectedId: profile.hairType,
                      onSelected: controller.setHairType,
                    ),
                    const SizedBox(height: 10),
                    _SubLabel('Hair style'),
                    _SingleSelectChips(
                      options: _hairStyleOptions,
                      selectedId: profile.hairStyle,
                      onSelected: controller.setHairStyle,
                    ),
                    const SizedBox(height: 10),
                    _SubLabel('Hair colour'),
                    _SingleSelectChips(
                      options: UserAvatarOptions.hairColors,
                      selectedId: profile.hairColor,
                      onSelected: controller.setHairColor,
                    ),
                    const SizedBox(height: 10),
                    _SubLabel('Style expression'),
                    _SingleSelectChips(
                      options: UserAvatarOptions.stylePreferences,
                      selectedId: profile.stylePreference,
                      onSelected: controller.setStylePreference,
                    ),
                  ],
                ),
              ),
              _AvatarSection(
                title: 'Clothing, accessibility, disability, and culture',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _SubLabel('Clothing'),
                    _MultiSelectChips(
                      options: UserAvatarOptions.clothingItems,
                      selectedIds: profile.clothingItems,
                      onSelected: controller.toggleClothingItem,
                    ),
                    const SizedBox(height: 10),
                    _SubLabel('Accessibility and disability representation'),
                    _MultiSelectChips(
                      options: UserAvatarOptions.accessibilityItems,
                      selectedIds: profile.accessibilityItems,
                      onSelected: controller.toggleAccessibilityItem,
                    ),
                    const SizedBox(height: 10),
                    _SubLabel('Cultural items'),
                    _MultiSelectChips(
                      options: UserAvatarOptions.culturalItems,
                      selectedIds: profile.culturalItems,
                      onSelected: controller.toggleCulturalItem,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearTextFields() {
    _displayNameController.clear();
    _pronounsController.clear();
    _avatarNameController.clear();
  }
}

class _AvatarTextFields extends StatelessWidget {
  const _AvatarTextFields({
    required this.displayNameController,
    required this.pronounsController,
    required this.avatarNameController,
    required this.controller,
  });

  final TextEditingController displayNameController;
  final TextEditingController pronounsController;
  final TextEditingController avatarNameController;
  final UserAvatarProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          key: const ValueKey<String>('avatar-display-name-field'),
          controller: displayNameController,
          decoration: const InputDecoration(
            labelText: 'Display name',
            hintText: 'What should we call you?',
            border: OutlineInputBorder(),
          ),
          onChanged: controller.setDisplayName,
        ),
        const SizedBox(height: 10),
        TextFormField(
          key: const ValueKey<String>('avatar-pronouns-field'),
          controller: pronounsController,
          decoration: const InputDecoration(
            labelText: 'Pronouns',
            hintText: 'Optional, e.g. they/them',
            border: OutlineInputBorder(),
          ),
          onChanged: controller.setPronouns,
        ),
        const SizedBox(height: 10),
        TextFormField(
          key: const ValueKey<String>('avatar-name-field'),
          controller: avatarNameController,
          decoration: const InputDecoration(
            labelText: 'Avatar name',
            hintText: 'Optional nickname for your avatar',
            border: OutlineInputBorder(),
          ),
          onChanged: controller.setAvatarName,
        ),
      ],
    );
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SingleSelectChips extends StatelessWidget {
  const _SingleSelectChips({
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  final List<UserAvatarOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        return ChoiceChip(
          label: Text(option.label),
          selected: option.id == selectedId,
          onSelected: (_) => onSelected(option.id),
        );
      }).toList(growable: false),
    );
  }
}

class _MultiSelectChips extends StatelessWidget {
  const _MultiSelectChips({
    required this.options,
    required this.selectedIds,
    required this.onSelected,
  });

  final List<UserAvatarOption> options;
  final List<String> selectedIds;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        return FilterChip(
          label: Text(option.label),
          selected: selectedIds.contains(option.id),
          onSelected: (_) => onSelected(option.id),
        );
      }).toList(growable: false),
    );
  }
}

const List<UserAvatarOption> _moodOptions = <UserAvatarOption>[
  UserAvatarOption(id: 'calm', label: 'Calm'),
  UserAvatarOption(id: 'bright', label: 'Bright'),
  UserAvatarOption(id: 'playful', label: 'Playful'),
  UserAvatarOption(id: 'bold', label: 'Bold'),
  UserAvatarOption(id: 'minimal', label: 'Minimal'),
];

const List<UserAvatarOption> _backgroundOptions = <UserAvatarOption>[
  UserAvatarOption(id: 'soft_teal', label: 'Soft teal'),
  UserAvatarOption(id: 'bold', label: 'Bold'),
  UserAvatarOption(id: 'warm', label: 'Warm'),
  UserAvatarOption(id: 'minimal', label: 'Minimal'),
];

const List<UserAvatarOption> _hairStyleOptions = <UserAvatarOption>[
  UserAvatarOption(id: 'short', label: 'Short'),
  ...UserAvatarOptions.hairStyles,
];
