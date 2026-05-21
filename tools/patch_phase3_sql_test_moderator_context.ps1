$ErrorActionPreference = "Stop"

$path = "supabase/sql/body_double_phase3_rls_rpc_tests.sql"

if (-not (Test-Path $path)) {
  throw "Could not find $path. Run this from the repo root."
}

$text = Get-Content -Raw -Path $path

$needle = @'
  if not exists (
    select 1 from public.body_double_message_moderation_events e
    where e.session_id = text_session_id
      and e.sender_id = adult_a
      and e.report_id = linked_report_id
      and e.action = 'reported'
  ) then
'@

$replacement = @'
  -- Moderation events are intentionally moderator-only under RLS.
  -- adult_a is seeded as the local verification moderator, so switch
  -- to that auth context before asserting the reported moderation row.
  perform set_config('request.jwt.claim.sub', adult_a::text, true);

  if not exists (
    select 1 from public.body_double_message_moderation_events e
    where e.session_id = text_session_id
      and e.sender_id = adult_a
      and e.report_id = linked_report_id
      and e.action = 'reported'
  ) then
'@

if ($text.Contains($replacement)) {
  Write-Host "Patch already applied."
  exit 0
}

if (-not $text.Contains($needle)) {
  throw "Expected SQL block not found. The file may already have changed."
}

$text = $text.Replace($needle, $replacement)
Set-Content -Path $path -Value $text -NoNewline -Encoding UTF8

Write-Host "Patched $path"
