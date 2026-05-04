import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.8';

import { corsHeaders, jsonResponse } from '../_shared/cors.ts';
import type {
  AvatarGenerationBatchRequest,
  AvatarGenerationBatchResponse,
  AvatarGenerationCandidateResponse,
} from '../_shared/avatar-types.ts';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY');
const OPENAI_IMAGE_MODEL = Deno.env.get('OPENAI_IMAGE_MODEL') ?? 'gpt-image-1';
const AVATAR_BUCKET = Deno.env.get('AVATAR_BUCKET') ?? 'avatar-candidates';

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return jsonResponse(
      { error: 'Method not allowed.' },
      { status: 405 },
    );
  }

  try {
    assertEnv();

    const authHeader = req.headers.get('Authorization') ?? '';
    if (!authHeader) {
      return jsonResponse(
        { error: 'Missing Authorization header.' },
        { status: 401 },
      );
    }

    const body = (await req.json()) as AvatarGenerationBatchRequest;
    validateRequest(body);

    const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: {
        headers: {
          Authorization: authHeader,
        },
      },
    });

    const adminClient = createClient(
      SUPABASE_URL,
      SUPABASE_SERVICE_ROLE_KEY,
    );

    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();

    if (userError || !user) {
      return jsonResponse(
        { error: 'Unauthorized.' },
        { status: 401 },
      );
    }

    await ensureBucket(adminClient);

    const batchId = crypto.randomUUID();
    const count = clampNumber(body.count ?? 4, 1, 6);
    const size = normalizeSize(body.size ?? '1024x1024');
    const variationStrength = normalizeVariationStrength(body);
    const seedValue = normalizeSeed(body.seed?.value, batchId);

    const candidates: AvatarGenerationCandidateResponse[] = [];

    for (let i = 0; i < count; i += 1) {
      const candidateSeed = `${seedValue}-${i + 1}`;
      const prompt = buildProviderPrompt(body, candidateSeed, i);

      let imageUrl: string | undefined = undefined;
      let provider: AvatarGenerationCandidateResponse["provider"] = "fallback";

      if (OPENAI_API_KEY) {
        try {
          const imageBytes = await generateImageWithOpenAI({
            prompt,
            size,
            sourceImageUrl: body.sourceImageUrl,
          });

          const objectPath =
            `${user.id}/${batchId}/candidate_${String(i + 1).padStart(2, "0")}.png`;

          const uploadResult = await adminClient.storage
            .from(AVATAR_BUCKET)
            .upload(objectPath, imageBytes, {
              contentType: "image/png",
              upsert: true,
              cacheControl: "3600",
            });

          if (uploadResult.error) {
            console.warn(
              `OpenAI candidate storage upload failed for candidate ${i + 1}: ${uploadResult.error.message}`,
            );
          } else {
            const publicUrlData = adminClient.storage
              .from(AVATAR_BUCKET)
              .getPublicUrl(objectPath);
            imageUrl = publicUrlData.data.publicUrl;
            provider = "openai";
          }
        } catch (error) {
          console.warn(
            `OpenAI image generation failed for candidate ${i + 1}: ${error.message}`,
          );
        }
      }

      // Fallback to Pollinations
      if (!imageUrl) {
        try {
          const url = buildPollinationsUrl({ prompt, seed: candidateSeed, size });
          const response = await fetch(url);
          if (!response.ok) {
            throw new Error(`Pollinations failed: ${response.statusText}`);
          }
          const imageBytes = new Uint8Array(await response.arrayBuffer());

          const objectPath =
            `${user.id}/${batchId}/candidate_${String(i + 1).padStart(2, "0")}.png`;

          const uploadResult = await adminClient.storage
            .from(AVATAR_BUCKET)
            .upload(objectPath, imageBytes, {
              contentType: "image/png",
              upsert: true,
              cacheControl: "3600",
            });

          if (uploadResult.error) {
            console.warn(
              `Pollinations candidate storage upload failed for candidate ${i + 1}: ${uploadResult.error.message}`,
            );
          } else {
            const publicUrlData = adminClient.storage
              .from(AVATAR_BUCKET)
              .getPublicUrl(objectPath);
            imageUrl = publicUrlData.data.publicUrl;
            provider = "pollinations";
          }
        } catch (error) {
          console.warn(
            `Pollinations image generation failed for candidate ${i + 1}: ${error.message}`,
          );
        }
      }

      const warnings = buildWarnings(body);
      const qualityScore = scoreCandidate(i, warnings.length);

      candidates.push({
        id: crypto.randomUUID(),
        label: `Candidate ${i + 1}`,
        imageUrl,
        prompt,
        provider,
        qualityScore,
        seed: candidateSeed,
        variationStrength,
        warnings,
      });
    }

    const bestCandidate =
      [...candidates].sort((a, b) => b.qualityScore - a.qualityScore)[0] ??
      null;

    const response: AvatarGenerationBatchResponse = {
      batchId,
      provider: bestCandidate?.provider ?? "fallback",
      model: OPENAI_IMAGE_MODEL,
      createdAt: new Date().toISOString(),
      bestCandidateId: bestCandidate?.id ?? null,
      candidates,
    };

    return jsonResponse(response, { status: 200 });
  } catch (error) {
    console.error('generate-avatar-candidates failed:', error);

    const message =
      error instanceof Error ? error.message : 'Unknown server error.';

    return jsonResponse(
      { error: message },
      { status: 500 },
    );
  }
});

