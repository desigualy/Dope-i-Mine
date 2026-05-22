. "$PSScriptRoot\qa_common.ps1"
Assert-RepoRoot
Show-EnvironmentSummary
$tests = @(
  "integration_test/app_boot_flow_test.dart",
  "integration_test/onboarding_flow_test.dart",
  "integration_test/task_breakdown_flow_test.dart",
  "integration_test/caregiver_flow_test.dart",
  "integration_test/body_double_flow_test.dart",
  "integration_test/notifications_flow_test.dart",
  "integration_test/offline_sync_flow_test.dart",
  "integration_test/accessibility_flow_test.dart"
)
foreach ($test in $tests) { Invoke-OptionalFlutterTest $test }
