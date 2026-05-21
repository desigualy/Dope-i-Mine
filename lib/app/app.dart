import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import '../presentation/settings/theme_controller.dart';

class DopeIMineApp extends ConsumerStatefulWidget {
  const DopeIMineApp({super.key});

  @override
  ConsumerState<DopeIMineApp> createState() => _DopeIMineAppState();
}

class _DopeIMineAppState extends ConsumerState<DopeIMineApp> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await ref.read(reminderServiceProvider).initialize();
    } catch (error) {
      debugPrint('Failed to initialize local notifications: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(syncAutoRunnerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Dope-i-Mine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
