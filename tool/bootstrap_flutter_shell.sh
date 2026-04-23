#!/usr/bin/env bash
set -euo pipefail

echo "== Dope-i-Mine Flutter shell bootstrap =="

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed or not on PATH."
  exit 1
fi

echo "Backing up core project folders..."
mkdir -p .bootstrap_backup
cp -R lib .bootstrap_backup/lib
cp -R assets .bootstrap_backup/assets || true
cp -R test .bootstrap_backup/test || true
cp pubspec.yaml .bootstrap_backup/pubspec.yaml
cp analysis_options.yaml .bootstrap_backup/analysis_options.yaml || true

echo "Generating missing native Flutter host files..."
flutter create . --platforms=android,ios

echo "Restoring project source of truth..."
rm -rf lib
cp -R .bootstrap_backup/lib lib

rm -rf assets
cp -R .bootstrap_backup/assets assets || true

rm -rf test
cp -R .bootstrap_backup/test test || true

cp .bootstrap_backup/pubspec.yaml pubspec.yaml
cp .bootstrap_backup/analysis_options.yaml analysis_options.yaml || true

echo "Running flutter pub get..."
flutter pub get

echo "Shell bootstrap complete."
echo "Next steps:"
echo "  flutter analyze"
echo "  flutter test"
echo "  flutter run --dart-define-from-file=.env.json"
