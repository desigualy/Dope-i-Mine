# Avatar Style Geometry Fix

This patch corrects the remaining avatar problem:

- Adds explicit `AvatarHairStyle`
- Adds selectable `Curly afro with side part`
- Adds selectable `Full curly afro`
- Adds selectable shoulder-length curls and long ringlets
- Updates the painter so curly/afro front hair is clipped above mouth/chin/jaw
- Removes lower cheek/jaw curl blobs from afro rendering
- Allows side ringlets only outside the face silhouette
- Updates prompt builders to describe the selected hair style clearly

Acceptance:
- Curly/afro hair does not render as beard-like mass.
- The image-reference style can be selected as `Curly afro with side part`.
- Facial hair remains separate and defaults to none.
