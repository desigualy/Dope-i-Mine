import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
    if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

    try {
        const { stepText, taskText, taskTitle } = await req.json()
        return new Response(
            JSON.stringify({
                substeps: generateMicroSteps(String(stepText ?? ''), String(taskText ?? ''), String(taskTitle ?? '')).map((text) => ({ text })),
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 },
        )
    } catch (error) {
        console.error('Error in breakdown-step:', error)
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 500,
        })
    }
})

function generateMicroSteps(stepText: string, taskText: string, taskTitle: string): string[] {
    const stepLower = stepText.toLowerCase().trim()
    const contextLower = `${taskTitle} ${taskText}`.toLowerCase().trim()

    // 1. Exact Step-Level Actions (Highest Priority)
    if (stepLower.includes('pair') || stepLower.includes('match')) {
        return ['Find one item', 'Look for its exact match', 'Put them together', 'Place them in the finished pile', 'Look for the next item']
    }
    if (stepLower.includes('sort') || stepLower.includes('separate')) {
        return ['Pick one category to look for first', 'Move matching items into one small pile', 'Pick the next category', 'Move those items into another pile', 'Stop when the mixed pile is smaller']
    }
    if (stepLower.includes('stack') || stepLower.includes('pile')) {
        return ['Find the largest or heaviest items first', 'Place them at the bottom', 'Find the next size down', 'Place them on top', 'Repeat until everything is stacked safely']
    }
    if (stepLower.includes('clear') || stepLower.includes('wipe')) {
        return ['Look at the area you need to clear', 'Remove one item that does not belong', 'Put it where it goes', 'Wipe the surface if needed', 'Check if the area is clear']
    }
    if (stepLower.includes('drawer') || stepLower.includes('wardrobe') || stepLower.includes('hang')) {
        return ['Pick up the item', 'Walk to the storage space', 'Open the door or drawer', 'Place or hang the item inside', 'Close the door or drawer']
    }
    if (stepLower.includes('plug in') || stepLower.includes('turn on')) {
        return ['Find the cable or switch', 'Check it is safe to use', 'Plug it in or press the button', 'Wait for it to turn on', 'Move to the next step']
    }
    if (stepLower.includes('pocket')) {
        return ['Pick up one clothing item', 'Put your hand in the first pocket', 'Remove anything inside', 'Check the other pockets', 'Put the item into the wash pile']
    }
    if (stepLower.includes('scrape') || stepLower.includes('leftover')) {
        return ['Pick up one item with food on it', 'Hold it over the bin', 'Use a fork or scraper to remove the food', 'Put the scraped item by the sink', 'Repeat for the next item']
    }
    
    // 2. Task-Level Core Actions (Medium Priority)
    if (stepLower.includes('fold')) {
        return ['Pick up one item to fold', 'Lay it flat or hold it', 'Smooth it with your hands', 'Fold it or place it on a hanger', 'Place it in the finished pile']
    }
    if (stepLower.includes('wash') || stepLower.includes('rinse')) {
        return ['Pick up one item', 'Wet or rinse it', 'Add soap or use the soapy water', 'Scrub the easiest visible area', 'Rinse or place it to drain']
    }
    if (stepLower.includes('hoover') || stepLower.includes('vacuum')) {
        return ['Hold the hoover handle', 'Place the head flat on the floor', 'Push it forward slowly', 'Pull it back over the same strip', 'Move sideways and repeat']
    }
    if (stepLower.includes('bin') || stepLower.includes('rubbish') || stepLower.includes('trash')) {
        return ['Pick up the nearest rubbish item', 'Check it is definitely rubbish', 'Put it in the bag or bin', 'Pick up one more rubbish item', 'Pause and check the area']
    }

    // 3. Contextual Fallback (Low Priority)
    if (contextLower.includes('washing up') || contextLower.includes('dishes')) {
        return ['Look only at this item', 'Move it closer to the sink', 'Do the first small part of washing it', 'Do the next small part', 'Check if it is clean enough']
    }
    if (contextLower.includes('washing away') || contextLower.includes('laundry') || contextLower.includes('clothes') || contextLower.includes('fold')) {
        return ['Look only at the clothes for this step', 'Pick up the first item', 'Do the first small movement', 'Place it where it belongs', 'Check whether this pile is done']
    }
    if (contextLower.includes('clean') || contextLower.includes('hoover') || contextLower.includes('tidy')) {
        return ['Look only at this small area', 'Get the tool you need', 'Do the first small cleaning movement', 'Do one more movement', 'Check if this patch is done']
    }

    // 4. Absolute Generic Fallback
    return ['Look only at this step', 'Get anything you need for it', 'Do the first small movement', 'Do one more small movement', 'Check whether this step is done enough']
}