import 'dart:io';

import 'package:dope_i_mine/presentation/settings/advanced_security_screen.dart';
import 'package:dope_i_mine/presentation/settings/ai_personality_screen.dart';
import 'package:dope_i_mine/presentation/settings/appearance_settings_screen.dart';
import 'package:dope_i_mine/presentation/settings/automation_shortcuts_screen.dart';
import 'package:dope_i_mine/presentation/settings/avatar_tweaks_screen.dart';
import 'package:dope_i_mine/presentation/settings/data_privacy_screen.dart';
import 'package:dope_i_mine/presentation/settings/developer_tools_screen.dart';
import 'package:dope_i_mine/presentation/settings/family_multiuser_screen.dart';
import 'package:dope_i_mine/presentation/settings/gamification_settings_screen.dart';
import 'package:dope_i_mine/presentation/settings/integrations_screen.dart';
import 'package:dope_i_mine/presentation/settings/storage_performance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Full-system UI/UX QA smoke suite', () {
    late Directory tempRoot;

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp('dope_ui_qa_');
      _installFakePathProvider(tempRoot);
    });

    tearDown(() async {
      await tempRoot.delete(recursive: true);
    });

    final screenCases = <_ScreenQaCase>[
      _ScreenQaCase(
        name: 'appearance settings',
        screen: const AppearanceSettingsScreen(),
        requiredTexts: const <String>[
          'Theming & Appearance',
          'Dyslexia-Friendly Font',
          'Save Changes',
        ],
        expectedIcons: const <IconData>[Icons.font_download_rounded],
      ),
      _ScreenQaCase(
        name: 'AI personality settings',
        screen: const AiPersonalityScreen(),
        requiredTexts: const <String>[
          'Advanced Reasoning Model',
          'Save Changes',
        ],
        expectedIcons: const <IconData>[Icons.psychology_rounded],
      ),
      _ScreenQaCase(
        name: 'gamification settings',
        screen: const GamificationSettingsScreen(),
        requiredTexts: const <String>[
          'Show XP & Level Progress',
          'Visual Celebrations',
          'Save Changes',
        ],
        expectedIcons: const <IconData>[Icons.star_rounded],
      ),
      _ScreenQaCase(
        name: 'integrations settings',
        screen: const IntegrationsScreen(),
        requiredTexts: const <String>[
          'Auto-export Routines to Calendar',
          'Apple Health',
          'Save Changes',
        ],
        expectedIcons: const <IconData>[Icons.calendar_month_rounded],
      ),
      _ScreenQaCase(
        name: 'automation and shortcuts settings',
        screen: const AutomationShortcutsScreen(),
        requiredTexts: const <String>[
          'Siri Shortcuts',
          'Add Webhook',
          'Save Changes',
        ],
        expectedIcons: const <IconData>[Icons.mic_rounded],
      ),
      _ScreenQaCase(
        name: 'family multi-user settings',
        screen: const FamilyMultiuserScreen(),
        requiredTexts: const <String>[
          'Family & Multi-User',
          'Enable Quick Profile Switch',
          'No signed-in profile found',
          'Save Changes',
        ],
        expectedIcons: const <IconData>[Icons.switch_account_rounded],
      ),
      _ScreenQaCase(
        name: 'storage and performance settings',
        screen: const StoragePerformanceScreen(),
        requiredTexts: const <String>[
          'Storage & Performance',
          'Storage Breakdown',
          'Battery Saver Mode',
        ],
        expectedIcons: const <IconData>[Icons.battery_saver_rounded],
      ),
      _ScreenQaCase(
        name: 'avatar tweaks settings',
        screen: const AvatarTweaksScreen(),
        requiredTexts: const <String>[
          'Avatar & Companion Tweaks',
          'High Fidelity',
          'Idle Animations',
          'Save Changes',
        ],
        expectedIcons: const <IconData>[Icons.hd_rounded],
      ),
      _ScreenQaCase(
        name: 'advanced security settings',
        screen: const AdvancedSecurityScreen(),
        requiredTexts: const <String>[
          'Advanced Security',
          'App Lock (Biometrics/PIN)',
          'Active Sessions',
          'Log out of all other sessions',
        ],
        expectedIcons: const <IconData>[Icons.fingerprint_rounded],
      ),
      _ScreenQaCase(
        name: 'data privacy settings',
        screen: const DataPrivacyScreen(),
        requiredTexts: const <String>[
          'Data & Privacy',
          'Clear Local Cache',
          'Export My Data',
          'Delete Account',
        ],
        expectedIcons: const <IconData>[Icons.cleaning_services_rounded],
      ),
      _ScreenQaCase(
        name: 'developer tools settings',
        screen: const DeveloperToolsScreen(),
        requiredTexts: const <String>[
          'Developer Tools',
          'Export Debug Logs',
          'Verbose Sync State',
          'Clear API Cache',
        ],
        expectedIcons: const <IconData>[Icons.bug_report_rounded],
      ),
    ];

    for (final screenCase in screenCases) {
      testWidgets('${screenCase.name} renders required UI and controls respond',
          (tester) async {
        await _setLargeViewport(tester);
        await _pumpQaScreen(tester, screenCase.screen);

        for (final text in screenCase.requiredTexts) {
          await _expectTextReachable(tester, text,
              reason: '${screenCase.name} missing "$text"');
        }
        for (final icon in screenCase.expectedIcons) {
          expect(find.byIcon(icon), findsWidgets,
              reason: '${screenCase.name} missing icon $icon');
        }

        await _exerciseVisibleControls(tester);

        expect(tester.takeException(), isNull,
            reason: '${screenCase.name} threw during QA smoke interactions');
      });
    }

    testWidgets('destructive privacy dialog opens and cancel closes safely',
        (tester) async {
      await _setLargeViewport(tester);
      await _pumpQaScreen(tester, const DataPrivacyScreen());

      await _expectTextReachable(tester, 'Delete Account');
      await tester.tap(find.text('Delete Account'));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Delete Account?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Delete Account?'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Static full-system route and UI contract QA', () {
    test('all settings routes are wired and expose concrete screen builders',
        () {
      final router = File('lib/app/router.dart').readAsStringSync();
      const expectedRoutes = <String>[
        '/settings',
        '/settings/setup',
        '/settings/voice',
        '/settings/notifications',
        '/settings/companion',
        '/settings/pronunciation',
        '/settings/reminders',
        '/settings/data-privacy',
        '/settings/developer-tools',
        '/settings/ai-personality',
        '/settings/gamification',
        '/settings/advanced-security',
        '/settings/appearance',
        '/settings/storage-performance',
        '/settings/avatar-tweaks',
        '/settings/integrations',
        '/settings/automation-shortcuts',
        '/settings/family-multiuser',
      ];

      for (final route in expectedRoutes) {
        expect(router, contains("path: '$route'"),
            reason: 'Missing route $route');
      }
    });

    test('primary feature routes remain wired for full-app navigation QA', () {
      final router = File('lib/app/router.dart').readAsStringSync();
      const expectedRoutes = <String>[
        '/',
        '/login',
        '/signup',
        '/home',
        '/tasks/new',
        '/tasks/breakdown',
        '/tasks/summary',
        '/body-double/start',
        '/body-double/session',
        '/body-double/summary',
        '/progress',
        '/routines',
        '/caregiver',
        '/avatar/customize',
        '/notifications',
        '/feedback/beta',
      ];

      for (final route in expectedRoutes) {
        expect(router, contains("path: '$route'"),
            reason: 'Missing route $route');
      }
    });

    test('settings hub exposes navigable rows with leading and trailing icons',
        () {
      final settings = File('lib/presentation/settings/settings_screen.dart')
          .readAsStringSync();
      final navigableRows =
          RegExp(r'ListTile\([\s\S]*?onTap: \(\) => context\.(?:push|go)\(')
              .allMatches(settings)
              .toList(growable: false);

      expect(navigableRows.length, greaterThanOrEqualTo(20));
      for (final row in navigableRows) {
        final block = row.group(0)!;
        expect(block, contains('leading: const Icon'),
            reason: 'Navigable settings row missing leading icon: $block');
        expect(block, contains('trailing: const Icon'),
            reason: 'Navigable settings row missing trailing icon: $block');
      }
    });
  });
}