function buildPollinationsUrl(
  input: { prompt: string; seed: string; size: string },
): string {
  const [width, height] = input.size.split("x").map(Number);
  const params = new URLSearchParams({
    prompt: input.prompt,
    seed: input.seed,
    width: String(width),
    height: String(height),
    // The following parameters are for fine-tuning Pollinations results
    // You may need to adjust these based on testing
    "model": "stable-diffusion-xl-beta-v2.2.1",
    "aspect_ratio": `${width}:${height}`,
    "nofeed": "true",
    "no_log": "true",
    "no_ui": "true",
    "enhance_prompts": "true",
  });
  return `https://image.pollinations.ai/prompt/${encodeURIComponent(input.prompt)}?${params.toString()}`;
}

function getLocalFallbackAvatar(seed: string): Uint8Array {
  const svg = `
    <svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect width="1024" height="1024" fill="#E5E7EB"/>
      <circle cx="512" cy="412" r="200" fill="#9CA3AF"/>
      <ellipse cx="512" cy="780" rx="300" ry="150" fill="#9CA3AF"/>
      <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-family="sans-serif" font-size="100" fill="#FFFFFF">${seed.substring(0, 2).toUpperCase()}</text>
    </svg>
  `;
  return new TextEncoder().encode(svg);
}

