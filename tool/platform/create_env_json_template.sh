#!/usr/bin/env bash
set -euo pipefail

cat > .env.json <<'JSON'
{
  "SUPABASE_URL": "https://YOURPROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_PUBLIC_ANON_KEY"
}
JSON

echo ".env.json template created."
