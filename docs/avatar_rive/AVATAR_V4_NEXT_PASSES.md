# Avatar V4 — Remaining Passes

## Required

### Pass 4A — Real Rive rig import

Add:

```text
assets/avatar_rive/base_avatar.riv
```

The rig must satisfy:

```text
Artboard: Avatar
State machine: AvatarState
Required inputs locked in AvatarV4RiveContract
```

### Pass 4B — Control binding QA

Verify every V4 control visibly changes the avatar:

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

### Pass 4C — Visual QA iteration

Fix the actual rig until it passes the style checklist.

Focus areas:

```text
hair placement
locs/braids/twists depth
afro/coily/ringlet realism
facial hair vertical position
birthmarks/scars/vitiligo/freckles realism
body presentation
accessibility items
```

## Optional but recommended

### Pass 4D — Store/unlock packs

Wire purchased outfits/accessories into:

```text
avatar_inventory
local cache
remote sync
```

### Pass 4E — Delete old V3 leftovers

Only after repo-wide import scan proves nothing relies on them.

### Pass 4F — Real-device Supabase upload test

Verify:

```text
auth user id
online state
storage upload
avatar_uploads metadata insert
local cache
remote sync
```

## Current truth

The Flutter engine is ready.

The visual quality now depends on the actual Rive art/rig.
