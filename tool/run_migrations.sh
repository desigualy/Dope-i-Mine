#!/usr/bin/env bash
set -euo pipefail

echo "Checking Supabase CLI..."
if ! command -v supabase &> /dev/null; then
    echo "Supabase CLI not found. Installing via npm..."
    npm install -g supabase
fi

supabase --version

echo "Linking to Supabase project..."
supabase link --project-ref ohdvpbzivjcrwsxadpnp

echo "Pushing database migrations..."
supabase db push

echo "Migrations applied successfully!"
