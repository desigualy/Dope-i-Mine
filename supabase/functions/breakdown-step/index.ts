import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

console.log("breakdown-step function started")

serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { stepText, mode, energyLevel, stressLevel } = await req.json()

    // Generate substeps for further breakdown
    const substeps = generateSubsteps(stepText, mode, energyLevel, stressLevel)

    const response = {
      substeps,
    }

    return new Response(
      JSON.stringify(response),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )
  } catch (error) {
    console.error('Error in breakdown-step:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      },
    )
  }
})

function generateSubsteps(stepText: string, mode: string, energyLevel: string, stressLevel: string): any[] {
  const text = stepText.toLowerCase().trim()

  // Handle specific common patterns
  if (text.includes('sort laundry')) {
    return [
      { text: 'Separate whites from colors' },
      { text: 'Check care labels for washing instructions' },
      { text: 'Sort by fabric type (delicates, towels, etc.)' },
    ]
  }

  if (text.includes('load washing machine')) {
    return [
      { text: 'Add appropriate amount of detergent' },
      { text: 'Place laundry evenly in machine' },
      { text: 'Select correct wash cycle and temperature' },
    ]
  }

  if (text.includes('clean surfaces')) {
    return [
      { text: 'Choose appropriate cleaning product' },
      { text: 'Spray surface and let sit briefly' },
      { text: 'Wipe with clean cloth or paper towel' },
    ]
  }

  if (text.includes('respond to emails')) {
    return [
      { text: 'Read email carefully' },
      { text: 'Draft clear, concise response' },
      { text: 'Proofread before sending' },
    ]
  }

  // Generic breakdown based on action verbs
  const actionVerbs = ['clean', 'wash', 'fold', 'sort', 'organize', 'check', 'review', 'prepare', 'gather', 'collect']
  const words = text.split(' ')
  const actions = words.filter(word => actionVerbs.some(verb => word.includes(verb)))

  if (actions.length > 1) {
    return actions.map(action => ({
      text: `${action.charAt(0).toUpperCase() + action.slice(1)} ${words.filter(w => !actions.includes(w)).join(' ')}`.trim()
    }))
  }

  // Split long sentences into smaller parts
  if (text.length > 50) {
    const midPoint = Math.floor(text.length / 2)
    const splitPoint = text.indexOf(' ', midPoint)
    if (splitPoint > 0) {
      return [
        { text: text.substring(0, splitPoint).trim() },
        { text: text.substring(splitPoint).trim() },
      ]
    }
  }

  // Default: split by conjunctions
  const parts = text.split(/\s+(and|or|then|after|before|while)\s+/i)
  if (parts.length > 1) {
    const result = []
    for (let i = 0; i < parts.length; i += 2) {
      const part = parts[i].trim()
      if (part) result.push({ text: part })
    }
    if (result.length > 1) return result
  }

  // Ultimate fallback: just return the original step
  return [{ text: stepText.trim() }]
}