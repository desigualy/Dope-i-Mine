. "$PSScriptRoot\qa_common.ps1"
Assert-RepoRoot
Show-EnvironmentSummary
Invoke-Checked "flutter build apk --debug" { flutter build apk --debug }
