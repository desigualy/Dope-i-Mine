# Avatar V2 Force Live Renderer Patch

This patch fixes the problem where Avatar V2 exists and tests pass, but the visible app still looks unchanged.

## Root cause

The live app was still reaching legacy renderers:

- `UnifiedUserAvatar`
- `PremiumPortraitAvatar`
- `UserAvatarRenderer`

Pass 3 improved `AvatarV2Renderer`, but those legacy paths could still render the old portrait.

## What this patch does

- Makes `UnifiedUserAvatar` render through Avatar V2.
- Makes `PremiumPortraitAvatar` render through Avatar V2.
- Makes the older `UserAvatarRenderer` render through Avatar V2.
- Adds a legacy adapter so old profiles are mapped into the new Avatar V2 anatomical schema.
- Keeps old public class names so existing screens/tests do not need route rewrites.

## Apply

Extract into project root, overwriting files, then run:

```powershell
flutter analyze
flutter test
flutter run
```

## Visual confirmation

The avatar should now visibly change anywhere the app uses:

- Home avatar
- Onboarding avatar
- Settings/Companion avatar
- Old user avatar renderer path
- Premium portrait path
