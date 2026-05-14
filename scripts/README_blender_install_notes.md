# Blender command not found

If this fails:

```powershell
blender --background --python tools/avatar_assets/blender/create_base_avatar_starter.py
```

PowerShell cannot find Blender.

Use:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/run_blender_avatar_starter.ps1
```

If Blender is installed but still not found, pass the full path:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/run_blender_avatar_starter.ps1 -BlenderExe "C:\Program Files\Blender Foundation\Blender 4.5\blender.exe"
```

Then upload assets:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install_avatar_plugin_assets.ps1
```
