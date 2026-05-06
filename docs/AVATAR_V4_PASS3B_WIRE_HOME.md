# Avatar Engine V4 — Pass 3B Home Wiring

This pass wires the public Home avatar surfaces to Avatar Engine V4.

## What changes

- Home hero uses `AvatarRiveView`.
- Home hero key is `home-avatar-v4-rive`.
- The old `UnifiedUserAvatar` / V3 public avatar is removed from Home.
- Avatar studio preview uses `AvatarRiveView`.
- Avatar studio buttons route to `/avatar/customize`.
- App router gets `/avatar/customize` -> `AvatarCustomizerScreen`.
- Tests check source wiring so the old renderer cannot silently come back.

## Expected visual result

Until this file exists:

```text
assets/avatar_rive/base_avatar.riv
```

Home should show the red-bordered `Avatar rig missing` diagnostic, not the old curly SVG/paint avatar.

That is intentional. It proves the fake renderer is no longer the public target.

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\apply_avatar_v4_pass3b_wire_home.ps1
flutter analyze
flutter test
flutter run
```
