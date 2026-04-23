import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

console.log("overwhelm-rescue function started")

serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Generate overwhelm support response
    const supportiveActions = [
      "Take a deep breath. You're doing great just by trying.",
      "Focus on just the next single step. One thing at a time.",
      "Remember: progress over perfection. Small steps count.",
      "It's okay to pause and come back later when you feel ready.",
      "You've got this. Break it down even smaller if needed.",
      "Celebrate that you're taking action - that's already a win.",
      "Use a timer for 5 minutes. Just work on it for that long.",
      "Ask yourself: what's the absolute minimum I can do right now?",
      "You're building skills with every attempt. Be kind to yourself.",
      "Switch to the minimum version - it's still meaningful progress.",
    ]

    const randomAction = supportiveActions[Math.floor(Math.random() * supportiveActions.length)]

    const response = {
      showOnlyCurrentStep: true,
      supportiveAction: randomAction,
    }

    return new Response(
      JSON.stringify(response),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )
  } catch (error) {
    console.error('Error in overwhelm-rescue:', error)
    return new Response(
      JSON.stringify({
        showOnlyCurrentStep: true,
        supportiveAction: "Take a moment to breathe. You're doing your best.",
        error: error.message
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      },
    )
  }
})