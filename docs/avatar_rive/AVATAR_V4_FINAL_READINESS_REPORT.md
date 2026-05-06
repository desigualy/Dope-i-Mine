# Avatar Engine V4 — Final Readiness Report

## Status

Avatar Engine V4 is now structurally ready for the real Rive avatar rig.

```text
Flutter analyze: expected clean
Flutter test: expected passing
Public avatar renderer: Avatar Engine V4 / Rive
Retired public renderers: V2 CustomPainter, V3 SVG/blob/layer renderer, UnifiedUserAvatar fallback, FloatingDopeiAvatar fallback
```

## Completed passes

```text
3A Rive foundation: done
3B Home/customizer wiring: done
3C Rive asset contract: done
3D Supabase/local cache sync: done
3E reference image upload flow: done
3F real service wiring: done
3G V3 public-surface retirement: done
3H Rive asset handoff pack: done
3I Rive contract validator: done
3J Rive initialization guard: done
3K silent validator tests: done
3L readiness report + runbook: done
```

## What is complete

```text
1. Avatar V4 has its own engine folder.
2. Home is wired to the V4/Rive public renderer.
3. The old V3/blob renderer is blocked from public avatar surfaces.
4. Rive contract is locked.
5. Missing .riv diagnostic exists.
6. Invalid/unreadable .riv diagnostic exists.
7. Supabase avatar tables exist through manually-applied SQL.
8. Supabase Storage bucket SQL exists for reference photos.
9. Reference-image upload flow exists.
10. Reference upload requires consent.
11. Reference upload requires online state.
12. Reference upload records metadata/storage path.
13. Local cache and remote sync service exist.
14. Rive artist brief exists.
15. Rive technical contract exists.
16. Style acceptance checklist exists.
```

## What is not complete yet

The real production avatar is not visually complete until this file exists:

```text
assets/avatar_rive/base_avatar.riv
```

Until that file is added, the app should correctly show the diagnostic instead of pretending the avatar is ready.

## Required Rive file contract

```text
File: assets/avatar_rive/base_avatar.riv
Artboard: Avatar
State machine: AvatarState
```

Required number inputs:

```text
skinTone
faceShape
hairPack
hairStyle
hairColor
bodyPreset
```

Required boolean inputs:

```text
freckles
vitiligo
hasFacialHair
hasGlasses
```

## Style target

```text
Apple/Meta-style polished 3D-inspired avatar
Soft lighting
Rounded facial geometry
Believable skin variation
Anatomically correct hair placement
Respectful body presentation
Respectful accessibility/accessory rendering
```

## Hard rejection rules

Reject the Rive rig if:

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
