import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

console.log("breakdown-step function started")

serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
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

  if ((text.includes('washing') || text.includes('laundry') || text.includes('clothes')) &&
      (text.includes('put away') || text.includes('fold') || text.includes('hang'))) {
    return [
      { text: 'Pick up one item' },
      { text: 'Fold it or hang it up' },
      { text: 'Put it in the right place' },
      { text: 'Repeat with the next item' },
    ]
  }

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

  if (text.includes('tidy') || text.includes('clean room')) {
    return [
      { text: 'Pick up items from the floor' },
      { text: 'Put things back in their designated spots' },
      { text: 'Wipe down any dusty surfaces' },
    ]
  }

  if (text.includes('cook') || text.includes('prepare meal')) {
    return [
      { text: 'Gather all ingredients and tools' },
      { text: 'Prepare the ingredients (chop, wash, etc.)' },
      { text: 'Follow the cooking steps' },
      { text: 'Serve and tidy the kitchen' },
    ]
  }

  // Generic breakdown based on action verbs
  const actionVerbs = ['clean', 'wash', 'fold', 'sort', 'organize', 'check', 'review', 'prepare', 'gather', 'collect', 'tidy', 'vacuum', 'hoover']
  const words = text.split(/\s+/)
  const actions = words.filter(word => actionVerbs.some(verb => word.includes(verb)))

  if (actions.length > 0) {
    // If we have a verb, try to create a 3-step breakdown
    const verb = actions[0]
    const object = words.filter(w => !actionVerbs.includes(w)).join(' ')
    return [
      { text: `Get ready to ${verb} ${object}`.trim() },
      { text: `Start ${verb}ing ${object}`.trim() },
      { text: `Finish and check ${verb} ${object}`.trim() },
    ]
  }

  // Split long sentences into smaller parts
  if (text.length > 40) {
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
    for (let i = 0; i < parts.length; i += 1) {
      const part = parts[i].trim()
      const conjunctions = ['and', 'or', 'then', 'after', 'before', 'while']
      if (part && !conjunctions.includes(part.toLowerCase())) {
        result.push({ text: part })
      }
    }
    if (result.length > 1) return result
  }

  // Ultimate fallback: just return the original step broken into tiny pieces
  return [
    { text: 'Prepare for the task' },
    { text: `Take one small step: ${text}` },
    { text: 'Complete and review' },
  ]
}