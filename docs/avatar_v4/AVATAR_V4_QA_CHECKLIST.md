# Avatar Engine V4 — QA Checklist

## Runtime checks

```text
[ ] File exists at assets/avatar_rive/base_avatar.riv
[ ] pubspec.yaml includes assets/avatar_rive/
[ ] Flutter loads AvatarRiveView without missing-rig diagnostic
[ ] Artboard name is Avatar
[ ] State machine name is AvatarState
[ ] Required number inputs exist
[ ] Required boolean inputs exist
[ ] App does not crash if optional future inputs are missing
```

## Visual checks

```text
[ ] Avatar reads clearly at 96px
[ ] Avatar reads clearly at 180px
[ ] Avatar reads clearly at 220px
[ ] Avatar reads clearly at 512px
[ ] Hair sits behind/on head
[ ] Hair does not form beard mass
[ ] Facial hair sits on lower face only
[ ] Eyes, nose, mouth align naturally
[ ] Glasses align with eyes
[ ] Hearing aids align with ears
[ ] Headwear does not accidentally erase face
[ ] Skin details look respectful and realistic enough
[ ] Freckles are visible but not clown-like
[ ] Vitiligo does not look like random paint splatter
[ ] Birthmarks and scars are placed intentionally
```

## Inclusivity checks

```text
[ ] Coily/afro/ringlet hair styles are not caricatures
[ ] Braids/locs/twists are structured, not curtain blobs
[ ] Facial hair options are not stuck too high on the face
[ ] Mature lines are subtle and not punitive
[ ] Body presets are respectful
[ ] Medical/accessibility items are not novelty props
```

## Regression checks

```text
[ ] flutter analyze
[ ] flutter test
[ ] Home shows AvatarRiveView
[ ] Home does not show old V3 renderer
[ ] Customizer shows AvatarRiveView
[ ] Reference image upload panel still appears
[ ] Offline upload remains blocked
[ ] Supabase metadata registration still works
```
