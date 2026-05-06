# Avatar V4 Pass 3I FlutterError Import Repair

`FlutterError` lives in:

```dart
package:flutter/foundation.dart
```

Pass 3I used `FlutterError` in the validator and test but only imported `services.dart`.

This repair adds:

```dart
import 'package:flutter/foundation.dart';
```

to:

```text
lib/avatar_engine_v4/runtime/avatar_rive_contract_validator.dart
test/avatar_v4/avatar_v4_rive_contract_validator_test.dart
```

## Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3i_flutter_error_import.ps1
flutter analyze
flutter test
```
