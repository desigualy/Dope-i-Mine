import 'dart:developer';

import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

bool isAuthenticated() {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    debugPrint('isAuthenticated check: user=$user');
    return user != null;
  } catch (e) {
    debugPrint('isAuthenticated error: $e');
    return false;
  }
}
