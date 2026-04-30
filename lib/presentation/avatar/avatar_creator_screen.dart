import 'package:flutter/material.dart';

import '../../domain/avatar/avatar_enums.dart';
import '../../domain/avatar/user_avatar_profile.dart';
import 'avatar_preview_card.dart';

class AvatarCreatorScreen extends StatefulWidget {
  const AvatarCreatorScreen({
    super.key,
    this.initialProfile = UserAvatarProfile.defaultAdult,
  });

  final UserAvatarProfile initialProfile;

  @override
  State<AvatarCreatorScreen> createState() => _AvatarCreatorScreenState();
}

class _AvatarCreatorScreenState extends State<AvatarCreatorScreen> {
  late UserAvatarProfile _profile;
  DopeiMood _previewMood = DopeiMood.neutral;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your avatar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          AvatarPreviewCard(profile: _profile, mood: _previewMood),
          _section('Preview mood'),
          _enumChips<DopeiMood>(
            values: DopeiMood.values,
            selected: _previewMood,
            onSelected: (value) => setState(() => _previewMood = value),
          ),
          _section('Avatar mode'),
          _enumChips<AvatarMode>(
            values: AvatarMode.values,
            selected: _profile.mode,
            onSelected: (value) => _set(_profile.copyWith(mode: value)),
          ),
          _section('Render mode'),
          _enumChips<AvatarRenderMode>(
            values: AvatarRenderMode.values,
            selected: _profile.renderMode,
            onSelected: (value) => _set(_profile.copyWith(renderMode: value)),
          ),
          _section('Realism level'),
          _enumChips<AvatarRealismLevel>(
            values: AvatarRealismLevel.values,
            selected: _profile.realismLevel,
            onSelected: (value) => _set(_profile.copyWith(realismLevel: value)),
          ),
          _section('Lighting style'),
          _enumChips<AvatarLightingStyle>(
            values: AvatarLightingStyle.values,
            selected: _profile.lightingStyle,
            onSelected: (value) =>
                _set(_profile.copyWith(lightingStyle: value)),
          ),
          _section('Camera style'),
          _enumChips<AvatarCameraStyle>(
            values: AvatarCameraStyle.values,
            selected: _profile.cameraStyle,
            onSelected: (value) => _set(_profile.copyWith(cameraStyle: value)),
          ),
          _section('Age presentation'),
          _enumChips<AvatarAgePresentation>(
            values: AvatarAgePresentation.values,
            selected: _profile.agePresentation,
            onSelected: (value) =>
                _set(_profile.copyWith(agePresentation: value)),
          ),
          _section('Skin tone'),
          _colourRow(
            colours: AvatarPalettes.skinTones,
            selected: _profile.skinTone,
            onSelected: (value) => _set(_profile.copyWith(skinTone: value)),
          ),
          _section('Skin detail'),
          _enumChips<AvatarSkinDetail>(
            values: AvatarSkinDetail.values,
            selected: _profile.skinDetail,
            onSelected: (value) => _set(_profile.copyWith(skinDetail: value)),
          ),
          _section('Body presentation'),
          _enumChips<AvatarBodyPresentation>(
            values: AvatarBodyPresentation.values,
            selected: _profile.bodyPresentation,
            onSelected: (value) =>
                _set(_profile.copyWith(bodyPresentation: value)),
          ),
          _section('Face shape'),
          _enumChips<AvatarFaceShape>(
            values: AvatarFaceShape.values,
            selected: _profile.faceShape,
            onSelected: (value) => _set(_profile.copyWith(faceShape: value)),
          ),
          _section('Hair type'),
          _enumChips<AvatarHairType>(
            values: AvatarHairType.values,
            selected: _profile.hairType,
            onSelected: (value) => _set(_profile.copyWith(hairType: value)),
          ),
          _section('Hair length'),
          _enumChips<AvatarHairLength>(
            values: AvatarHairLength.values,
            selected: _profile.hairLength,
            onSelected: (value) => _set(_profile.copyWith(hairLength: value)),
          ),
          _section('Hair colour'),
          _colourRow(
            colours: AvatarPalettes.hairColors,
            selected: _profile.hairColor,
            onSelected: (value) => _set(_profile.copyWith(hairColor: value)),
          ),
          _section('Expression'),
          _enumChips<AvatarExpression>(
            values: AvatarExpression.values,
            selected: _profile.expression,
            onSelected: (value) => _set(_profile.copyWith(expression: value)),
          ),
          _section('Cultural / head covering'),
          _enumChips<AvatarCulturalItem>(
            values: AvatarCulturalItem.values,
            selected: _profile.culturalItem,
            onSelected: (value) => _set(_profile.copyWith(culturalItem: value)),
          ),
          _section('Accessibility items'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AvatarAccessibilityItem.values.map((item) {
              final selected = _profile.accessibilityItems.contains(item);
              return FilterChip(
                selected: selected,
                label: Text(item.label),
                onSelected: (enabled) {
                  final next = List<AvatarAccessibilityItem>.from(
                    _profile.accessibilityItems,
                  );
                  enabled ? next.add(item) : next.remove(item);
                  _set(_profile.copyWith(accessibilityItems: next));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_profile),
            child: const Text('Save avatar'),
          ),
        ],
      ),
    );
  }

  void _set(UserAvatarProfile profile) => setState(() => _profile = profile);

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }

  Widget _enumChips<T extends Enum>({
    required List<T> values,
    required T selected,
    required ValueChanged<T> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        return ChoiceChip(
          selected: value == selected,
          label: Text(value.label),
          onSelected: (_) => onSelected(value),
        );
      }).toList(),
    );
  }

  Widget _colourRow({
    required List<Color> colours,
    required Color selected,
    required ValueChanged<Color> onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colours.map((colour) {
        final active = colour.value == selected.value;
        return InkWell(
          onTap: () => onSelected(colour),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colour,
              border: Border.all(
                color: active ? Colors.white : Colors.black26,
                width: active ? 4 : 1,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(blurRadius: 8, color: Colors.black26),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
