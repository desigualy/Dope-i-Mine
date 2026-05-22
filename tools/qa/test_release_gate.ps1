param([switch]$BuildAppBundle)
. "$PSScriptRoot\qa_common.ps1"
Assert-RepoRoot
Show-EnvironmentSummary
Invoke-Checked "flutter clean" { flutter clean }
Invoke-Checked "flutter pub get" { flutter pub get }
Invoke-Checked "flutter analyze" { flutter analyze }
Invoke-Checked "flutter test" { flutter test }
Invoke-Checked "flutter build apk --debug" { flutter build apk --debug }
Invoke-Checked "flutter build apk --release" { flutter build apk --release }
if ($BuildAppBundle) {
  Invoke-Checked "flutter build appbundle --release" { flutter build appbundle --release }
}
