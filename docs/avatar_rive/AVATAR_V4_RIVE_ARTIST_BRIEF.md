# Dope-i-Mine Avatar Engine V4 — Rive Artist Brief

## Goal

Create a high-quality Apple/Meta-style avatar rig for:

```text
assets/avatar_rive/base_avatar.riv
```

This must not look like a flat blob, sticker, emoji, or basic SVG stack. The target is a polished 3D-inspired, soft-lit, expressive avatar system with believable identity variation.

## Required Rive contract

```text
File: assets/avatar_rive/base_avatar.riv
Artboard: Avatar
State machine: AvatarState
```

## Required state machine inputs

Number inputs, all `0.0` to `1.0`:

```text
skinTone
faceShape
hairPack
hairStyle
hairColor
bodyPreset
```

Boolean inputs:

```text
freckles
vitiligo
hasFacialHair
hasGlasses
```

## Visual requirements

```text
1. Realistic head proportions
2. Soft Apple/Meta-style rounded forms
3. Proper hair placement on the scalp/head, not over the mouth/chin
4. Hair behind and around the head where anatomically correct
5. Distinct hair families: straight, wavy, curly, coily, afro, ringlet afro, braids, locs, twists, shaved, covered, frizzy
6. Facial hair sits on the lower face only
7. Skin details are subtle but visible
8. Freckles, vitiligo, scars, birthmarks, and mature lines must be believable
9. Body presentation should support real variation, not one generic body
10. Accessories must be useful and respectful: glasses, hearing aids, headwear, jewellery, medical items
```

## Style target

```text
Polished 3D-style avatar
Soft global lighting
Rounded Pixar-adjacent but less cartoonish
Apple Memoji / Meta Avatar quality target
Clean facial proportions
Subtle material shading
No harsh black outlines
No flat paper-cutout layers
No beard-shaped hair mass
No curtain hair covering the centre face
```

## Non-negotiable rejection rules

Reject the rig if:

```text
hair appears like a beard
hair covers mouth/chin unless intentionally selected as facial hair
facial hair sits too high on cheeks
hair is only a flat shape in front of the face
ringlets look like cultural caricature
locs look like a curtain wall
afro/coily hair has no believable volume or scalp relationship
birthmarks/scars/vitiligo look like random stickers
body sliders visibly do nothing
accessibility items look like jokes or props
```
