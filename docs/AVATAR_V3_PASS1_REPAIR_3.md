# Avatar V3 Pass 1 Repair 3

The remaining test failures were caused by `test/user_avatar/user_avatar_renderer_test.dart` still expecting the deleted legacy renderer:

- `user-avatar-fallback-base`
- old abstract PNG layer keys
- old fallback/cultural marker renderer

That contradicts the locked rule: old renderer deleted, not fallback.

This repair replaces that test file with assertions that the legacy wrapper delegates to `AvatarV3Renderer`.

Run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v3_pass1_tests.ps1
flutter analyze
flutter test
```
