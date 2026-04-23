from pathlib import Path

REQUIRED = [
    'pubspec.yaml',
    'lib/main.dart',
    'lib/app/app.dart',
    'lib/app/router.dart',
    'lib/providers.dart',
    'supabase/migrations',
    'supabase/functions',
    'tool/bootstrap_flutter_shell.sh',
]

OPTIONAL_PLATFORM = [
    'android/build.gradle',
    'android/settings.gradle',
    'android/app/build.gradle',
    'ios/Podfile',
    'ios/Runner.xcodeproj',
]

root = Path(__file__).resolve().parent.parent

print('== Required project files ==')
for rel in REQUIRED:
    p = root / rel
    print(f'[{ "OK" if p.exists() else "MISSING" }] {rel}')

print('\n== Native platform shell status ==')
for rel in OPTIONAL_PLATFORM:
    p = root / rel
    print(f'[{ "OK" if p.exists() else "MISSING" }] {rel}')
