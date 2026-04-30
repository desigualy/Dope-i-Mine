# Avatar Candidate Generation Layer

## Purpose

This improves actual image generation quality by generating multiple avatar candidates, scoring them, and letting the user choose.

## Flow

UserAvatarProfile
→ StructuredRealisticAvatarPromptBuilder
→ AvatarGenerationBatchRequest
→ AvatarBatchGenerator
→ Supabase Edge Function: `generate-avatar-candidates`
→ AvatarGenerationBatchResult
→ AvatarCandidateSelectorScreen

## Expected Edge Function Response

```json
{
  "batchId": "batch_123",
  "providerId": "image-provider",
  "revisedPrompt": "optional",
  "candidates": [
    {
      "id": "candidate_1",
      "imageUrl": "https://...",
      "qualityScore": 0.91,
      "seed": "seed-value",
      "variationStrength": "medium",
      "warnings": [],
      "metadata": {}
    }
  ]
}
```

## Product Rules

- Generate 4 candidates by default.
- Do not auto-accept the first image.
- Prefer semi-realistic premium over ultra-realistic as the default.
- Keep private abstract available.
- Use low variation to preserve identity.
- Use high variation only when the user asks to explore.