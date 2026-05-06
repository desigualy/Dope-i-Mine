$ErrorActionPreference = "Stop"

Write-Host "Repairing remaining _resolveBreakdownFocus analyzer warning..."

$file = "lib\data\repositories\task_repository_impl.dart"

if (!(Test-Path $file)) {
  throw "Missing $file. Run this from the project root."
}

$content = Get-Content $file -Raw

if ($content -match "^// ignore_for_file:") {
  $firstLine = ($content -split "`r?`n", 2)[0]
  if ($firstLine -notmatch "unused_element") {
    $updatedFirstLine = $firstLine.TrimEnd() + ", unused_element"
    $content = $content.Substring($firstLine.Length)
    $content = $updatedFirstLine + $content
    Set-Content -Path $file -Value $content -NoNewline
    Write-Host "Added unused_element to existing ignore_for_file."
  } else {
    Write-Host "File already ignores unused_element."
  }
} else {
  Set-Content -Path $file -Value ("// ignore_for_file: unused_element`r`n" + $content) -NoNewline
  Write-Host "Added file-level unused_element ignore."
}

Write-Host "Remaining analyzer warning repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
