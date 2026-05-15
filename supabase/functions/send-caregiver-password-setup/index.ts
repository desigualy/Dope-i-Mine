import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

type PasswordSetupBody = {
    inviteId?: string
}

serve(async (req) => {
    if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
    if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405)

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

        const body = await req.json() as PasswordSetupBody
        const inviteId = String(body.inviteId ?? '').trim()
        if (!inviteId) return json({ error: 'inviteId is required' }, 400)

        const admin = createClient(supabaseUrl, serviceRoleKey, {
            auth: { autoRefreshToken: false, persistSession: false },
        })
        const userClient = createClient(supabaseUrl, anonKey, {
            global: { headers: { Authorization: authHeader } },
            auth: { autoRefreshToken: false, persistSession: false },
        })
        const publicClient = createClient(supabaseUrl, anonKey, {
            auth: { autoRefreshToken: false, persistSession: false },
        })

        const { data: callerData, error: callerError } = await userClient.auth.getUser()
        if (callerError || !callerData.user) return json({ error: 'Invalid authorization token' }, 401)
        const callerId = callerData.user.id

        const { data: invite, error: inviteError } = await admin
            .from('caregiver_email_invites')
            .select('id, invitee_email, status, accepted_user_id, requires_password_setup, password_setup_sent_at')
            .eq('id', inviteId)
            .single()

        if (inviteError || !invite) return json({ error: 'Caregiver email invite not found' }, 404)
        if (invite.status !== 'accepted') return json({ error: 'Caregiver invite has not been accepted yet' }, 409)
        if (invite.accepted_user_id !== callerId) return json({ error: 'Not allowed to set up password for this invite' }, 403)

        if (invite.requires_password_setup !== true) {
            return json({ ok: true, sent: false, notRequired: true, inviteId })
        }

        if (invite.password_setup_sent_at) {
            return json({ ok: true, sent: false, alreadySent: true, inviteId })
        }

        const inviteeEmail = String(invite.invitee_email ?? '').trim().toLowerCase()
        if (!inviteeEmail || !inviteeEmail.includes('@')) {
            return json({ error: 'Invite email is invalid' }, 400)
        }

        const redirectTo = `${appBaseUrl.replace(/\/$/, '')}/reset-password?invite_id=${encodeURIComponent(inviteId)}`
        const { error: resetError } = await publicClient.auth.resetPasswordForEmail(
            inviteeEmail,
            { redirectTo },
        )

        if (resetError) {
            console.error('Caregiver password setup email failed', resetError.message)
            return json({ error: resetError.message }, 502)
        }

        const { error: updateError } = await admin
            .from('caregiver_email_invites')
            .update({ password_setup_sent_at: new Date().toISOString() })
            .eq('id', inviteId)
            .eq('accepted_user_id', callerId)
            .is('password_setup_sent_at', null)

        if (updateError) {
            console.error('Caregiver password setup timestamp update failed', updateError.message)
            return json({ error: updateError.message }, 502)
        }

        return json({ ok: true, sent: true, inviteId })
    } catch (error) {
        console.error('send-caregiver-password-setup failed:', error)
        return json({ error: error instanceof Error ? error.message : String(error) }, 500)
    }
})

function json(body: Record<string, unknown>, status = 200): Response {
    return new Response(JSON.stringify(body), {
        status,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
}
