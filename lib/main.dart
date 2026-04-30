import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/utils/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const rawSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  final supabaseUrl = normalizeSupabaseUrl(rawSupabaseUrl);

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } else {
    debugPrint(
      'Dope-i-Mine: Supabase not initialized. '
      'Provide --dart-define=SUPABASE_URL and --dart-define=SUPABASE_ANON_KEY.',
    );
  }

  runApp(const ProviderScope(child: DopeIMineApp()));
}
