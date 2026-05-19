export interface AvatarGenerationBatchRequest {
  prompt: string;
  negativePrompt?: string;
  count?: number;
  size?: string;
  stylePreset?: string;
  variationStrength?: string | number;
  variationStrengthName?: string;
  sourceImageUrl?: string;
  seed?: {
    value?: string;
  };
  profile?: {
    agePresentation?: string;
    accessibilityItems?: string[];
    realismLevel?: string;
    culturalItem?: string;
  };
  policy?: {
    minorSafe?: boolean;
    noBiometricIdentification?: boolean;
  };
}

export interface AvatarGenerationCandidateResponse {
  id: string;
  label: string;
  imageUrl?: string;
  prompt: string;
  provider: 'openai' | 'pollinations' | 'fallback';
  qualityScore: number;
  seed: string;
  variationStrength: string;
  warnings: string[];
}

export interface AvatarGenerationBatchResponse {
  batchId: string;
  provider: 'openai' | 'pollinations' | 'fallback';
  model: string;
  createdAt: string;
  bestCandidateId: string | null;
  candidates: AvatarGenerationCandidateResponse[];
}
