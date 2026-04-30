# Dope-i Neon Hoodie Robot Mascot

The orb-only direction is retired. Dope-i should match the neon hoodie robot mascot reference and remain clearly separate from user avatars.

Required visual traits:

- rounded 3D robot head
- black glossy visor
- cyan glow facial features
- black hoodie with drawstrings
- over-ear headphones
- purple/cyan neon accents
- soft rounded shapes rather than block, toy, or Lego proportions

The current Flutter fallback is rendered procedurally with `DopeiOrbAvatar` for API compatibility, but the art direction is no longer an orb. It paints the hoodie, headphones, visor, cyan facial features, and purple/cyan neon trim directly with `CustomPainter`.

## Moods

- neutral
- focused
- happy
- celebration
- overwhelmed
- calm
- encouraging
- proud

## Use

```dart
DopeiOrbAvatar(
  mood: DopeiMood.focused,
)
```

Use `AnimatedDopeyAvatar` in product UI so reduced-motion and mood transitions remain consistent.
