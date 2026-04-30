# Avatar Generation Safety Layer

## Purpose

This layer makes realistic avatar generation safer and more user-controlled.

## Adds

- AvatarGenerationPolicy
- AvatarSeed
- AvatarRefinementRequest
- AvatarQualityValidator
- AvatarRealismConsentScreen
- AvatarRegenerationPanel
- AvatarQualityIssuesPanel

## Product Rules

- No real photo required
- No biometric identity claims
- Private abstract mode must stay available
- Minor profiles require stricter prompt safety
- Users can regenerate, refine, or delete avatars
- Identity representation must never be premium-only

## Suggested Flow

1. User creates profile choices
2. Show realism consent screen
3. Build prompt
4. Validate prompt
5. Generate avatar
6. Validate provider metadata
7. User accepts, regenerates, refines, or switches to abstract mode