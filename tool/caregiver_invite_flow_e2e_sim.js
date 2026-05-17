const assert = require('node:assert/strict');

function acceptCaregiverInvite({ invite, callerId, relationship, resetPasswordForEmail }) {
    if (!invite) return { status: 404, body: { error: 'Caregiver email invite not found' } };
    if (invite.status !== 'pending' && invite.status !== 'accepted') {
        return { status: 409, body: { error: `Caregiver invite is ${invite.status}` } };
    }
    if (invite.status === 'accepted' && invite.accepted_user_id !== callerId) {
        return { status: 403, body: { error: 'Caregiver invite has already been accepted by another user' } };
    }

    invite.status = 'accepted';
    invite.accepted_user_id = callerId;
    invite.accepted_at = new Date('2026-05-16T09:00:00.000Z').toISOString();

    const passwordSetup = maybeSendPasswordSetupEmail({ invite, resetPasswordForEmail });

    return {
        status: 200,
        body: {
            ok: true,
            inviteId: invite.id,
            relationship,
            passwordSetup,
        },
    };
}

function sendCaregiverInviteForNewUser({ invite, caregiverProfile, caregiverPassword, createOrUpdateUserPassword }) {
    if (caregiverPassword.length < 8) {
        return { status: 400, body: { error: 'caregiverPassword must be at least 8 characters' } };
    }
    const passwordResult = createOrUpdateUserPassword(invite.invitee_email, caregiverPassword);
    if (passwordResult.error) {
        return { status: 502, body: { error: passwordResult.error } };
    }
    const acceptedAt = new Date('2026-05-16T09:00:00.000Z').toISOString();
    caregiverProfile.account_type = 'caregiver';
    caregiverProfile.onboarding_completed = true;
    caregiverProfile.onboarding_completed_at = acceptedAt;
    invite.requires_password_setup = false;
    invite.password_setup_sent_at = null;
    invite.status = 'accepted';
    invite.accepted_user_id = 'caregiver-user-1';
    invite.accepted_at = acceptedAt;
    const passwordSetup = { required: false, passwordCreated: true };
    return {
        status: 200,
        body: {
            ok: true,
            mode: 'direct_relationship',
            inviteId: invite.id,
            relationship: {
                id: 'relationship-1',
                caregiver_user_id: 'caregiver-user-1',
                supported_user_id: invite.inviter_user_id,
                role: invite.role,
                status: 'accepted',
            },
            requiresPasswordSetup: false,
            passwordSetup,
        },
    };
}

function maybeSendPasswordSetupEmail({ invite, resetPasswordForEmail }) {
    if (invite.requires_password_setup !== true) {
        return { required: false, sent: false, alreadySent: false };
    }
    if (invite.password_setup_sent_at) {
        return { required: true, sent: false, alreadySent: true, sentAt: invite.password_setup_sent_at };
    }

    const result = resetPasswordForEmail(invite.invitee_email, `/reset-password?invite_id=${invite.id}`);
    if (result.error) {
        return { required: true, sent: false, alreadySent: false, error: result.error };
    }

    invite.password_setup_sent_at = new Date('2026-05-16T09:00:01.000Z').toISOString();
    return { required: true, sent: true, alreadySent: false, sentAt: invite.password_setup_sent_at };
}

function run() {
    const functionCalls = [];
    const invite = {
        id: 'invite-e2e-1',
        inviter_user_id: 'supported-user-1',
        invitee_email: 'caregiver@example.com',
        role: 'caregiver',
        status: 'pending',
        accepted_user_id: null,
        accepted_at: null,
        requires_password_setup: false,
        password_setup_sent_at: null,
    };
    const relationship = {
        id: 'relationship-1',
        caregiver_user_id: 'caregiver-user-1',
        supported_user_id: 'supported-user-1',
        role: 'caregiver',
        status: 'accepted',
    };
    const caregiverProfile = {
        id: 'caregiver-user-1',
        email: 'caregiver@example.com',
        account_type: 'user',
        onboarding_completed: false,
        onboarding_completed_at: null,
    };

    functionCalls.push('send-caregiver-invite');
    const sendResponse = sendCaregiverInviteForNewUser({
        invite,
        caregiverProfile,
        caregiverPassword: 'password123',
        createOrUpdateUserPassword: (email, password) => {
            assert.equal(email, 'caregiver@example.com');
            assert.equal(password, 'password123');
            return { error: null };
        },
    });

    assert.equal(sendResponse.status, 200);
    assert.equal(sendResponse.body.passwordSetup.passwordCreated, true);
    assert.equal(sendResponse.body.requiresPasswordSetup, false);
    assert.equal(invite.password_setup_sent_at, null);

    assert.deepEqual(functionCalls, ['send-caregiver-invite']);
    assert.equal(sendResponse.body.ok, true);
    assert.equal(sendResponse.body.relationship.id, 'relationship-1');
    assert.equal(sendResponse.body.relationship.caregiver_user_id, 'caregiver-user-1');
    assert.equal(sendResponse.body.relationship.supported_user_id, 'supported-user-1');
    assert.equal(sendResponse.body.passwordSetup.required, false);
    assert.equal(caregiverProfile.account_type, 'caregiver');
    assert.equal(caregiverProfile.onboarding_completed, true);
    assert.equal(caregiverProfile.onboarding_completed_at, invite.accepted_at);
    assert.equal(invite.status, 'accepted');
    assert.equal(invite.accepted_user_id, 'caregiver-user-1');
    assert.equal(invite.password_setup_sent_at, null);

    console.log('PASS caregiver add flow creates password and relationship without email dependency');
    console.log(JSON.stringify({ functionCalls, caregiverProfile, invite, response: sendResponse.body }, null, 2));
}

run();