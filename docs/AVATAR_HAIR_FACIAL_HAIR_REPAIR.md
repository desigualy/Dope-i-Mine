# Avatar Hair + Facial Hair Repair Patch

This patch fixes the current avatar renderer problem where curly/afro hair can read as beard hair.

Changes:
- Adds AvatarFacialHair as a separate explicit trait.
- Defaults facial hair to none and locks it off for child/pre-teen avatar modes.
- Adds facial hair selection to the avatar creator.
- Splits scalp hair rendering from facial hair rendering.
- Replaces the generic curly/afro back-hair block with a crown/side silhouette that stays above the jaw.
- Adds Apple / Meta realistic avatar as a selectable portrait palette.
- Strengthens realistic avatar prompts and negative prompts so afro/curly hair is kept on scalp/shoulders and not rendered as beard/chin/jaw hair.
- Restores Settings/Onboarding Customize portrait to the trait-based AvatarCreatorScreen path.

Run:
flutter analyze
flutter test
