# Dope-i Neon Hoodie Robot Asset System

Production drop-in mascot assets live in:

```text
assets/avatar/dopey/
```

The canonical Flutter paths are:

```text
assets/avatar/dopey/neutral.png
assets/avatar/dopey/happy.png
assets/avatar/dopey/focused.png
assets/avatar/dopey/overwhelmed.png
assets/avatar/dopey/encouraging.png
assets/avatar/dopey/proud.png
assets/avatar/dopey/celebration.png
assets/avatar/dopey/calm.png
```

Each top-level file is a transparent 1024x1024 PNG master. Downscale exports are generated in sibling size folders (`512/`, `256/`, `128/`, `64/`) for store, web, or notification use.

Current runtime rendering also includes a procedural safety fallback that follows the final mascot direction: black visor, cyan glow face, black hoodie, headphones, purple/cyan neon accents, and rounded 3D robot proportions.

## Flutter usage

`DopeiMood.assetPath` maps every mood to the correct production PNG path. `DopeiAvatar`/`AnimatedDopeyAvatar` render the neon hoodie robot mascot with reduced-motion support and can accept PNG replacement assets later without changing mood names.

```dart
Image.asset(DopeiMood.happy.assetPath);
```

## Phase 1 animation system

Use `AnimatedDopeyAvatar` for the image-based companion animation layer:

```dart
AnimatedDopeyAvatar(
  mood: DopeiMood.focused,
  size: 150,
)
```

Mood behaviours:

| Mood | Behaviour |
| --- | --- |
| Neutral | slow idle float |
| Focused | slight steady glow, minimal movement |
| Happy | soft bounce |
| Celebration | bigger bounce with a tiny tilt |
| Overwhelmed | tiny shake, then settle |
| Calm | slow breathing scale |
| Encouraging | small forward pop |
| Proud | gentle upright glow |

Reduced motion is supported through `reducedMotion: true` and the system accessibility flag (`MediaQuery.disableAnimations`). When enabled, the avatar renders as a static image with no bounce, shake, rotation, or scaling.

Regenerate the local transparent PNG pack with:

```bash
node tool/generate_dopey_avatar_assets.js
```

When final extracted source images are available, replace the PNG files at these same paths with crops that match the neon hoodie robot reference. No Lego/block, toy, or childish mascot variants should be introduced.