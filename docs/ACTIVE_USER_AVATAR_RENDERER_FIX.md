# Active User Avatar Renderer Fix

The actual screenshot path was the string-based `UserAvatarRenderer`, not the newer `PremiumPortraitAvatar`.

This patch fixes the active renderer:
- Adds real selectable hair styles:
  - Curly afro with side part
  - Full curly afro
  - Shoulder-length curls
  - Long ringlets
- Adds auburn and copper hair colours.
- Adds explicit facial hair field, defaulting to `none`.
- Locks facial hair to `none` for child and pre-teen modes.
- Replaces the active fallback painter curly/afro hair geometry.
- Curly/afro hair is clipped to the crown/upper side head area.
- Side ringlets can fall to shoulders but only outside the face silhouette.
- Head hair never occupies the mouth/chin/jaw zone.
