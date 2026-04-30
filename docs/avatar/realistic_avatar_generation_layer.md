# Realistic Avatar Generation Layer

## Purpose

This layer upgrades user avatars from procedural illustration to realistic portrait generation.

## Architecture

UserAvatarProfile
→ RealisticAvatarPromptBuilder
→ RealisticAvatarGenerationRequest
→ RealisticAvatarGenerator
→ Supabase Edge Function / Avatar Service
→ imageUrl
→ UnifiedUserAvatar / UltraRealisticAvatar

## Supabase Edge Function Expected Response

```json
{
  "imageUrl": "https://...",
  "localPath": null,
  "providerId": "optional-id",
  "revisedPrompt": "optional revised prompt"
}
```

## Safety Rules

- no face upload required
- no biometric identity claims
- user can delete generated avatar
- child/pre-teen/teen modes must remain minor-safe
- realistic mode is optional
- abstract/private mode remains available