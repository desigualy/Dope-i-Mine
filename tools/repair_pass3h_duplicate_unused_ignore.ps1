$ErrorActionPreference = "Stop"

Write-Host "Repairing duplicate unused_element ignore..."

$file = "lib\data\repositories\task_repository_impl.dart"

if (!(Test-Path $file)) {
  throw "Missing $file. Run this from the project root."
}

$content = Get-Content $file -Raw

# Keep the file-level ignore, remove the stale inline ignore added by the earlier script.
$content = $content -replace "(?m)^\s*//\s*ignore:\s*unused_element\s*`r?`n", ""

if ($content -notmatch "^// ignore_for_file:") {
  $content = "// ignore_for_file: unused_element`r`n" + $content
} elseif (($content -split "`r?`n", 2)[0] -notmatch "unused_element") {
  $firstLine = ($content -split "`r?`n", 2)[0]
  $updatedFirstLine = $firstLine.TrimEnd() + ", unused_element"
  $content = $updatedFirstLine + $content.Substring($firstLine.Length)
}

Set-Content -Path $file -Value $content -NoNewline

Write-Host "Duplicate unused_element ignore repaired."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
