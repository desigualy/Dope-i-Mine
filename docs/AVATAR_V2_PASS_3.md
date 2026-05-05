# Avatar V2 Pass 3 — Visual Quality Overhaul

Pass 3 replaces the first-pass renderer with a stricter anatomical renderer.

## Fixes in this pass

- Hair is drawn as back/crown/scalp/front-safe layers.
- Afro/coily hair renders as crown/halo mass, not beard volume.
- Curly hair renders as side/back volume, not face-front blobs.
- Locs, braids and twists originate from scalp/root zones.
- Locs no longer draw as a curtain across the face.
- Facial hair is locked to lower-face zones.
- Moustache, goatee, short beard, full beard and sideburns render separately.
- Body frame, shoulder width, neck style and posture produce visible differences.
- Freckles, vitiligo, birthmarks, scars and mature lines are rendered with anatomical placement.
- Glasses, hearing aids, cochlear implant markers, medical patch/glucose monitor are placed against anatomical zones.
- Debug zones exist for visual QA.

## Files

- `lib/presentation/avatar_v2/avatar_v2_renderer.dart`
- `test/avatar_v2/avatar_v2_visual_quality_test.dart`

## Apply

Extract into the project root, then run:

```powershell
flutter analyze
flutter test
```

## Visual QA profiles to check manually

1. Afro-textured, side-part afro, no facial hair.
2. Locs, shoulder length, side-only front policy.
3. Full beard, shaved/bald head.
4. Child profile with facial hair input, validation should normalize to none.
5. Older adult, mature lines, grey hair.
6. Vitiligo bilateral, glasses, hearing aids.
