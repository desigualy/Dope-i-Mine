#!/usr/bin/env bash
set -euo pipefail

echo "Running Flutter dependency restore..."
flutter pub get

echo "Running formatter check..."
dart format --output=none --set-exit-if-changed .

echo "Running analyzer..."
flutter analyze

echo "Running tests..."
flutter test

echo "Building iOS archive with dart defines..."
flutter build ipa --release   --dart-define-from-file=.env.json

echo "iOS build complete."
