import 'package:dope_i_mine/data/local/local_body_double_store.dart';
import 'package:dope_i_mine/data/local/local_json_store.dart';
import 'package:dope_i_mine/data/repositories/body_double_repository_impl.dart';
import 'package:dope_i_mine/domain/body_double/body_double_session.dart';
import 'package:dope_i_mine/presentation/body_double/body_double_controller.dart';
import 'package:dope_i_mine/presentation/body_double/dopei_body_double_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Dope-i session screen exposes Phase 1 controls',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = await _controller();
    await controller.startDopeiSession(
      sessionType: BodyDoubleSessionType.quickStart,
      sessionLengthMinutes: 5,
      checkInIntervalMinutes: 1,
      currentStepText: 'Put one plate away',
      voiceEnabled: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          bodyDoubleControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(
          home: DopeiBodyDoubleSessionScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('body-double-current-step')),
        findsOneWidget);
    expect(find.text('Put one plate away'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('body-double-timer-label')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('body-double-step-done-button')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('body-double-speak-step-button')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('body-double-emergency-exit-button')),
        findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('body-double-overwhelmed-button')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('body-double-pause-resume-button')),
        findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('body-double-pause-resume-button')),
    );
    await tester.pump();
    expect(controller.state.activeSession!.status, BodyDoubleStatus.paused);
    expect(find.text('Resume session'), findsOneWidget);
  });
}

Future<BodyDoubleController> _controller() async {
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer();
  return BodyDoubleController(
    BodyDoubleRepositoryImpl(
      localStore: LocalBodyDoubleStore(
        store: LocalJsonStore('test.body_double.widget', preferences: prefs),
      ),
    ),
    container.read(providerContainerProvider),
  );
}

final providerContainerProvider = Provider<Ref>((ref) => ref);