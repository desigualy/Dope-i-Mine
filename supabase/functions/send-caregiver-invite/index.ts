import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

type InviteBody = {
    inviteId?: string
    targetUserEmail?: string
    role?: string
}

serve(async (req) => {
    if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
    if (req.method !== 'POST') {
        return json({ error: 'Method not allowed' }, 405)
    }

    try {
        const supabaseUrl = Deno.env.get('SUPABASE_URL')
        const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
        const anonKey = Deno.env.get('SUPABASE_ANON_KEY')
        const appBaseUrl = Deno.env.get('APP_BASE_URL') ?? 'https://dope-i-mine.app'

        if (!supabaseUrl || !serviceRoleKey || !anonKey) {
            return json({ error: 'Missing Supabase function environment variables' }, 500)
        }

        const authHeader = req.headers.get('Authorization')
        if (!authHeader) return json({ error: 'Missing authorization header' }, 401)

        const body = await req.json() as InviteBody
        const inviteId = String(body.inviteId ?? '').trim()
        const targetUserEmail = String(body.targetUserEmail ?? '').trim().toLowerCase()
        const role = String(body.role ?? 'caregiver').trim()

        if (!inviteId || !targetUserEmail || !targetUserEmail.includes('@')) {
            return json({ error: 'inviteId and targetUserEmail are required' }, 400)
        }

        const admin = createClient(supabaseUrl, serviceRoleKey, {
            auth: { autoRefreshToken: false, persistSession: false },
        })
        const userClient = createClient(supabaseUrl, anonKey, {
            global: { headers: { Authorization: authHeader } },
            auth: { autoRefreshToken: false, persistSession: false },
        })

        const { data: callerData, error: callerError } = await userClient.auth.getUser()
        if (callerError || !callerData.user) return json({ error: 'Invalid authorization token' }, 401)
        const callerId = callerData.user.id

        const { data: invite, error: inviteError } = await admin
            .from('caregiver_email_invites')
            .select('id, inviter_user_id, invitee_email, role, status')
            .eq('id', inviteId)
            .single()

        if (inviteError || !invite) return json({ error: 'Caregiver email invite not found' }, 404)
        if (invite.inviter_user_id !== callerId) {
            return json({ error: 'Not allowed to send this caregiver invite' }, 403)
        }
        if (String(invite.invitee_email).toLowerCase() !== targetUserEmail) {
            return json({ error: 'Invite email mismatch' }, 400)
        }

        const redirectTo = `${appBaseUrl.replace(/\/$/, '')}/caregiver?invite_id=${encodeURIComponent(inviteId)}`

        // Existing users receive a Supabase magic-link email that brings them back
        // into the app where the pending caregiver relationship is visible.
        const { error: otpError } = await userClient.auth.signInWithOtp({
            email: targetUserEmail,
            options: {
                emailRedirectTo: redirectTo,
                shouldCreateUser: false,
                data: { caregiver_email_invite_id: inviteId, caregiver_role: role },
            },
        })

        if (!otpError) {
            return json({ ok: true, mode: 'magic_link', inviteId, role })
        }

        // For new users, we use the inviteUserByEmail function. 
        // We redirect them to /reset-password so they can set their initial password.
        const newCaregiverRedirectTo = `${appBaseUrl.replace(/\/$/, '')}/reset-password?invite_id=${encodeURIComponent(inviteId)}`
        
        const { error: authInviteError } = await admin.auth.admin.inviteUserByEmail(targetUserEmail, {
            redirectTo: newCaregiverRedirectTo,
            data: { caregiver_email_invite_id: inviteId, caregiver_role: role },
        })

        if (authInviteError) {
            console.error('Caregiver invite email failed', { otpError: otpError.message, inviteError: authInviteError.message })
            return json({ error: authInviteError.message, otpError: otpError.message }, 502)
        }

        return json({ ok: true, mode: 'auth_invite', inviteId, role })
    } catch (error) {
        console.error('send-caregiver-invite failed:', error)
        return json({ error: error instanceof Error ? error.message : String(error) }, 500)
    }
})

function json(body: Record<string, unknown>, status = 200): Response {
    return new Response(JSON.stringify(body), {
        status,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
}