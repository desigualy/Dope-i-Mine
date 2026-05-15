$ErrorActionPreference = 'Stop'

$pathsToRemove = @(
  'assets/avatar_v3',
  'lib/domain/avatar_v3',
  'lib/data/local/local_avatar_v3_asset_pack_store.dart',
  'lib/data/local/local_avatar_v3_inventory_store.dart',
  'lib/data/local/local_avatar_v3_pending_sync_store.dart',
  'lib/data/local/local_avatar_v3_profile_store.dart',
  'lib/data/repositories/avatar_v3_repository.dart',
  'lib/data/repositories/offline_first_avatar_v3_repository.dart',
  'lib/data/repositories/supabase_avatar_v3_repository.dart',
  'test/avatar_v3',
  'supabase/sql/avatar_v3_tables.sql'
)

foreach ($path in $pathsToRemove) {
  if (Test-Path $path) {
    Remove-Item $path -Recurse -Force
  }
}

Write-Host 'Avatar V3 purge complete. Run flutter analyze and flutter test next.'
