# Avatar Engine V4 Artist / Rigging Handoff Spec

This document defines the production asset pack required before Dope-i-Mine can render polished Avatar Engine V4 avatars.

The app code now has:

- an inclusive trait catalogue: `assets/avatar/catalogues/avatar_trait_catalogue.json`
- a trait-to-asset manifest template: `assets/avatar/catalogues/avatar_plugin_asset_manifest.json`
- a Rive contract validator
- a visible local starter preview when the production rig is missing

The app still needs real artist-exported `.riv` and `.glb` files.

## Non-negotiable product rules

- Identity features must remain free.
- Do not monetise skin tone, body type, hair texture, accessibility items, cultural/religious headwear, private abstract mode, or core identity expression.
- Heritage/race/culture labels are optional self-description only.
- Heritage identity labels must not automatically determine face, skin, hair, nose, eye, or body traits.
- Appearance traits must be user-controlled independently.
- Appearance traits must not imply identity.
- Albinism is a pigmentation trait, not a race label.
- Kiwi / New Zealander is nationality/cultural identity, not race.

## Required Rive deliverable

Export this file:

```text
assets/avatar_rive/base_avatar.riv
```

The file must contain:

| Contract item | Required value |
| --- | --- |
| Artboard | `Avatar` |
| State machine | `AvatarState` |

### Required Rive number inputs

The state machine must expose these number inputs:

| Input | Purpose |
| --- | --- |
| `skinTone` | normalized skin/pigmentation palette selector |
| `faceShape` | normalized face/head shape selector |
| `hairPack` | normalized hair family selector |
| `hairStyle` | normalized style within hair family |
| `hairColor` | normalized hair material/color selector |
| `bodyPreset` | normalized body presentation selector |

### Required Rive boolean inputs

The state machine must expose these boolean inputs:

| Input | Purpose |
| --- | --- |
| `freckles` | toggles freckle detail layer |
| `vitiligo` | toggles vitiligo detail layer |
| `hasFacialHair` | toggles facial hair group |
| `hasGlasses` | toggles eyewear group |

### Rive layer/group guidance

Recommended top-level groups:

- `base`
- `skin`
- `hair_back`
- `neck`
- `body`
- `head`
- `ears`
- `face`
- `hair_front`
- `facial_hair`
- `clothing`
- `accessories`
- `lighting`
- `diagnostics`

The rig must be safe at every normalized input value from `0.0` to `1.0`.

## Required GLB deliverables

GLB assets are required for full-body, clothing, accessories, accessibility items, and many headwear items.

Recommended base path structure:

```text
assets/avatar_glb/base/full_body_base.glb
assets/avatar_glb/hair/<trait_id>.glb
assets/avatar_glb/clothing/<trait_id>.glb
assets/avatar_glb/outerwear/<trait_id>.glb
assets/avatar_glb/headwear/<trait_id>.glb
assets/avatar_glb/accessories/<trait_id>.glb
assets/avatar_glb/accessibility/<trait_id>.glb
```

### Required GLB slots

The GLB pipeline/manifest expects these slots:

#### Material slots

- `skin_material`
- `hair_material`
- `eye_material`
- `clothing_slot`
- `outerwear_slot`
- `headwear_slot`
- `accessory_slot`
- `accessibility_slot`

#### Mesh slots

- `body_mesh`
- `hair_mesh`
- `facial_hair_mesh`
- `glasses_slot`
- `headwear_slot`
- `accessibility_slot`

## Trait-to-asset manifest

The production mapping lives here:

```text
assets/avatar/catalogues/avatar_plugin_asset_manifest.json
```

Each supported trait should have a binding like:

```json
{
  "traitId": "hijab",
  "category": "cultural_headwear",
  "glbAssetPath": "assets/avatar_glb/headwear/hijab.glb",
  "glbMeshSlot": "headwear_slot",
  "notes": "Selection is user-controlled and does not imply identity. Must remain free."
}
```

Rive-driven traits should include `riveInputKey` and `riveValue`:

```json
{
  "traitId": "tan_warm",
  "category": "skin_tone",
  "riveInputKey": "skinTone",
  "riveValue": 0.58,
  "glbMaterialSlot": "skin_material"
}
```

## Minimum first production pack

To move from placeholder preview to real production rendering, deliver at least:

1. `assets/avatar_rive/base_avatar.riv`
2. Rive inputs listed above
3. manifest bindings for the default `AvatarV4Config` values:
   - `tan_warm`
   - `soft_oval`
   - `soft_natural` brow/nose where supported
   - `gentle_smile`
   - `soft_almond`
   - `hair_ringlet_afro_v1` / relevant hair pack value
   - `long_copper_ringlet_afro` or nearest production hair style
   - `copper_brown` or nearest production hair colour
   - `average_soft`
   - `starter_black_top`
   - `starter_jeans`
   - `none` outerwear/facial hair/headwear

If a default trait is renamed, update `AvatarV4Config` and the manifest together.

## Supabase seeding notes

If remote asset resolution is used, seed asset records using the same `traitId` keys as the manifest.

Each remote asset record should include:

- `trait_id`
- `category`
- `render_backend` (`rive_face`, `rive_bust`, `glb_full_body`, `hybrid`)
- storage bucket/path or signed/public URL
- version
- checksum
- free/protected flags
- minor-safe flag if applicable

Do not seed external image-generation routes as the production avatar path.

## Acceptance checklist

The production asset handoff is accepted only when:

- `flutter analyze` passes.
- avatar Rive contract validation passes.
- `AvatarRiveView` renders `base_avatar.riv` instead of the starter preview.
- Default avatar appears in the customizer without missing-rig diagnostics.
- Changing skin/hair/face/body controls visibly changes the Rive rig or GLB layer.
- Accessibility items render from GLB or approved Rive groups and remain free.
- Cultural/religious headwear renders only when selected by the user.
- Heritage identity labels never force any appearance trait.
- Private abstract mode remains available and free.

## Current blocker

At the time this spec was created, the repository did **not** contain:

```text
assets/avatar_rive/base_avatar.riv
assets/avatar_glb/base/full_body_base.glb
```

Until those files or equivalent remote plugin assets exist, the app can only show the starter preview / missing-production-rig state.