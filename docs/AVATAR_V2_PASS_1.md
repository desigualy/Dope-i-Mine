# Avatar V2 Pass 1 Foundation

This patch creates the production Avatar V2 foundation beside the legacy avatar system.

## Goal

Stop patching the broken legacy painter and introduce a proper avatar engine with:

- structured profile data
- anatomical layer ordering
- hair texture/style separation
- facial hair separated from scalp hair
- skin detail modeling
- accessibility modeling
- reference-image metadata
- a first renderer and preview card

## New files

```text
lib/domain/avatar_v2/avatar_v2_profile.dart
lib/domain/avatar_v2/avatar_v2_options.dart
lib/domain/avatar_v2/avatar_v2_layers.dart
lib/domain/avatar_v2/avatar_v2_validation.dart
lib/presentation/avatar_v2/avatar_v2_renderer.dart
lib/presentation/avatar_v2/avatar_v2_preview_card.dart
lib/presentation/avatar_v2/avatar_v2_studio.dart
test/avatar_v2/avatar_v2_validation_test.dart
test/avatar_v2/avatar_v2_layer_order_test.dart
```

## What this pass deliberately avoids

This pass does not remove the legacy avatar system. It creates Avatar V2 alongside it so the old system can remain as fallback while V2 is wired into Home, Settings, and Onboarding in the next pass.

## Hard rules now represented in code

- Back hair renders before face/head skin.
- Facial hair renders after mouth but before glasses.
- Child and pre-teen avatars normalize facial hair to none.
- Hair styles are validated against hair texture.
- Afro/coily hair cannot use unsafe front-face fringe overlap.
- Locs/braids/twists are treated as scalp-rooted strand families.

## Next pass

Pass 2 should wire Avatar V2 into:

- Home avatar card
- Settings companion/avatar editor
- Onboarding avatar step
- Local persistence
- Optional migration from legacy UserAvatarProfile to AvatarV2Profile
