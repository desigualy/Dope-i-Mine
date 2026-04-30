# Complete Dope-i-Mine Avatar System

## Purpose

This module brings together:

- Dope-i mascot image avatar
- user soft illustrated portrait avatar
- user ultra-realistic image avatar wrapper
- unified user avatar switcher
- avatar creator screen
- mood-to-glow mapping

## Dope-i Mascot Assets

Expected files:

```text
assets/avatar/dopey/
  neutral.png
  happy.png
  focused.png
  overwhelmed.png
  encouraging.png
  proud.png
  celebration.png
  calm.png
```

Add to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/avatar/dopey/
```

## User Avatar Use

```dart
UnifiedUserAvatar(
  profile: UserAvatarProfile.defaultAdult,
  mood: DopeiMood.happy,
)
```

## Dope-i Mascot Use

```dart
ImageDopeiAvatar(
  mood: DopeiMood.focused,
)
```

## Ultra-Realistic Mode

Ultra-realistic avatars are image-based.

Set:

```dart
profile.copyWith(
  renderMode: AvatarRenderMode.ultraRealistic,
  localImagePath: '/path/to/avatar.png',
)
```

or:

```dart
profile.copyWith(
  renderMode: AvatarRenderMode.ultraRealistic,
  generatedImageUrl: 'https://...',
)
```

## Safety / Inclusion Rules

Identity representation must remain free:

- skin tones
- body types
- hair textures
- accessibility items
- cultural/head covering options

Premium monetisation should only apply to:

- fantasy outfits
- animated backgrounds
- frames
- seasonal visual effects