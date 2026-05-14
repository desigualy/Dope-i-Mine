# Supabase Functions Deployment Guide

## Prerequisites
1. Install Supabase CLI: `npm install -g supabase`
2. Login to Supabase: `supabase login`
3. Link your project: `supabase link --project-ref ohdvpbzivjcrwsxadpnp`

## Database Setup
Before deploying functions, ensure the database tables exist:

### Option 1: Automatic (Recommended)
Run the migration script:
```bash
./tool/run_migrations.sh
```

### Option 2: Manual SQL
If the CLI is not available, run the SQL in `CREATE_TASK_TABLES.sql` in the Supabase SQL Editor:
1. Go to https://supabase.com/dashboard/project/ohdvpbzivjcrwsxadpnp/sql
2. Copy and paste the contents of `CREATE_TASK_TABLES.sql`
3. Click "Run"

## Deploy Functions
Run the deployment script:
```bash
./tool/deploy_supabase_functions.sh
```

Or deploy individually:
```bash
supabase functions deploy create-task
supabase functions deploy breakdown-step
supabase functions deploy overwhelm-rescue
supabase functions deploy send-caregiver-invite
```

## Function Overview

### create-task
- **Purpose**: AI-powered task breakdown for new task creation
- **Input**: `{ taskText: string, mode: string, energyLevel: string, stressLevel: string }`
- **Output**: `{ primarySteps: string[], minimumSteps: string[], category: string }`

### breakdown-step
- **Purpose**: Further breakdown of individual task steps into substeps
- **Input**: `{ stepText: string, mode: string, energyLevel: string, stressLevel: string }`
- **Output**: `{ substeps: { text: string }[] }`

### overwhelm-rescue
- **Purpose**: Provides supportive actions and overwhelm management suggestions
- **Input**: `{}` (empty body)
- **Output**: `{ showOnlyCurrentStep: boolean, supportiveAction: string }`

### send-caregiver-invite
- **Purpose**: Sends the email used to connect a caregiver/support account after a pending caregiver relationship is created.
- **Input**: `{ inviteId: string, targetUserEmail: string, role: string }`
- **Output**: `{ ok: true, mode: 'magic_link' | 'auth_invite', inviteId: string, role: string }`
- **Required secrets/env**: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`; optional `APP_BASE_URL` for the email redirect target.

## Testing
After deployment, test functions using:
```bash
supabase functions invoke create-task --data '{"taskText":"Clean the kitchen","mode":"balanced","energyLevel":"medium","stressLevel":"low"}'
```