Future<void> _setLargeViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpQaScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        home: screen,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _expectTextReachable(
  WidgetTester tester,
  String text, {
  String? reason,
}) async {
  final finder = find.text(text);
  if (finder.evaluate().isNotEmpty) {
    await tester.pump(const Duration(milliseconds: 150));
    await tester.ensureVisible(finder.first);
    return;
  }

  for (var i = 0; i < 12; i++) {
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -350));
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 150));
      await tester.ensureVisible(finder.first);
      return;
    }
  }

  expect(finder, findsWidgets, reason: reason);
}

Future<void> _exerciseVisibleControls(WidgetTester tester) async {
  for (final finder in <Finder>[
    find.byType(SwitchListTile),
    find.byType(RadioListTile<String>),
    find.byType(RadioListTile<int>),
  ]) {
    final count = finder.evaluate().length;
    for (var index = 0; index < count; index++) {
      final item = finder.at(index);
      await tester.ensureVisible(item);
      await tester.tap(item);
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  final saveButton = find.text('Save Changes');
  if (saveButton.evaluate().isNotEmpty) {
    await tester.ensureVisible(saveButton.last);
    await tester.tap(saveButton.last);
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void _installFakePathProvider(Directory root) {
  PathProviderPlatform.instance = _FakePathProviderPlatform(root.path);
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.rootPath);

  final String rootPath;

  @override
  Future<String?> getTemporaryPath() async => _ensure('cache');

  @override
  Future<String?> getApplicationDocumentsPath() async => _ensure('documents');

  @override
  Future<String?> getApplicationSupportPath() async => _ensure('support');

  String _ensure(String child) {
    final directory = Directory('$rootPath${Platform.pathSeparator}$child')
      ..createSync(recursive: true);
    File('${directory.path}${Platform.pathSeparator}qa.bin')
        .writeAsBytesSync(<int>[1, 2, 3, 4]);
    return directory.path;
  }
}

class _ScreenQaCase {
  const _ScreenQaCase({
    required this.name,
    required this.screen,
    required this.requiredTexts,
    required this.expectedIcons,
  });

  final String name;
  final Widget screen;
  final List<String> requiredTexts;
  final List<IconData> expectedIcons;
}