function assertEnv(): void {
  const missing: string[] = [];

  if (!SUPABASE_URL) missing.push('SUPABASE_URL');
  if (!SUPABASE_ANON_KEY) missing.push('SUPABASE_ANON_KEY');
  if (!SUPABASE_SERVICE_ROLE_KEY) {
    missing.push("SUPABASE_SERVICE_ROLE_KEY");
  }

  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(', ')}`,
    );
  }
}

function validateRequest(body: AvatarGenerationBatchRequest): void {
  if (!body || typeof body !== 'object') {
    throw new Error('Invalid request body.');
  }

  if (!body.prompt || typeof body.prompt !== 'string') {
    throw new Error('Request body must include a prompt string.');
  }

  if ((body.prompt ?? '').trim().length < 12) {
    throw new Error('Prompt is too short.');
  }
}

function clampNumber(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

function normalizeSize(size: string): string {
  const allowed = new Set([
    '256x256',
    '512x512',
    '1024x1024',
    '1024x1536',
    '1536x1024',
  ]);

  return allowed.has(size) ? size : '1024x1024';
}

function normalizeSeed(seed: string | undefined, batchId: string): string {
  const cleaned = (seed ?? '').trim();
  return cleaned.length > 0 ? cleaned : batchId;
}

function normalizeVariationStrength(
  body: AvatarGenerationBatchRequest,
): string {
  if (typeof body.variationStrengthName === 'string' &&
    body.variationStrengthName.trim().length > 0) {
    return body.variationStrengthName.trim();
  }

  if (typeof body.variationStrength === 'string' &&
    body.variationStrength.trim().length > 0) {
    return body.variationStrength.trim();
  }

  if (typeof body.variationStrength === 'number') {
    if (body.variationStrength <= 0.2) return 'low';
    if (body.variationStrength <= 0.6) return 'medium';
    return 'high';
  }

  return 'medium';
}

function isMinorProfile(body: AvatarGenerationBatchRequest): boolean {
  if (body.policy?.minorSafe === true) return true;

  const age = (body.profile?.agePresentation ?? '').toLowerCase();
  return age === 'child' || age === 'preteen' || age === 'pre_teen' ||
    age === 'teen';
}

function buildWarnings(body: AvatarGenerationBatchRequest): string[] {
  const warnings: string[] = [];

  if (isMinorProfile(body)) {
    warnings.push('minor-safe-generation-applied');
  }

  if (body.policy?.noBiometricIdentification !== false) {
    warnings.push('not-a-biometric-identity-render');
  }

  return warnings;
}

function scoreCandidate(index: number, warningCount: number): number {
  const base = 0.96 - (index * 0.01) - (warningCount * 0.01);
  return Number(Math.max(0.80, base).toFixed(2));
}

function buildProviderPrompt(
  body: AvatarGenerationBatchRequest,
  candidateSeed: string,
  index: number,
): string {
  const stylePreset = body.stylePreset ?? 'semiRealisticPremium';
  const variationStrength = normalizeVariationStrength(body);
  const isMinor = isMinorProfile(body);

  const profile = body.profile ?? {};
  const accessibilityItems = Array.isArray(profile.accessibilityItems)
    ? profile.accessibilityItems.join(', ')
    : '';

  const variationInstruction = (() => {
    switch (variationStrength.toLowerCase()) {
      case 'low':
        return 'Keep identity and styling very consistent. Make only subtle changes in facial nuance, clothing detail, and background treatment.';
      case 'high':
        return 'Allow stronger variation while preserving the same person concept. Vary styling, crop nuance, hair arrangement, and outfit detail more boldly.';
      default:
        return 'Keep the same person concept while allowing moderate variation in expression nuance, clothing detail, and portrait styling.';
    }
  })();

  const realismInstruction = (() => {
    const realism = (profile.realismLevel ?? '').toLowerCase();
    if (stylePreset === 'digital3D') {
      return 'Render as a high-fidelity 3D digital illustration in the style of Apple Memoji or Meta Avatars. Use soft subsurface scattering on skin, clean smooth geometry, professional studio lighting, and a friendly modern high-end appearance.';
    }
    if (realism.includes('ultra')) {
      return 'Render as a highly realistic, premium portrait suitable for a modern app avatar, but still soft, warm, and non-creepy.';
    }
    if (realism.includes('semi')) {
      return 'Render as a semi-realistic premium portrait with natural facial structure and believable detail.';
    }
    return 'Render as a soft premium portrait, more realistic than cartoon, with natural facial structure and clean app-friendly styling.';
  })();

  const culturalItem = profile.culturalItem && profile.culturalItem !== 'none'
    ? `Respectfully include ${profile.culturalItem}.`
    : '';

  const accessoryInstruction = accessibilityItems
    ? `Respectfully include these accessibility or assistive features where relevant: ${accessibilityItems}.`
    : '';

  const minorSafetyInstruction = isMinor
    ? 'The portrait must be clearly age-appropriate, wholesome, non-sexualised, and suitable for a child or teen wellbeing app.'
    : 'The portrait must remain respectful, non-sexualised, and suitable for a general wellbeing app.';

  const negativePrompt = (body.negativePrompt ?? '').trim();

  return [
    'Create exactly one avatar portrait.',
    body.prompt.trim(),
    realismInstruction,
    `Style preset: ${stylePreset}.`,
    `Variation strength: ${variationStrength}.`,
    variationInstruction,
    'This is for a supportive executive-function and wellbeing app.',
    'The result must feel inclusive, warm, dignified, and emotionally safe.',
    'Head-and-shoulders portrait only.',
    'Single person only.',
    'Centered composition.',
    'Readable at small app-avatar size.',
    'Clean simple background.',
    'No text, no watermark, no logo, no collage, no multiple people.',
    'Do not make it look like Lego, toy-like, blocky, plastic, caricatured, or primitive.',
    'Avoid exaggerated or cartoonish proportions.',
    'No uncanny or distorted face.',
    'No extra limbs, no deformed features, no offensive stereotypes.',
    minorSafetyInstruction,
    culturalItem,
    accessoryInstruction,
    body.policy?.noBiometricIdentification !== false
      ? 'Do not attempt biometric identity reproduction of a real uploaded face. This is an original generated avatar inspired by profile traits only.'
      : '',
    `Internal variation token: ${candidateSeed}.`,
    `Candidate index: ${index + 1}.`,
    negativePrompt.length > 0
      ? `Avoid these traits: ${negativePrompt}.`
      : '',
  ].filter(Boolean).join('\n\n');
}

async function ensureBucket(
  adminClient: ReturnType<typeof createClient>,
): Promise<void> {
  const getBucketResult = await adminClient.storage.getBucket(AVATAR_BUCKET);

  if (!getBucketResult.error) {
    return;
  }

  const createResult = await adminClient.storage.createBucket(AVATAR_BUCKET, {
    public: true,
    fileSizeLimit: 5 * 1024 * 1024,
    allowedMimeTypes: ['image/png', 'image/jpeg', 'image/webp'],
  });

  if (createResult.error &&
    !createResult.error.message.toLowerCase().includes('already exists')) {
    throw new Error(
      `Could not create storage bucket "${AVATAR_BUCKET}": ${createResult.error.message}`,
    );
  }
}

async function generateImageWithOpenAI(
  input: { prompt: string; size: string; sourceImageUrl?: string },
): Promise<Uint8Array> {
  const url = 'https://gen.pollinations.ai/v1/images/generations';
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${OPENAI_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: input.sourceImageUrl ? 'flux-realism' : 'flux',
      prompt: input.prompt,
      size: input.size,
      n: 1,
      response_format: 'b64_json',
      image: input.sourceImageUrl, // Pass source image if available
    }),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`OpenAI image generation failed: ${text}`);
  }

  const json = await response.json();
  const base64Image = json?.data?.[0]?.b64_json;

  if (!base64Image || typeof base64Image !== 'string') {
    throw new Error('OpenAI returned no image payload.');
  }

  return base64ToUint8Array(base64Image);
}

function base64ToUint8Array(base64: string): Uint8Array {
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);

  for (let i = 0; i < binary.length; i += 1) {
    bytes[i] = binary.charCodeAt(i);
  }

  return bytes;
}