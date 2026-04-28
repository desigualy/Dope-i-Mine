import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

console.log("create-task function started")

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
    const { sourceText, mode, energyLevel, stressLevel, timeAvailable } = await req.json()

    // Simple task breakdown logic
    const normalizedTitle = sourceText.trim().split(/[.!?]/)[0].trim() || 'New task'
    const category = categorizeTask(sourceText)

    // Generate primary steps based on task complexity
    const primarySteps = generatePrimarySteps(sourceText, mode, energyLevel, stressLevel, timeAvailable)

    // Generate minimum version (simplified steps)
    const minimumVersionSteps = generateMinimumSteps(sourceText, mode)

    // Generate side quests
    const sideQuests = generateSideQuests(sourceText, category)

    const response = {
      normalizedTitle,
      category,
      effortBand: estimateEffort(primarySteps.length, timeAvailable),
      estimatedMinutes: estimateTime(primarySteps.length, timeAvailable),
      primarySteps,
      minimumVersionSteps,
      sideQuests,
    }

    return new Response(
      JSON.stringify(response),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )
  } catch (error) {
    console.error('Error in create-task:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      },
    )
  }
})

function generatePrimarySteps(sourceText: string, mode: string, energyLevel: string, stressLevel: string, timeAvailable: string): any[] {
  const text = sourceText.toLowerCase().trim()

  if ((text.includes('washing') || text.includes('laundry') || text.includes('clothes')) &&
      (text.includes('put away') || text.includes('fold') || text.includes('hang'))) {
    return [
      { text: 'Bring the clean washing to one place', isOptional: false },
      { text: 'Sort the clothes into small piles', isOptional: false },
      { text: 'Fold or hang one pile at a time', isOptional: false },
      { text: 'Put each pile into the right drawer or wardrobe', isOptional: false },
    ]
  }

  // Simple keyword-based breakdown
  if (text.includes('laundry') || text.includes('washing') || text.includes('clothes')) {
    return [
      { text: 'Collect the laundry into one place', isOptional: false },
      { text: 'Sort items by type or where they belong', isOptional: false },
      { text: 'Handle one small group at a time', isOptional: false },
      { text: 'Put the finished clothes away', isOptional: false },
    ]
  }

  if (text.includes('clean') || text.includes('tidy')) {
    return [
      { text: 'Gather cleaning supplies needed', isOptional: false },
      { text: 'Clear surfaces and remove clutter', isOptional: false },
      { text: 'Clean surfaces with appropriate cleaner', isOptional: false },
      { text: 'Organize items back neatly', isOptional: false },
      { text: 'Dispose of trash and recycling', isOptional: false },
    ]
  }

  if (text.includes('email') || text.includes('respond')) {
    return [
      { text: 'Open email application', isOptional: false },
      { text: 'Review unread emails', isOptional: false },
      { text: 'Respond to urgent emails first', isOptional: false },
      { text: 'Compose responses clearly', isOptional: false },
      { text: 'Send emails and mark as complete', isOptional: false },
    ]
  }

  // Default breakdown for any task
  const sentences = sourceText.split(/[.!?]/).filter(s => s.trim().length > 0)
  if (sentences.length > 1) {
    return sentences.map(sentence => ({
      text: sentence.trim(),
      isOptional: false
    }))
  }

  // Very basic fallback
  return [
    { text: `Get ready to start: ${sourceText.trim()}`, isOptional: false },
    { text: `Do one small part of: ${sourceText.trim()}`, isOptional: false },
    { text: `Finish and check off: ${sourceText.trim()}`, isOptional: false },
  ]
}

function generateMinimumSteps(sourceText: string, mode: string): any[] {
  const text = sourceText.toLowerCase().trim()

  // Minimum version is always just the core action
  if ((text.includes('washing') || text.includes('laundry') || text.includes('clothes')) &&
      (text.includes('put away') || text.includes('fold') || text.includes('hang'))) {
    return [{ text: 'Put away just one small pile of washing', isOptional: false }]
  }

  if (text.includes('laundry') || text.includes('washing') || text.includes('clothes')) {
    return [{ text: 'Put away one or two items of clothing', isOptional: false }]
  }

  if (text.includes('clean') || text.includes('tidy')) {
    return [{ text: 'Clean the space', isOptional: false }]
  }

  if (text.includes('email') || text.includes('respond')) {
    return [{ text: 'Check and respond to emails', isOptional: false }]
  }

  // Default minimum version
  return [{ text: `Do the easiest first part of: ${sourceText.trim()}`, isOptional: false }]
}

function categorizeTask(sourceText: string): string {
  const text = sourceText.toLowerCase()

  if (text.includes('clean') || text.includes('tidy') || text.includes('laundry')) {
    return 'household'
  }

  if (text.includes('email') || text.includes('work') || text.includes('meeting')) {
    return 'work'
  }

  if (text.includes('exercise') || text.includes('run') || text.includes('walk')) {
    return 'health'
  }

  return 'general'
}

function estimateEffort(stepCount: number, timeAvailable: string): string {
  if (stepCount <= 2) return 'low'
  if (stepCount <= 5) return 'medium'
  return 'high'
}

function estimateTime(stepCount: number, timeAvailable: string): number {
  const baseTime = stepCount * 5 // 5 minutes per step
  const multiplier = {
    '2m': 0.5,
    '5m': 0.8,
    '15m': 1.0,
    '30m_plus': 1.2,
  }[timeAvailable] || 1.0

  return Math.max(5, Math.min(60, Math.round(baseTime * multiplier)))
}

function generateSideQuests(sourceText: string, category: string): any[] {
  const quests = []
  
  if (category === 'household') {
    quests.push({
      title: 'Put on a high-energy playlist',
      quest_type: 'motivation',
      reward_xp: 50
    })
    quests.push({
      title: 'Set a 15-minute timer for a speed run',
      quest_type: 'challenge',
      reward_xp: 100
    })
  } else if (category === 'work') {
    quests.push({
      title: 'Take a 2-minute stretch break',
      quest_type: 'health',
      reward_xp: 30
    })
    quests.push({
      title: 'Drink a glass of water before starting',
      quest_type: 'health',
      reward_xp: 20
    })
  } else {
    quests.push({
      title: 'Do one small extra thing to help future you',
      quest_type: 'bonus',
      reward_xp: 40
    })
  }

  return quests
}