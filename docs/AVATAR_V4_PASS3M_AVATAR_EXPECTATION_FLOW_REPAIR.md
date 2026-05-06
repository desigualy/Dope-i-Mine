# Avatar V4 Pass 3M — Avatar Expectation Flow Repair

The app route is now correct:

```text
voice setup -> identity -> avatar
```

The broad onboarding tests still expect `Avatar` immediately after one `Next`. This repair makes the tests step through the inserted identity page when needed:

```dart
if (find.text('Avatar').evaluate().isEmpty) {
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}
expect(find.text('Avatar'), findsOneWidget);
```

It also clears the remaining quote lint in the onboarding purge test.

## Apply

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\repair_avatar_v4_pass3m_avatar_expectation_flow.ps1
flutter analyze
flutter test
```
