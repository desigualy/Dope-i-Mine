# Avatar V2 Apple/Meta Style Renderer Patch

This patch converts the renderer toward the visual style agreed in chat:

- Meta-like full body/bust proportions
- Apple-like rounded face language
- premium 3D-like soft shading
- clean studio background
- long curly auburn afro/ringlet hair support
- hair mass anchored around crown/scalp, not drawn as a beard
- freckles and soft youthful face rendering
- dark top + casual denim full-body preview when cameraStyle is `upperBody`

## Files

- `lib/presentation/avatar_v2/avatar_v2_renderer.dart`
- `test/avatar_v2/avatar_v2_apple_meta_style_test.dart`

## Apply

Extract over project root, then run:

```powershell
flutter analyze
flutter test
flutter run
```

## How to preview the target style in-app

Set the profile roughly to:

```dart
const AvatarV2Profile(
  cameraStyle: AvatarV2CameraStyle.upperBody,
  agePresentation: AvatarV2AgePresentation.preTeen,
  skin: AvatarV2Skin(
    tone: AvatarV2SkinTone.tan,
    freckles: AvatarV2Freckles(
      density: AvatarV2FreckleDensity.medium,
      distribution: AvatarV2FreckleDistribution.noseAndCheeks,
    ),
  ),
  hair: AvatarV2Hair(
    texture: AvatarV2HairTexture.afro,
    style: AvatarV2HairStyle.longCurls,
    length: AvatarV2HairLength.long,
    density: AvatarV2HairDensity.dense,
    volume: AvatarV2HairVolume.halo,
    colour: AvatarV2HairColour.copper,
    frontStrandPolicy: AvatarV2FrontStrandPolicy.noFaceOverlap,
  ),
  clothing: AvatarV2Clothing(
    top: AvatarV2TopClothing.tShirt,
    colour: AvatarV2ClothingColour.black,
  ),
)
```

## Important

This is still a Flutter vector renderer, not a true 3D mesh engine. It should, however, move the app away from the flat toy look and toward the agreed Apple/Meta-like visual direction.
