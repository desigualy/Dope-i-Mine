$ErrorActionPreference = "Stop"

Write-Host "Repairing Avatar V3 Pass 1 after partial apply..."

# 1) Remove obsolete Avatar V2 renderer/test path. Old renderer is not fallback.
$removePaths = @(
  "lib\presentation\avatar_v2",
  "test\avatar_v2"
)

foreach ($path in $removePaths) {
  if (Test-Path $path) {
    Remove-Item -Recurse -Force $path
    Write-Host "Deleted $path"
  }
}

# 2) Guarantee pubspec dependencies are present.
$pubspecPath = "pubspec.yaml"
if (!(Test-Path $pubspecPath)) {
  throw "pubspec.yaml not found. Run this from the project root."
}

$lines = [System.Collections.Generic.List[string]]::new()
(Get-Content $pubspecPath) | ForEach-Object { [void]$lines.Add($_) }

function Has-LineMatching([string]$pattern) {
  foreach ($line in $lines) {
    if ($line -match $pattern) { return $true }
  }
  return $false
}

function Insert-Dependency([string]$dependencyLine) {
  if ($dependencyLine -match "^\s*([^:]+):") {
    $depName = $Matches[1].Trim()
    if (Has-LineMatching("^\s{2}$([regex]::Escape($depName))\s*:")) {
      return
    }
  }

  $dependenciesIndex = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^dependencies:\s*$") {
      $dependenciesIndex = $i
      break
    }
  }

  if ($dependenciesIndex -lt 0) {
    throw "dependencies: section not found in pubspec.yaml"
  }

  $insertAt = $dependenciesIndex + 1
  while ($insertAt -lt $lines.Count) {
    $line = $lines[$insertAt]
    if ($line -match "^[A-Za-z_][A-Za-z0-9_]*:\s*$") {
      break
    }
    if ($line -match "^dev_dependencies:\s*$") {
      break
    }
    $insertAt++
  }

  $lines.Insert($insertAt, $dependencyLine)
  Write-Host "Added dependency: $dependencyLine"
}

Insert-Dependency "  flutter_svg: ^2.0.17"
Insert-Dependency "  vector_graphics: ^1.1.15"

# 3) Guarantee assets/avatar_v3/ is declared under flutter/assets.
$content = ($lines -join "`n")

if ($content -notmatch "assets/avatar_v3/") {
  $flutterIndex = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^flutter:\s*$") {
      $flutterIndex = $i
      break
    }
  }

  if ($flutterIndex -lt 0) {
    [void]$lines.Add("")
    [void]$lines.Add("flutter:")
    [void]$lines.Add("  assets:")
    [void]$lines.Add("    - assets/avatar_v3/")
    Write-Host "Added flutter/assets section with assets/avatar_v3/"
  } else {
    $assetsIndex = -1
    for ($i = $flutterIndex + 1; $i -lt $lines.Count; $i++) {
      if ($lines[$i] -match "^[A-Za-z_][A-Za-z0-9_]*:\s*$") {
        break
      }
      if ($lines[$i] -match "^\s{2}assets:\s*$") {
        $assetsIndex = $i
        break
      }
    }

    if ($assetsIndex -lt 0) {
      $lines.Insert($flutterIndex + 1, "  assets:")
      $lines.Insert($flutterIndex + 2, "    - assets/avatar_v3/")
      Write-Host "Added flutter/assets with assets/avatar_v3/"
    } else {
      $lines.Insert($assetsIndex + 1, "    - assets/avatar_v3/")
      Write-Host "Added assets/avatar_v3/"
    }
  }
}

Set-Content -Path $pubspecPath -Value ($lines -join "`n") -NoNewline

# 4) Basic sanity output.
Write-Host ""
Write-Host "Repair complete."
Write-Host "Run:"
Write-Host "  flutter pub get"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
