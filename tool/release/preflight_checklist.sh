#!/usr/bin/env bash
set -euo pipefail

echo "== Dope-i-Mine Preflight Checklist =="

echo "[1/6] flutter pub get"
flutter pub get

echo "[2/6] dart format check"
dart format --output=none --set-exit-if-changed .

echo "[3/6] flutter analyze"
flutter analyze

echo "[4/6] flutter test"
flutter test

echo "[5/6] Reminder: verify .env.json exists"
if [ ! -f .env.json ]; then
  echo "WARNING: .env.json not found"
else
  echo ".env.json found"
fi

echo "[6/6] Reminder: verify Supabase CLI is installed"
if command -v supabase >/dev/null 2>&1; then
  supabase --version
else
  echo "WARNING: Supabase CLI not found"
fi

echo "Preflight complete."
