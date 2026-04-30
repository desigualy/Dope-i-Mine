import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

type TaskSection = { title: string; steps: string[] }
type SideQuest = { title: string; quest_type: string; reward_xp: number }
type TaskTemplate = {
    title: string
    category: string
    estimatedMinutes: number
    sections: TaskSection[]
    sideQuests: SideQuest[]
}

serve(async (req) => {
    if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

    try {
        const { sourceText, timeAvailable } = await req.json()
        const source = String(sourceText ?? '').trim()
        const template = findTemplate(source)
        const normalizedTitle = template?.title || source.split(/[.!?]/)[0].trim() || 'New task'
        const primarySteps = template
            ? template.sections.map((section) => ({
                text: section.title,
                isOptional: false,
                substeps: section.steps.map((text) => ({ text })),
            }))
            : [{
                text: normalizedTitle,
                isOptional: false,
                substeps: generateGenericSteps(source).map((text) => ({ text })),
            }]
        const bitesizeCount = primarySteps.reduce(
            (total, section) => total + ((section.substeps as Array<unknown>)?.length ?? 0),
            0,
        )

        return new Response(
            JSON.stringify({
                normalizedTitle,
                category: template?.category || categorizeTask(source),
                effortBand: estimateEffort(bitesizeCount),
                estimatedMinutes: template?.estimatedMinutes || estimateTime(bitesizeCount, timeAvailable),
                primarySteps,
                minimumVersionSteps: [{ text: `Do just 5 minutes of ${normalizedTitle}`, isOptional: false }],
                sideQuests: template?.sideQuests || defaultSideQuests(),
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 },
        )
    } catch (error) {
        console.error('Error in create-task:', error)
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 500,
        })
    }
})

