# Avatar Engine V4 — Rive Artist Delivery Checklist

The artist/developer must deliver:

```text
[ ] base_avatar.riv
[ ] 512x512 preview PNG
[ ] 220x220 preview PNG
[ ] screenshot of Rive artboard name: Avatar
[ ] screenshot of Rive state machine name: AvatarState
[ ] screenshot/list of all required inputs
[ ] screenshot/list of top-level layer groups
```

## Required input list

```text
skinTone
faceShape
hairPack
hairStyle
hairColor
bodyPreset
freckles
vitiligo
hasFacialHair
hasGlasses
```

## Required layer checks

```text
[ ] hair_back is behind head
[ ] hair_front is above head but does not cover lower face by default
[ ] facial_hair is separate from scalp hair
[ ] glasses sit on eyes/bridge
[ ] hearing accessories align with ears
[ ] skin details are not parody-like
[ ] body shapes are respectful
```

## Rejection criteria

Reject the `.riv` if:

```text
[ ] hair looks like a beard
[ ] ringlet afro appears as side beard
[ ] locs/braids become a curtain over the face
[ ] facial hair starts too high
[ ] body presets look insulting
[ ] accessibility items look like novelty props
[ ] file has wrong artboard name
[ ] file has wrong state machine name
[ ] required inputs are missing
```

## First acceptance target

The first accepted rig does not need every future variant, but it must look premium and be expandable.

Minimum acceptable visible options:

```text
8 skin tones
5 face shapes
6 hair families
3 body presets
freckles toggle
vitiligo toggle
glasses toggle
facial hair toggle
```
