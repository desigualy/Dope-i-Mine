#!/usr/bin/env bash
set -euo pipefail

echo "Checking Supabase CLI..."
if ! command -v supabase &> /dev/null; then
    echo "Supabase CLI not found. Installing via npm..."
    npm install -g supabase
fi

supabase --version

echo "Deploying Dope-i-Mine edge functions..."
supabase functions deploy create-task
supabase functions deploy breakdown-step
supabase functions deploy overwhelm-rescue

echo "Functions deployed successfully!"
