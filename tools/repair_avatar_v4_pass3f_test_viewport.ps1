$ErrorActionPreference = "Stop"

Write-Host "Repairing Avatar V4 Pass 3F customizer test viewport..."

$file = "test\avatar_v4\avatar_v4_customizer_service_wiring_test.dart"

if (!(Test-Path $file)) {
  throw "Missing $file. Run this from the project root."
}

$content = Get-Content $file -Raw

$old = @'
  testWidgets('customizer uses injected online/user/service providers',
      (tester) async {
    final service = _NeverCalledReferenceImageService();
'@

$new = @'
  testWidgets('customizer uses injected online/user/service providers',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = _NeverCalledReferenceImageService();
'@

if ($content.Contains($new)) {
  Write-Host "Viewport repair already present."
} elseif ($content.Contains($old)) {
  $content = $content.Replace($old, $new)
  Set-Content -Path $file -Value $content -NoNewline
  Write-Host "Patched customizer service wiring test viewport."
} else {
  throw "Could not find expected test block in $file"
}

Write-Host "Avatar V4 Pass 3F viewport repair complete."
Write-Host "Run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