const templates: Record<string, TaskTemplate> = {
    put_washing_away: {
        title: 'Put washing away',
        category: 'household',
        estimatedMinutes: 25,
        sections: [{
            title: 'Putting the washing away',
            steps: [
                'Collect the clean, dry washing',
                'Put it all in one clear place, like the bed or sofa',
                'Check whether anything is still damp and set it aside',
                'Separate items into piles: tops, bottoms, underwear, socks, towels, bedding',
                'Make a separate pile for anything that needs hanging',
                'Fold each item neatly',
                'Pair socks together',
                'Hang clothes that need hanging',
                'Put folded clothes into the correct drawers',
                'Put towels or bedding into their storage place',
                'Check the area for anything you missed',
                'Put the empty laundry basket away',
            ],
        }],
        sideQuests: [
            { title: 'Put one extra item away', quest_type: 'momentum', reward_xp: 10 },
            { title: 'Match one lonely sock if you spot one', quest_type: 'bonus', reward_xp: 15 },
        ],
    },
    washing_up: {
        title: 'Washing up',
        category: 'household',
        estimatedMinutes: 25,
        sections: [{
            title: 'Washing up',
            steps: [
                'Clear a space on the draining board',
                'Put away anything clean that is already on the draining board',
                'Scrape leftover food into the bin',
                'Stack dishes beside the sink: glasses, cutlery, plates, bowls, pans',
                'Fill the sink with hot water',
                'Add washing-up liquid',
                'Wash glasses and mugs first',
                'Wash cutlery next',
                'Wash plates and bowls',
                'Wash serving dishes',
                'Wash pans and greasy items last',
                'Rinse items if they need it',
                'Place clean items safely on the draining board',
                'Drain the sink and remove food from the plughole',
                'Wipe the sink, taps, and nearby worktop',
                'Dry and put away items, or leave them neatly to air dry',
            ],
        }],
        sideQuests: [
            { title: 'Wipe the worktop after washing up', quest_type: 'shine', reward_xp: 15 },
            { title: 'Put away three dry items', quest_type: 'bonus', reward_xp: 10 },
        ],
    },
    hoover_room: {
        title: 'Hoovering a room',
        category: 'household',
        estimatedMinutes: 20,
        sections: [{
            title: 'Hoovering a room',
            steps: [
                'Pick up anything loose from the floor',
                'Move shoes, bags, toys, or boxes out of the way',
                'Check for coins, cables, or tiny objects that could block the hoover',
                'Move small furniture if it is safe and easy',
                'Check whether the hoover cylinder or bag is full',
                'Plug in the hoover',
                'Start at the far side of the room',
                'Hoover slowly in overlapping lines',
                'Hoover around the edges of the room',
                'Hoover under furniture where you can reach',
                'Use the nozzle for corners and skirting boards',
                'Hoover the middle of the room',
                'Check for missed spots',
                'Turn off and unplug the hoover',
                'Put the hoover away',
            ],
        }],
        sideQuests: [{ title: 'Empty hoover if full', quest_type: 'maintenance', reward_xp: 20 }],
    },
    make_bed: {
        title: 'Making a bed',
        category: 'household',
        estimatedMinutes: 10,
        sections: [{
            title: 'Making a bed',
            steps: [
                'Clear anything that does not belong on the bed',
                'Pull the duvet or blanket back',
                'Smooth the bottom sheet flat',
                'Tuck in any loose sheet corners if needed',
                'Shake out the duvet so the filling spreads evenly',
                'Lay the duvet evenly over the bed',
                'Pull the duvet up to the top of the bed',
                'Straighten the left side',
                'Straighten the right side',
                'Plump the pillows',
                'Place pillows at the head of the bed',
                'Do one final smoothing pass',
            ],
        }],
        sideQuests: [{ title: 'Put one item from the bed where it belongs', quest_type: 'bonus', reward_xp: 10 }],
    },
    change_bed: {
        title: 'Changing a bed',
        category: 'household',
        estimatedMinutes: 30,
        sections: [{
            title: 'Changing the bed',
            steps: [
                'Remove pillows from the bed',
                'Take off the pillowcases',
                'Remove the duvet cover',
                'Remove the fitted sheet',
                'Put dirty bedding into the laundry basket',
                'Get a clean fitted sheet, duvet cover, and pillowcases',
                'Put the clean fitted sheet on one mattress corner',
                'Secure the other fitted sheet corners',
                'Put the duvet into the clean cover',
                'Hold the top corners and shake the duvet down',
                'Fasten the duvet cover buttons, poppers, or zipper',
                'Put clean pillowcases on pillows',
                'Return pillows to the head of the bed',
                'Lay the duvet evenly and straighten everything',
                'Move dirty bedding near the washing machine or laundry area',
            ],
        }],
        sideQuests: [{ title: 'Start a bedding wash if there is enough energy', quest_type: 'optional_extra', reward_xp: 20 }],
    },
    put_on_wash: {
        title: 'Putting on a wash',
        category: 'household',
        estimatedMinutes: 20,
        sections: [{
            title: 'Putting on a wash',
            steps: [
                'Collect dirty laundry into one place',
                'Separate laundry into whites, colours, darks, towels, bedding, or delicates',
                'Choose one pile to wash now',
                'Check clothing labels if unsure',
                'Check pockets for tissues, coins, keys, or paper',
                'Turn delicate or printed clothes inside out if needed',
                'Open the washing machine door',
                'Load the chosen wash into the drum',
                'Make sure the drum is not overfilled',
                'Add detergent to the correct drawer or directly into the drum',
                'Add fabric softener if you use it',
                'Close the washing machine door firmly',
                'Choose the correct wash setting',
                'Select the temperature',
                'Press start',
                'Set a reminder to move the washing when it finishes',
            ],
        }],
        sideQuests: [{ title: 'Set a reminder to unload the machine', quest_type: 'future_you', reward_xp: 10 }],
    },
    empty_bin: {
        title: 'Throwing out a bin',
        category: 'household',
        estimatedMinutes: 10,
        sections: [{
            title: 'Throwing out the bin',
            steps: [
                'Check whether the bin needs emptying',
                'Press rubbish down gently if needed',
                'Tie the bin bag securely',
                'Lift the bag out carefully',
                'Check for leaks',
                'Double-bag it if it is leaking',
                'Carry the bag to the outside bin',
                'Put it in the correct outside bin',
                'Close the outside bin lid',
                'Put a fresh liner into the indoor bin',
                'Fold the liner edges over the rim',
                'Wipe the bin lid if it is dirty',
                'Wash your hands',
            ],
        }],
        sideQuests: [{ title: 'Check if recycling needs going out too', quest_type: 'bonus', reward_xp: 15 }],
    },
    clean_room: {
        title: 'Reset bedroom / housework',
        category: 'household',
        estimatedMinutes: 60,
        sections: [
            { title: 'Putting the washing away', steps: ['Collect the clean, dry washing', 'Put it all in one clear place, like the bed or sofa', 'Separate items into piles', 'Fold each item neatly', 'Pair socks together', 'Hang clothes that need hanging', 'Put folded clothes into the correct drawers', 'Put towels or bedding into storage', 'Check the area for missed items', 'Put the empty laundry basket away'] },
            { title: 'Making the bed', steps: ['Clear anything that does not belong on the bed', 'Pull the duvet or blanket back', 'Smooth the bottom sheet flat', 'Shake out the duvet', 'Lay the duvet evenly over the bed', 'Straighten both sides', 'Plump the pillows', 'Place pillows at the head of the bed', 'Do one final smoothing pass', 'Check the bed looks done enough'] },
            { title: 'Clearing rubbish', steps: ['Get a bin bag', 'Look for obvious rubbish', 'Pick up wrappers or tissues', 'Check the desk or bedside table', 'Check the floor near the bed', 'Remove cups or plates', 'Separate recycling if helpful', 'Tie the rubbish bag', 'Take it to the correct bin', 'Check for one final missed item'] },
            { title: 'Hoovering the room', steps: ['Pick up loose floor items', 'Move small things out of the way', 'Check for cables or coins', 'Plug in the hoover', 'Start at the far side of the room', 'Hoover slowly in overlapping lines', 'Hoover the edges', 'Hoover under furniture where reachable', 'Use the nozzle for corners', 'Check for missed spots', 'Unplug and put the hoover away'] },
        ],
        sideQuests: [
            { title: 'Put one extra item away', quest_type: 'momentum', reward_xp: 10 },
            { title: 'Open a window for fresh air', quest_type: 'environment', reward_xp: 10 },
            { title: 'Empty hoover if full', quest_type: 'maintenance', reward_xp: 20 },
        ],
    },
}

