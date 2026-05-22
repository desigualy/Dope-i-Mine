. "$PSScriptRoot\qa_common.ps1"
Assert-RepoRoot
Show-EnvironmentSummary
Invoke-Checked "flutter pub get" { flutter pub get }
Invoke-Checked "flutter analyze" { flutter analyze }
Invoke-Checked "flutter test" { flutter test }
