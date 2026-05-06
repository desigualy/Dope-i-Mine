# Avatar Engine V4 — Rive Technical Contract

## Asset path

```text
assets/avatar_rive/base_avatar.riv
```

## Rive file setup

```text
Artboard name: Avatar
State machine name: AvatarState
```

## Inputs

| Input | Type | Range/Purpose |
|---|---|---|
| skinTone | Number | 0.0–1.0 skin material/palette |
| faceShape | Number | 0.0–1.0 face/head preset |
| hairPack | Number | 0.0–1.0 hair family/pack |
| hairStyle | Number | 0.0–1.0 style inside hair family |
| hairColor | Number | 0.0–1.0 hair palette/material |
| bodyPreset | Number | 0.0–1.0 body presentation preset |
| freckles | Boolean | freckle detail layer |
| vitiligo | Boolean | vitiligo detail layer |
| hasFacialHair | Boolean | facial hair group |
| hasGlasses | Boolean | glasses group |

## Runtime

Flutter loads:

```dart
RiveAnimation.asset(
  'assets/avatar_rive/base_avatar.riv',
  artboard: 'Avatar',
  fit: BoxFit.contain,
)
```

The runtime binds to:

```text
AvatarState
```

Do not rename inputs. Names are case-sensitive.

## Layering requirements

```text
base/
  body
  neck
  head
skin/
  tone materials
  detail overlays
face/
  eyes
  brows
  nose
  mouth
  ears
hair_back/
  back/side hair volume behind head
hair_front/
  scalp hairline/fringe/temple details only
facial_hair/
  moustache
  goatee
  short_beard
  full_beard
clothing/
  tops
  bottoms
  shoes
accessories/
  glasses
  hearing
  headwear
  jewellery
  medical
```

## Hair placement rule

```text
hair_back = behind head / around shoulders / side mass
hair_front = hairline, crown, fringe, short visible details
```

Do not place full long hair in a single front layer.
