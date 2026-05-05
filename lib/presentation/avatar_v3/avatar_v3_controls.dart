import 'package:flutter/material.dart';

import '../../domain/avatar_v3/avatar_v3_enums.dart';
import '../../domain/avatar_v3/avatar_v3_options.dart';
import '../../domain/avatar_v3/avatar_v3_profile.dart';

class AvatarV3Controls extends StatelessWidget {
  const AvatarV3Controls({
    super.key,
    required this.profile,
    required this.onChanged,
  });

  final AvatarV3Profile profile;
  final ValueChanged<AvatarV3Profile> onChanged;

  @override
  Widget build(BuildContext context) {
    final styles = AvatarV3Options.hairStylesFor(profile.hair.type);
    final selectedStyle = styles.contains(profile.hair.style)
        ? profile.hair.style
        : AvatarV3Options.defaultHairStyleFor(profile.hair.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _EnumDropdown<AvatarV3Camera>(
          label: 'Camera',
          values: AvatarV3Camera.values,
          selected: profile.camera,
          onChanged: (value) => onChanged(profile.copyWith(camera: value)),
        ),
        _EnumDropdown<AvatarV3AgePresentation>(
          label: 'Age presentation',
          values: AvatarV3AgePresentation.values,
          selected: profile.agePresentation,
          onChanged: (value) =>
              onChanged(profile.copyWith(agePresentation: value)),
        ),
        _EnumDropdown<AvatarV3SkinTone>(
          label: 'Skin tone',
          values: AvatarV3SkinTone.values,
          selected: profile.skin.tone,
          onChanged: (value) => onChanged(
            profile.copyWith(
              skin: AvatarV3SkinProfile(
                tone: value,
                undertone: profile.skin.undertone,
                freckles: profile.skin.freckles,
                vitiligo: profile.skin.vitiligo,
                scars: profile.skin.scars,
                birthmarks: profile.skin.birthmarks,
                matureLines: profile.skin.matureLines,
              ),
            ),
          ),
        ),
        _EnumDropdown<AvatarV3HairType>(
          label: 'Hair type',
          values: AvatarV3HairType.values,
          selected: profile.hair.type,
          onChanged: (value) {
            final style = AvatarV3Options.defaultHairStyleFor(value);
            onChanged(
              profile.copyWith(
                hair: AvatarV3HairProfile(
                  type: value,
                  style: style,
                  length: AvatarV3Options.defaultHairLengthFor(value, style),
                  volume: profile.hair.volume,
                  frontPolicy: AvatarV3Options.defaultFrontPolicyFor(value, style),
                  colour: profile.hair.colour,
                ),
              ),
            );
          },
        ),
        _EnumDropdown<AvatarV3HairStyle>(
          label: 'Hair style',
          values: styles,
          selected: selectedStyle,
          onChanged: (value) => onChanged(
            profile.copyWith(
              hair: AvatarV3HairProfile(
                type: profile.hair.type,
                style: value,
                length: AvatarV3Options.defaultHairLengthFor(profile.hair.type, value),
                volume: profile.hair.volume,
                frontPolicy:
                    AvatarV3Options.defaultFrontPolicyFor(profile.hair.type, value),
                colour: profile.hair.colour,
              ),
            ),
          ),
        ),
        _EnumDropdown<AvatarV3HairColour>(
          label: 'Hair colour',
          values: AvatarV3HairColour.values,
          selected: profile.hair.colour,
          onChanged: (value) => onChanged(
            profile.copyWith(
              hair: AvatarV3HairProfile(
                type: profile.hair.type,
                style: profile.hair.style,
                length: profile.hair.length,
                volume: profile.hair.volume,
                frontPolicy: profile.hair.frontPolicy,
                colour: value,
              ),
            ),
          ),
        ),
        _EnumDropdown<AvatarV3FacialHair>(
          label: 'Facial hair',
          values: AvatarV3FacialHair.values,
          selected: profile.facialHair.type,
          onChanged: (value) => onChanged(
            profile.copyWith(
              facialHair: AvatarV3FacialHairProfile(
                type: value,
                size: profile.facialHair.size,
                shape: profile.facialHair.shape,
                colour: profile.facialHair.colour,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EnumDropdown<T extends Enum> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<T> values;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: selected,
        decoration: InputDecoration(labelText: label),
        items: values
            .map(
              (value) => DropdownMenuItem<T>(
                value: value,
                child: Text(_label(value.name)),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }

  String _label(String raw) {
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i += 1) {
      final char = raw[i];
      final upper = char.toUpperCase() == char && char.toLowerCase() != char;
      if (i > 0 && upper) buffer.write(' ');
      buffer.write(i == 0 ? char.toUpperCase() : char);
    }
    return buffer.toString();
  }
}
