# Avatar Engine V4 — Rive Layer Naming Contract

## Required top-level structure

```text
Avatar
├── base
├── skin
├── hair_back
├── neck
├── body
├── head
├── ears
├── face
├── hair_front
├── facial_hair
├── clothing
├── accessories
├── lighting
└── diagnostics
```

## Layer order

Required render order from back to front:

```text
background/shadow
hair_back
neck
body
clothing_back
head
ears
skin_details
eyes
nose
mouth
brows
hair_front
facial_hair
glasses
headwear
jewellery
medical
lighting
diagnostics
```

## Naming style

Use lowercase snake case.

Good:

```text
hair_back/ringlet_afro/long_copper_back
hair_front/ringlet_afro/temple_curls
facial_hair/short_beard/soft_round
accessories/glasses/round_clear
skin/freckles/light_nose_cheeks
```

Bad:

```text
Layer 1
HairThing
curl-front-new-final-v3
beardHair
```

## Hair pack groups

```text
hair_back/straight
hair_back/wavy
hair_back/curly
hair_back/coily
hair_back/afro
hair_back/ringlet_afro
hair_back/braids
hair_back/locs
hair_back/twists
hair_back/shaved
hair_back/covered
hair_back/frizzy

hair_front/straight
hair_front/wavy
hair_front/curly
hair_front/coily
hair_front/afro
hair_front/ringlet_afro
hair_front/braids
hair_front/locs
hair_front/twists
hair_front/shaved
hair_front/covered
hair_front/frizzy
```

## Detail groups

```text
skin/freckles
skin/vitiligo
skin/scars
skin/birthmarks
skin/mature_lines
```

Each detail group should support amount and placement later, even if Pass 1 only toggles the group.

## Diagnostic layers

Add non-rendering or hidden helper layers under:

```text
diagnostics
```

Recommended:

```text
diagnostics/head_bounds
diagnostics/face_safe_zone
diagnostics/hair_no_go_zone
diagnostics/mouth_chin_clear_zone
```

These are useful for QA but must not be visible in production exports.
