# Avatar Engine V4 — Rive Handoff Specification

## Target

Create the production Rive file:

```text
assets/avatar_rive/base_avatar.riv
```

This file is the first real avatar rig for Dope-i-Mine. It must replace the retired blob/SVG/CustomPaint avatar approach.

## Non-negotiable visual direction

The avatar must be closer to Apple/Meta avatar quality than the old renderer:

```text
soft 3D-like illustrated style
rounded but human-recognisable proportions
clean face silhouette
natural hair placement
no hair over mouth/chin unless deliberately selected
no beard-like hair mass
clear separation between scalp hair and facial hair
expressive but not cartoon-clown
accessible and inclusive without parody
```

## Rive file contract

```text
Artboard: Avatar
State machine: AvatarState
File path: assets/avatar_rive/base_avatar.riv
```

## Required number inputs

```text
skinTone
faceShape
hairPack
hairStyle
hairColor
bodyPreset
```

All number inputs must accept a `0.0 → 1.0` value.

## Required boolean inputs

```text
freckles
vitiligo
hasFacialHair
hasGlasses
```

## Required groups/layers

The Rive file should be organised into these top-level groups:

```text
base/
skin/
face/
hair_back/
head/
hair_front/
facial_hair/
body/
clothing/
accessories/
lighting/
diagnostics/
```

The important order is:

```text
hair_back behind head
head/face above hair_back
hair_front above head but not covering lower face by default
facial_hair separate from hair
accessories above face/hair only where appropriate
```

## Initial production variants

### Base

```text
head shapes: soft oval, round, square-soft, heart, long oval
neck sizes: slim, average, broad
body presets: slim, average, soft, broad, curvy, stocky
```

### Skin

```text
skin tones: very light, light, medium, olive, tan, brown, deep brown, very deep
details: freckles, vitiligo, scars, birthmarks, mature lines
```

### Hair packs

```text
straight
wavy
curly
coily
afro
ringlet_afro
braids
locs
twists
shaved
covered
frizzy
```

### Facial hair

```text
stubble
moustache
goatee
short_beard
full_beard
sideburns
```

### Accessories

```text
glasses
hearing aids
headwear
jewellery
medical items
```

## Hair placement rule

Hair must sit on or behind the head.

Forbidden default outcomes:

```text
hair mass below mouth
hair forming beard shape
locs/braids as a face curtain
ringlet afro as side beard
hair covering the whole front of face
```

Allowed:

```text
hair behind shoulders
hair behind neck
temple curls
forehead fringe above eyebrows
intentional face-framing strands that stop before cheeks/mouth
```

## Facial hair placement rule

Facial hair must sit on the lower face only.

Forbidden:

```text
beard starts under eyes
moustache sits on nose
full beard covers cheeks up to temples
facial hair merges with scalp hair
```

## Accessibility rule

Accessibility items must look respectful and recognisable:

```text
hearing aids aligned with ears
glasses aligned with eyes and bridge
medical accessories clearly separate from jewellery
headwear does not erase hair unless style requires it
```

## Output acceptance

The `.riv` is acceptable only when:

```text
Flutter loads assets/avatar_rive/base_avatar.riv
AvatarRiveView no longer shows missing-rig diagnostic
AvatarState state machine exists
all required inputs exist
hair_back is visibly behind the head
hair_front does not form a beard
face remains readable
avatar works at 96px, 180px, 220px, and 512px
```
