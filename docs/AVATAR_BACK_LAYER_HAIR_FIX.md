# Avatar Back-Layer Hair Fix

This fixes the remaining visible bug shown in the screenshot.

Root cause:
- The active renderer was painting hair after the head, so curls appeared on top of the face.
- Curly/afro curls were still allowed into the front face layer.

Fix:
- Paint hair/headwear before ears/head/face.
- Let the head paint mask inner curl mass.
- Draw curly/afro hair as an outer crown/side silhouette only.
- Remove centre/front curl blobs.
- Keep ringlets outside the face silhouette.
- Prevent curly/afro styles from using the generic front hair texture.

Patched file:
- lib/presentation/user_avatar/user_avatar_renderer.dart
