import 'avatar_enums.dart';
import 'avatar_style_preset.dart';
import 'avatar_variation_strength.dart';
import 'realistic_avatar_prompt_builder.dart';
import 'user_avatar_profile.dart';

class StructuredRealisticAvatarPromptBuilder {
  const StructuredRealisticAvatarPromptBuilder._();

  static String buildStructured(
    UserAvatarProfile profile, {
    required AvatarStylePreset stylePreset,
    required AvatarVariationStrength variationStrength,
  }) {
    if (stylePreset == AvatarStylePreset.privateAbstract ||
        profile.mode == AvatarMode.privateAbstract ||
        profile.renderMode == AvatarRenderMode.abstract) {
      return _abstract(profile);
    }

    final basePrompt = RealisticAvatarPromptBuilder.build(profile);

    return '''
SUBJECT:
Head-and-shoulders avatar portrait for a supportive wellness and executive-function app.

IDENTITY:
${_identity(profile)}

STYLE:
${stylePreset.styleInstruction}.
Avoid toy-like, Lego-like, blocky, childish, caricature, or plastic character design.

LIGHTING:
${profile.lightingStyle.label} lighting. Gentle face illumination, soft rim light, clean background.

COMPOSITION:
${profile.cameraStyle.label} framing. Centered face, clean crop, profile-avatar safe, readable at small sizes.

QUALITY:
Natural proportions, clear eyes, believable facial structure, dignified expression, inclusive representation, detailed but not uncanny.

CONSISTENCY:
Use avatar seed consistency with ${variationStrength.label.toLowerCase()}.

BASE DESCRIPTION:
$basePrompt
''';
  }

  static String negativePrompt() {
    return <String>[
      'Lego style',
      'blocky toy avatar',
      'plastic toy figure',
      'doll-like',
      'caricature',
      'exaggerated features',
      'uncanny face',
      'distorted face',
      'extra limbs',
      'deformed hands',
      'asymmetrical eyes',
      'wrong age',
      'medical stereotype',
      'cultural stereotype',
      'offensive stereotype',
      'childish adult',
      'sexualised',
      'glamour photo',
      'passport photo',
      'low quality',
      'blurry',
      'messy background',
      'text',
      'watermark',
      'logo',
    ].join(', ');
  }

  static String _identity(UserAvatarProfile profile) {
    final items = <String>[
      '${profile.agePresentation.label} presentation',
      '${profile.bodyPresentation.label} body presentation',
      '${profile.faceShape.label} face shape',
      '${profile.hairLength.label} ${profile.hairType.label} hair',
      '${profile.expression.label} expression',
      '${profile.skinDetail.label} skin detail',
    ];

    if (profile.culturalItem != AvatarCulturalItem.none) {
      items.add('${profile.culturalItem.label} included respectfully');
    }

    if (profile.accessibilityItems.isNotEmpty) {
      items.add(
        'accessibility features: ${profile.accessibilityItems.map((item) => item.label).join(', ')}',
      );
    }

    return items.join(', ');
  }

  static String _abstract(UserAvatarProfile profile) {
    return '''
SUBJECT:
Private abstract non-human wellness avatar.

STYLE:
Soft glowing aura, symbolic identity, no human face, no body, no biometric likeness.

LIGHTING:
Calm modern app lighting, clean background, ${profile.accentColor.value.toRadixString(16)} inspired accent tone.

QUALITY:
Premium app avatar, inclusive, privacy-preserving, simple, readable at small sizes.
''';
  }
}