function findTemplate(sourceText: string): TaskTemplate | null {
    const text = sourceText.toLowerCase()
    if (hasAny(text, ['household reset', 'housework', 'reset bedroom', 'bedroom reset', 'clean my room', 'clean room', 'tidy my room', 'tidy room'])) return templates.clean_room
    if (hasAny(text, ['change bed', 'change the bed', 'change bedding'])) return templates.change_bed
    if (hasAny(text, ['make bed', 'make the bed', 'making a bed'])) return templates.make_bed
    if (hasAny(text, ['put washing away', 'put the washing away', 'put laundry away', 'put clothes away', 'washing away', 'laundry away', 'fold laundry', 'fold washing'])) return templates.put_washing_away
    if (hasAny(text, ['washing up', 'wash up', 'wash the dishes', 'do the dishes', 'dishes'])) return templates.washing_up
    if (hasAny(text, ['hoover', 'vacuum'])) return templates.hoover_room
    if (hasAny(text, ['put on a wash', 'putting on a wash', 'load washing machine', 'start washing machine'])) return templates.put_on_wash
    if (hasAny(text, ['empty bin', 'take out the bin', 'throw out bin', 'trash', 'rubbish'])) return templates.empty_bin
    return null
}

function hasAny(text: string, needles: string[]): boolean {
    return needles.some((needle) => text.includes(needle))
}

function generateGenericSteps(sourceText: string): string[] {
    const text = sourceText.trim()
    if (!text) return ['Notice the task', 'Do the easiest first action']
    return [
        `Look at what needs doing: ${text}`,
        'Choose the easiest visible starting point',
        'Get only the thing you need first',
        'Do the first tiny action',
        'Pause and notice that you started',
        'Do one more small action if you can',
        'Check what is left',
        'Finish with one clear stopping point',
    ]
}

function categorizeTask(sourceText: string): string {
    const text = sourceText.toLowerCase()
    if (hasAny(text, ['clean', 'tidy', 'laundry', 'washing', 'bed', 'bin', 'hoover', 'vacuum'])) return 'household'
    if (hasAny(text, ['email', 'work', 'meeting'])) return 'work'
    if (hasAny(text, ['exercise', 'run', 'walk'])) return 'health'
    return 'general'
}

function estimateEffort(stepCount: number): string {
    if (stepCount <= 8) return 'low'
    if (stepCount <= 24) return 'medium'
    return 'high'
}

function estimateTime(stepCount: number, timeAvailable: string): number {
    const multiplier = { '2m': 0.5, '5m': 0.8, '15m': 1.0, '30m_plus': 1.2 }[timeAvailable] || 1
    return Math.max(5, Math.min(60, Math.round(stepCount * 3 * multiplier)))
}

function defaultSideQuests(): SideQuest[] {
    return [
        { title: 'Take 3 slow breaths before starting', quest_type: 'sensory', reward_xp: 10 },
        { title: 'Put one extra item where it belongs', quest_type: 'momentum', reward_xp: 10 },
        { title: 'Drink a sip of water', quest_type: 'care', reward_xp: 10 },
    ]
}