param([switch]$SkipDbReset)
. "$PSScriptRoot\qa_common.ps1"
Assert-RepoRoot
Show-EnvironmentSummary
if (-not $SkipDbReset) {
  Invoke-Checked "npx supabase db reset" { npx supabase db reset }
} else {
  Write-Warn "Skipping npx supabase db reset because -SkipDbReset was provided."
}
$checks = @(
  "supabase/sql/body_double_phase3_rls_rpc_tests.sql",
  "supabase/sql/body_double_group_runtime_rls_tests.sql",
  "supabase/sql/body_double_moderation_retention_admin_tests.sql",
  "supabase/sql/body_double_moderation_admin_console_tests.sql",
  "supabase/sql/notification_runtime_rls_tests.sql",
  "supabase/sql/sync_runtime_rls_tests.sql",
  "supabase/sql/accessibility_preferences_rls_tests.sql"
)
foreach ($check in $checks) { Invoke-OptionalSql $check }
