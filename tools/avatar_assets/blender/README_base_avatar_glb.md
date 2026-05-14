# Dope-i-Mine base_avatar.glb authoring

Run:

```powershell
blender --background --python tools/avatar_assets/blender/create_base_avatar_starter.py
```

Output:

```text
assets/avatar_glb/base_avatar.glb
```

This starter GLB is not final Apple/Meta-quality art. It proves the production pipeline:
Blender export → Flutter GLB plugin render → Supabase upload → resolver → avatar preview.

Keep these names stable when replacing the starter model with production art.

Materials:
- skin_material
- hair_material
- eye_material
- top_material
- bottom_material
- outerwear_material
- shoe_material

Anchors:
- head_anchor
- hair_anchor
- headwear_anchor
- glasses_anchor
- left_ear_anchor
- right_ear_anchor
- back_anchor
- left_hand_anchor
- right_hand_anchor
- accessibility_anchor
- wheelchair_anchor

Shape keys:
- jaw_width
- cheek_fullness
- chin_length
- face_softness
