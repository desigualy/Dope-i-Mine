$ErrorActionPreference = "Stop"

$path = "supabase/sql/body_double_phase3_rls_rpc_tests.sql"

if (-not (Test-Path $path)) {
  throw "Could not find $path. Run this from the repo root."
}

$resolved = (Resolve-Path $path).Path
$sql = [System.IO.File]::ReadAllText($resolved)

$sql = $sql.TrimStart([char]0xFEFF)
if ($sql.StartsWith("ï»¿")) {
  $sql = $sql.Substring(3)
}

if ($sql -notmatch "Moderation events are intentionally moderator-only under RLS") {
  $pattern = "(?s)(\s*)if not exists \(\s*select 1 from public\.body_double_message_moderation_events e\s*where e\.session_id = text_session_id\s*and e\.sender_id = adult_a\s*and e\.report_id = linked_report_id\s*and e\.action = 'reported'\s*\) then"
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
  $newSql = [regex]::Replace($sql, $pattern, $replacement, 1)
  if ($newSql -eq $sql) {
    throw "Could not patch reported moderation-event context. Check the reported-event block manually."
  }
  $sql = $newSql
}

$runtimeMarker = @'
  -- Phase 3 runtime/RLS test intentionally stops before admin retention cleanup.
  -- Moderation retention is covered by supabase/sql/body_double_moderation_retention_admin_tests.sql.
'@

if ($sql -notmatch "Phase 3 runtime/RLS test intentionally stops before admin retention cleanup") {
  $patterns = @(
    "(?s)\s*-- Retention cleanup must be tested with its own controlled aged fixture\..*?(?=\s*perform set_config\('request\.jwt\.claim\.sub', adult_a::text, true\);\s*perform public\.body_double_presence_heartbeat)",
    "(?s)\s*perform set_config\('request\.jwt\.claim\.sub', adult_a::text, true\);\s*update public\.body_double_message_moderation_events\s*set created_at = now\(\) - interval '31 days'\s*where message_id = text_message_id;.*?(?=\s*perform set_config\('request\.jwt\.claim\.sub', adult_a::text, true\);\s*perform public\.body_double_presence_heartbeat)",
    "(?s)\s*create or replace function public\.__phase3_insert_moderation_retention_fixture.*?(?=\s*perform set_config\('request\.jwt\.claim\.sub', adult_a::text, true\);\s*perform public\.body_double_presence_heartbeat)"
  )

  $patched = $false
  foreach ($pattern in $patterns) {
    $newSql = [regex]::Replace($sql, $pattern, "`r`n$runtimeMarker`r`n", 1)
    if ($newSql -ne $sql) {
      $sql = $newSql
      $patched = $true
      break
    }
  }

  if (-not $patched) {
    throw "Could not find/remove retention cleanup block. Search for cleanup_body_double_moderation_retention in the SQL file."
  }
}

if ($sql -match "Phase 3D: Group Matching Verification") {
  $groupPattern = "(?s)\s*-- Phase 3D: Group Matching Verification.*?(?=\s*-- Phase 3F: Reliability Penalty Verification)"
  $twoPerson = @'

  -- Phase 3D/3E: two-person random matching is the current supported runtime.
  -- Group matching belongs to a later phase and must not be required here.
  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  queue_adult_a := public.enter_random_body_double_queue(
    'focusSprint',
    'admin',
    25,
    'presetSignals',
    'private'
  );

  perform set_config('request.jwt.claim.sub', adult_c::text, true);
  restriction_id := public.enter_random_body_double_queue(
    'focusSprint',
    'admin',
    25,
    'presetSignals',
    'private'
  );

  perform set_config('request.jwt.claim.sub', adult_a::text, true);
  matched_session_id := public.find_body_double_match(queue_adult_a);

  if matched_session_id is null then
    raise exception 'Expected compatible adults to match in two-person random session';
  end if;

  if (
    select count(*)
    from public.body_double_participants
    where session_id = matched_session_id
  ) != 2 then
    raise exception 'Expected exactly 2 participants in Phase 3D/3E random session';
  end if;

'@
  $newSql = [regex]::Replace($sql, $groupPattern, $twoPerson, 1)
  if ($newSql -eq $sql) {
    throw "Could not replace stale group-matching block."
  }
  $sql = $newSql
}

$sql = [regex]::Replace($sql, "(?m)^\s*retention_event_id uuid;\s*\r?\n", "")

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($resolved, $sql, $utf8NoBom)

Write-Host "Patched $path"
Select-String -Path $path -Pattern "moderator-only|runtime/RLS test intentionally|Group Matching Verification|cleanup_body_double_moderation_retention|retention_event_id" -Context 0,0
