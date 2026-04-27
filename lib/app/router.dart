import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/auth/login_screen.dart';
import '../presentation/auth/signup_screen.dart';
import '../presentation/branding/dope_i_intro_screen.dart';
import '../presentation/branding/pronunciation_setup_screen.dart';
import '../presentation/branding/skin_pack_shop_screen.dart';
import '../presentation/branding/voice_name_preview_screen.dart';
import '../presentation/caregiver/caregiver_assigned_routines_screen.dart';
import '../presentation/caregiver/caregiver_assign_routine_screen.dart';
import '../presentation/caregiver/caregiver_dashboard_screen.dart';
import '../presentation/caregiver/link_caregiver_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/onboarding/age_band_screen.dart';
import '../presentation/onboarding/assistant_name_screen.dart';
import '../presentation/onboarding/accessibility_screen.dart';
import '../presentation/onboarding/mode_selection_screen.dart';
import '../presentation/onboarding/onboarding_summary_screen.dart';
import '../presentation/onboarding/permissions_screen.dart';
import '../presentation/onboarding/sensory_preferences_screen.dart';
import '../presentation/onboarding/voice_setup_screen.dart';
import '../presentation/onboarding/voice_preferences_screen.dart';
import '../presentation/onboarding/welcome_screen.dart';
import '../presentation/progress/progress_screen.dart';
import '../presentation/reminders/reminder_settings_screen.dart';
import '../presentation/routines/routine_builder_screen.dart';
import '../presentation/routines/routine_list_screen.dart';
import '../presentation/routines/routine_run_screen.dart';
import '../presentation/settings/companion_screen.dart';
import '../presentation/settings/pronunciation_settings_screen.dart';
import '../presentation/settings/voice_profile_screen.dart';
import '../presentation/tasks/task_breakdown_screen.dart';
import '../presentation/tasks/task_input_screen.dart';
import '../presentation/tasks/task_summary_screen.dart';
import 'route_guard.dart';
import 'session_redirect.dart';

final GoRouter appRouter = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    final authenticated = isAuthenticated();
    final location = state.matchedLocation;
    debugPrint('Router redirect: authenticated=$authenticated, location=$location');
    return sessionRedirect(
      authenticated: authenticated,
      location: location,
    );
  },
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/branding/intro',
      builder: (_, state) => DopeIIntroScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
    GoRoute(
      path: '/branding/pronunciation',
      builder: (_, state) => PronunciationSetupScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
    GoRoute(path: '/branding/voice-preview', builder: (_, __) => const VoiceNamePreviewScreen()),
    GoRoute(path: '/branding/skins', builder: (_, __) => const SkinPackShopScreen()),
    GoRoute(
      path: '/onboarding/age-band',
      builder: (_, state) => AgeBandScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
    GoRoute(
      path: '/onboarding/assistant-name',
      builder: (_, state) => AssistantNameScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
    GoRoute(
      path: '/onboarding/mode',
      builder: (_, state) => ModeSelectionScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
    GoRoute(
      path: '/onboarding/accessibility',
      builder: (_, state) => AccessibilityScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
    GoRoute(
      path: '/onboarding/sensory',
      builder: (_, state) => SensoryPreferencesScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
    GoRoute(
      path: '/onboarding/permissions',
      builder: (_, state) => PermissionsScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
    GoRoute(
      path: '/onboarding/voice',
      builder: (_, state) => VoicePreferencesScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
    GoRoute(
      path: '/onboarding/voice-setup',
      builder: (_, state) => VoiceSetupScreen(
        returnToSummary: state.uri.queryParameters['return'] == 'summary',
      ),
    ),
    GoRoute(
      path: '/onboarding/summary',
      builder: (_, __) => const OnboardingSummaryScreen(),
    ),
    GoRoute(path: '/tasks/new', builder: (_, __) => const TaskInputScreen()),
    GoRoute(path: '/tasks/breakdown', builder: (_, __) => const TaskBreakdownScreen()),
    GoRoute(path: '/tasks/summary', builder: (_, __) => const TaskSummaryScreen()),
    GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
    GoRoute(path: '/routines', builder: (_, __) => const RoutineListScreen()),
    GoRoute(path: '/routines/new', builder: (_, __) => const RoutineBuilderScreen()),
    GoRoute(path: '/routines/run', builder: (_, __) => const RoutineRunScreen()),
    GoRoute(path: '/caregiver', builder: (_, __) => const CaregiverDashboardScreen()),
    GoRoute(path: '/caregiver/link', builder: (_, __) => const LinkCaregiverScreen()),
    GoRoute(path: '/caregiver/assign-routine', builder: (_, __) => const CaregiverAssignRoutineScreen()),
    GoRoute(path: '/caregiver/assigned-routines', builder: (_, __) => const CaregiverAssignedRoutinesScreen()),
    GoRoute(path: '/settings/voice', builder: (_, __) => const VoiceProfileScreen()),
    GoRoute(path: '/settings/companion', builder: (_, __) => const CompanionScreen()),
    GoRoute(path: '/settings/pronunciation', builder: (_, __) => const PronunciationSettingsScreen()),
    GoRoute(path: '/settings/reminders', builder: (_, __) => const ReminderSettingsScreen()),
  ],
);
