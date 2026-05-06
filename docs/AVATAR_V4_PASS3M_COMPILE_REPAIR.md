# Avatar V4 Pass 3M Compile Repair

Pass 3M added identity fields to `ProfileRepositoryImpl.saveOnboardingProfile`.

The onboarding fake repository in:

```text
test/onboarding/onboarding_flow_test.dart
```

also extends `ProfileRepositoryImpl`, so its override must include the same optional named parameters:

```dart
String? sexAtBirth,
String? genderIdentity,
String? pronouns,
String? customPronouns,
```

This repair also cleans the single-quote lint in:

```text
test/avatar_v4/avatar_v4_onboarding_purge_test.dart
```

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3m_compile.ps1
flutter analyze
flutter test
```
