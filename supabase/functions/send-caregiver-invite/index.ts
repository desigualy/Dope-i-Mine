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
    caregiverPassword?: string
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
        const caregiverPassword = String(body.caregiverPassword ?? '')

        if (!inviteId || !targetUserEmail || !targetUserEmail.includes('@')) {
            return json({ error: 'inviteId and targetUserEmail are required' }, 400)
        }
        if (caregiverPassword.length < 8) {
            return json({ error: 'caregiverPassword must be at least 8 characters' }, 400)
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
            .select('id, inviter_user_id, invitee_email, role, status, requires_password_setup, password_setup_sent_at')
            .eq('id', inviteId)
            .single()

        if (inviteError || !invite) return json({ error: 'Caregiver email invite not found' }, 404)
        if (invite.inviter_user_id !== callerId) {
            return json({ error: 'Not allowed to send this caregiver invite' }, 403)
        }
        if (String(invite.invitee_email).toLowerCase() !== targetUserEmail) {
            return json({ error: 'Invite email mismatch' }, 400)
        }

        let caregiverUser = await findUserByEmail(admin, targetUserEmail)

        if (caregiverUser) {
            const { error: updateUserError } = await admin.auth.admin.updateUserById(caregiverUser.id, {
                password: caregiverPassword,
                email_confirm: true,
                user_metadata: {
                    ...caregiverUser.user_metadata,
                    caregiver_email_invite_id: inviteId,
                    caregiver_role: role,
                },
            })

            if (updateUserError) {
                console.error('Caregiver auth user password update failed', updateUserError.message)
                return json({ error: updateUserError.message }, 502)
            }
        } else {
            const { data: createdUser, error: createUserError } = await admin.auth.admin.createUser({
                email: targetUserEmail,
                password: caregiverPassword,
                email_confirm: true,
                user_metadata: { caregiver_email_invite_id: inviteId, caregiver_role: role },
                app_metadata: { caregiver_invited: true },
            })

            if (createUserError || !createdUser.user) {
                console.error('Caregiver auth user creation failed', createUserError?.message)
                return json({ error: createUserError?.message ?? 'Caregiver auth user was not created' }, 502)
            }

            caregiverUser = { id: createdUser.user.id, user_metadata: createdUser.user.user_metadata as Record<string, unknown> | undefined }
        }

        const caregiverUserId = caregiverUser.id
        const acceptedAt = new Date().toISOString()

        const { error: profileError } = await admin
            .from('users_profile')
            .upsert({
                id: caregiverUserId,
                email: targetUserEmail,
                account_type: 'caregiver',
                onboarding_completed: true,
                onboarding_completed_at: acceptedAt,
                updated_at: acceptedAt,
            }, { onConflict: 'id' })

        if (profileError) return json({ error: profileError.message }, 502)

        const { error: caregiverProfileError } = await admin
            .from('caregiver_profiles')
            .upsert({
                user_id: caregiverUserId,
                contact_email: targetUserEmail,
                verification_status: 'unverified',
                updated_at: new Date().toISOString(),
            }, { onConflict: 'user_id' })

        if (caregiverProfileError) return json({ error: caregiverProfileError.message }, 502)

        const { data: relationship, error: relationshipError } = await admin
            .from('caregiver_relationships')
            .upsert({
                caregiver_user_id: caregiverUserId,
                supported_user_id: callerId,
                role,
                status: 'accepted',
                accepted_at: acceptedAt,
                revoked_at: null,
            }, { onConflict: 'caregiver_user_id,supported_user_id' })
            .select('id, caregiver_user_id, supported_user_id, role, status, relationship_label, created_at, accepted_at, revoked_at')
            .single()

        if (relationshipError || !relationship) {
            return json({ error: relationshipError?.message ?? 'Caregiver relationship was not created' }, 502)
        }

        const { error: markSetupRequiredError } = await admin
            .from('caregiver_email_invites')
            .update({
                status: 'accepted',
                accepted_user_id: caregiverUserId,
                accepted_at: acceptedAt,
                requires_password_setup: false,
                password_setup_sent_at: null,
            })
            .eq('id', inviteId)

        if (markSetupRequiredError) return json({ error: markSetupRequiredError.message }, 502)

        return json({
            ok: true,
            mode: 'auth_invite',
            inviteId,
            role,
            relationship,
            requiresPasswordSetup: false,
            passwordSetup: { required: false, passwordCreated: true },
        })
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

async function findUserByEmail(
    admin: ReturnType<typeof createClient>,
    email: string,
): Promise<{ id: string; user_metadata?: Record<string, unknown> } | null> {
    for (let page = 1; page <= 10; page += 1) {
        const { data, error } = await admin.auth.admin.listUsers({ page, perPage: 100 })
        if (error) throw new Error(error.message)
        const user = data.users.find((candidate: { email?: string | null }) => candidate.email?.toLowerCase() === email)
        if (user) {
            return {
                id: user.id,
                user_metadata: user.user_metadata as Record<string, unknown> | undefined,
            }
        }
        if (data.users.length < 100) return null
    }
    return null
}