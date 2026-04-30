# Inclusive User Avatar Creation System

## Doctrine

The user avatar system should communicate:

> Everyone gets to be seen. Nobody has to perform normality.

Users can choose an avatar that looks enough like them, feels inspired by them, or protects their privacy with an abstract mark.

The Lego/block avatar direction is explicitly rejected. User avatars are not toys, minifigures, block characters, or childish adult defaults. The default direction is a soft illustrated portrait system: head-and-shoulders framing, natural proportions, warm rendering, and respectful identity controls.

## Supported avatar modes

1. **Looks like me** — closest soft portrait likeness with natural proportions.
2. **Inspired by me** — recognisable portrait cues, gently stylised without likeness pressure.
3. **Private / abstract** — non-identifying colour, pattern, initials, symbol, or soft silhouette.

No gender binary is forced. Pronouns, display name, avatar name, and presentation style are optional metadata.

## Creation flow

1. Choose avatar mode: looks like me, inspired by me, or private / abstract.
2. Choose base: age presentation, body shape, face shape, skin tone.
3. Choose hair / head covering: hair type, style, colour, headwear, hidden-hair option.
4. Choose face details: eyes, eyebrows, nose, mouth, facial hair, marks, glasses, makeup, wrinkles, smile lines, dimples.
5. Choose body / accessibility: body shape, mobility aids, hearing aids, prosthetics, medical devices, sensory headphones, accessibility badge.
6. Choose clothing: outfit, colours, cultural clothing, modest clothing.
7. Choose mood style: calm, bright, playful, minimal, bold.
8. Save with small and large previews.

## Layered render method

Phase 1 uses a layered PNG/SVG-ready system. `UserAvatarLayerResolver` resolves a `UserAvatarProfile` into ordered asset layers, and `UserAvatarRenderer` stacks them with a procedural fallback so the UI works before final art is produced.

The procedural fallback must also preserve the art direction: soft illustrated head-and-shoulders portrait, natural face/head proportions, broad skin tones, realistic hair texture hints, cultural headwear, glasses, hearing aids, mobility aids, prosthetics, medical devices, and other disability markers where selected.

Layer order:

```text
background
body
skin
head / face base
hair / head covering
clothing
cultural item
accessibility item
```

Privacy-first avatars render only:

```text
background
abstract avatar
```

## Asset structure

```text
assets/user_avatar/
  base/
    heads/
    bodies/
    skin_tones/
  hair/
    straight/
    wavy/
    curly/
    coily/
    afro_textured/
    locs/
    braids/
    twists/
    shaved/
    bald/
  face/
    eyes/
    eyebrows/
    noses/
    mouths/
    facial_hair/
    marks/
  clothing/
    casual/
    school/
    work/
    modest/
    sleepwear/
    sportswear/
  accessibility/
    glasses/
    hearing_aids/
    wheelchairs/
    prosthetics/
    medical_devices/
    sensory/
  cultural/
    hijab/
    turban/
    headwrap/
    kippah/
  abstract/
    orbs/
    symbols/
    patterns/
    initials/
  backgrounds/
```

## Accessibility and monetisation boundaries

Every identity/disability representation option must be optional, respectful, non-medicalised, non-stereotyped, and free forever.

Free forever:

- skin tones
- body sizes
- disability representation
- cultural clothing basics
- glasses
- hair types
- age presentation
- privacy mode

Paid cosmetics can include premium clothing styles, themed packs, animated backgrounds, seasonal effects, and premium accessories. Paid cosmetics must not include core identity, disability, cultural, or body representation.

## Flutter entry points

```dart
const profile = UserAvatarProfile(
  skinTone: 'deep_brown',
  hairType: 'coily',
  hairStyle: 'afro',
  hairColor: 'black',
  bodyShape: 'larger_body',
  accessibilityItems: ['sensory_headphones'],
  culturalItems: ['headwrap'],
);

UserAvatarRenderer(profile: profile);
```

For privacy-first users:

```dart
const profile = UserAvatarProfile.privateAbstract(
  moodStyle: 'calm',
);
```