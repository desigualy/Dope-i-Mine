# Dope-i-Mine Avatar Asset Pipeline

Production flow:

1. Build or source avatar meshes in Blender.
2. Keep required material and anchor names stable.
3. Export `assets/avatar_glb/base_avatar.glb`.
4. Create overlay animations in Glaxnimate.
5. Export Lottie JSON overlays.
6. Create Rive file only if using Rive for face/bust.
7. Update `assets/avatar/catalogues/avatar_plugin_asset_manifest.json`.
8. Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install_avatar_plugin_assets.ps1
```

The app code renders assets. It does not invent premium art by itself.
