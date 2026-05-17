import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

type AcceptInviteBody = {
    inviteId?: string
}

type InviteRow = {
    id: string
    inviter_user_id: string
    invitee_email: string
    role: string
    status: string
    accepted_user_id: string | null
    accepted_at: string | null
    requires_password_setup: boolean | null
    password_setup_sent_at: string | null
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

        const body = await req.json() as AcceptInviteBody
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

        const inviteBefore = await loadInvite(admin, inviteId)
        if (!inviteBefore) return json({ error: 'Caregiver email invite not found' }, 404)

        let relationship: Record<string, unknown> | null = null
        if (inviteBefore.status === 'pending') {
            const { data: rpcData, error: acceptError } = await userClient.rpc(
                'accept_caregiver_email_invite',
                { p_invite_id: inviteId },
            )

            if (acceptError) {
                console.error('accept-caregiver-invite RPC failed', acceptError.message)
                return json({ error: acceptError.message }, 409)
            }

            relationship = normalizeRelationship(rpcData)
        } else if (inviteBefore.status === 'accepted') {
            if (inviteBefore.accepted_user_id !== callerId) {
                return json({ error: 'Caregiver invite has already been accepted by another user' }, 403)
            }
        } else {
            return json({ error: `Caregiver invite is ${inviteBefore.status}` }, 409)
        }

        const inviteAfter = await loadInvite(admin, inviteId)
        if (!inviteAfter) return json({ error: 'Caregiver email invite disappeared after acceptance' }, 500)
        if (inviteAfter.accepted_user_id !== callerId) {
            return json({ error: 'Caregiver invite was not accepted by the current user' }, 403)
        }

        if (!relationship) {
            relationship = await loadAcceptedRelationship(admin, inviteAfter)
        }

        if (!relationship) {
            return json({ error: 'Caregiver relationship was not found after invite acceptance' }, 500)
        }

        const passwordSetup = await maybeSendPasswordSetupEmail({
            admin,
            publicClient,
            invite: inviteAfter,
            appBaseUrl,
        })

        return json({ ok: true, inviteId, relationship, passwordSetup })
    } catch (error) {
        console.error('accept-caregiver-invite failed:', error)
        return json({ error: error instanceof Error ? error.message : String(error) }, 500)
    }
})

async function loadInvite(admin: ReturnType<typeof createClient>, inviteId: string): Promise<InviteRow | null> {
    const { data, error } = await admin
        .from('caregiver_email_invites')
        .select('id, inviter_user_id, invitee_email, role, status, accepted_user_id, accepted_at, requires_password_setup, password_setup_sent_at')
        .eq('id', inviteId)
        .maybeSingle()

    if (error) throw new Error(error.message)
    return data as InviteRow | null
}

function normalizeRelationship(value: unknown): Record<string, unknown> | null {
    if (!value) return null
    if (Array.isArray(value)) {
        const first = value.length > 0 ? value[0] : null
        return first && typeof first === 'object' ? first as Record<string, unknown> : null
    }
    return typeof value === 'object' ? value as Record<string, unknown> : null
}

async function loadAcceptedRelationship(
    admin: ReturnType<typeof createClient>,
    invite: InviteRow,
): Promise<Record<string, unknown> | null> {
    if (!invite.accepted_user_id) return null

    const { data: inviterProfile, error: profileError } = await admin
        .from('users_profile')
        .select('account_type')
        .eq('id', invite.inviter_user_id)
        .maybeSingle()

    if (profileError) throw new Error(profileError.message)

    const inviterIsCaregiver = inviterProfile?.account_type === 'caregiver'
    const caregiverUserId = inviterIsCaregiver ? invite.inviter_user_id : invite.accepted_user_id
    const supportedUserId = inviterIsCaregiver ? invite.accepted_user_id : invite.inviter_user_id

    const { data: relationship, error: relationshipError } = await admin
        .from('caregiver_relationships')
        .select('id, caregiver_user_id, supported_user_id, role, status, relationship_label, created_at, accepted_at, revoked_at')
        .eq('caregiver_user_id', caregiverUserId)
        .eq('supported_user_id', supportedUserId)
        .maybeSingle()

    if (relationshipError) throw new Error(relationshipError.message)
    return relationship as Record<string, unknown> | null
}

async function maybeSendPasswordSetupEmail({
    admin,
    publicClient,
    invite,
    appBaseUrl,
}: {
    admin: ReturnType<typeof createClient>
    publicClient: ReturnType<typeof createClient>
    invite: InviteRow
    appBaseUrl: string
}): Promise<Record<string, unknown>> {
    if (invite.requires_password_setup !== true) {
        return { required: false, sent: false, alreadySent: false }
    }

    if (invite.password_setup_sent_at) {
        // Password setup is sent by send-caregiver-invite immediately after the
        // auth user shell is created. Do not send a duplicate email on accept.
        return { required: true, sent: false, alreadySent: true, sentAt: invite.password_setup_sent_at }
    }

    const inviteeEmail = String(invite.invitee_email ?? '').trim().toLowerCase()
    if (!inviteeEmail || !inviteeEmail.includes('@')) {
        return { required: true, sent: false, alreadySent: false, error: 'Invite email is invalid' }
    }

    const redirectTo = `${appBaseUrl.replace(/\/$/, '')}/reset-password?invite_id=${encodeURIComponent(invite.id)}`
    const { error: resetError } = await publicClient.auth.resetPasswordForEmail(inviteeEmail, { redirectTo })

    if (resetError) {
        console.error('Caregiver password setup email failed', resetError.message)
        return { required: true, sent: false, alreadySent: false, error: resetError.message }
    }

    const sentAt = new Date().toISOString()
    const { error: updateError } = await admin
        .from('caregiver_email_invites')
        .update({ password_setup_sent_at: sentAt })
        .eq('id', invite.id)
        .eq('accepted_user_id', invite.accepted_user_id)
        .is('password_setup_sent_at', null)

    if (updateError) {
        console.error('Caregiver password setup timestamp update failed', updateError.message)
        return { required: true, sent: true, alreadySent: false, sentAt, stampFailed: true, error: updateError.message }
    }

    return { required: true, sent: true, alreadySent: false, sentAt }
}

function json(body: Record<string, unknown>, status = 200): Response {
    return new Response(JSON.stringify(body), {
        status,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
}