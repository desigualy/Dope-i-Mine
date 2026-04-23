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

echo "Building Android app bundle with dart defines..."
flutter build appbundle --release   --dart-define-from-file=.env.json

echo "Android build complete."
