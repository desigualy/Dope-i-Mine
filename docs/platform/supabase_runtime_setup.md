# Supabase Runtime Setup

## Required values
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

## Flutter run example
```bash
flutter run   --dart-define=SUPABASE_URL=https://YOURPROJECT.supabase.co   --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

## Preferred local build approach
Use `.env.json` with:
```bash
flutter run --dart-define-from-file=.env.json
```

## Backend steps
1. `supabase db push`
2. deploy functions:
   - create-task
   - breakdown-step
   - overwhelm-rescue
