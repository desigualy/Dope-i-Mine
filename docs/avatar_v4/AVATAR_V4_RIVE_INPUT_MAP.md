# Avatar Engine V4 — Rive Input Map

## Identity

```text
File: assets/avatar_rive/base_avatar.riv
Artboard: Avatar
State machine: AvatarState
```

## Number inputs

| Input | Range | Meaning | Runtime source |
|---|---:|---|---|
| `skinTone` | 0.0–1.0 | Selects skin material/tone | `AvatarV4Config.skinTone` |
| `faceShape` | 0.0–1.0 | Selects head/face shape | `AvatarV4Config.faceShape` |
| `hairPack` | 0.0–1.0 | Selects hair family pack | `AvatarV4Config.hairPackId` |
| `hairStyle` | 0.0–1.0 | Selects style inside active hair pack | `AvatarV4Config.hairStyleId` |
| `hairColor` | 0.0–1.0 | Selects hair palette/material | `AvatarV4Config.hairColor` |
| `bodyPreset` | 0.0–1.0 | Selects body presentation | `AvatarV4Config.bodyPresetId` |

## Boolean inputs

| Input | Meaning | Runtime source |
|---|---|---|
| `freckles` | Enables freckles detail layer | `AvatarV4Config.freckles` |
| `vitiligo` | Enables vitiligo detail layer | `AvatarV4Config.vitiligo` |
| `hasFacialHair` | Enables facial hair group | `facialHairStyleId != 'none'` |
| `hasGlasses` | Enables glasses group | `accessoryIds.contains('glasses')` |

## Recommended input handling inside Rive

Because Rive number inputs are continuous, the rig should divide each number into bands.

Example for `skinTone`:

```text
0.000–0.124 very_light
0.125–0.249 light
0.250–0.374 medium
0.375–0.499 olive
0.500–0.624 tan
0.625–0.749 brown
0.750–0.874 deep_brown
0.875–1.000 very_deep
```

Example for `hairPack`:

```text
0.000–0.083 straight
0.084–0.166 wavy
0.167–0.249 curly
0.250–0.332 coily
0.333–0.415 afro
0.416–0.498 ringlet_afro
0.499–0.581 braids
0.582–0.664 locs
0.665–0.747 twists
0.748–0.830 shaved
0.831–0.913 covered
0.914–1.000 frizzy
```

## Runtime conversion

The Flutter runtime hashes string IDs into stable `0.0 → 1.0` values. That means Rive must not rely on exact numbers like `0.5`; it must tolerate bands.

## Future expansion

Do not remove existing input names. Add new inputs later with backward compatibility, for example:

```text
scarAmount
birthmarkAmount
matureLines
hairLength
facialHairStyle
mouthShape
eyeShape
```
