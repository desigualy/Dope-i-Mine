import 'package:flutter/foundation.dart';
import 'package:rive/rive.dart';

class AvatarRiveRuntimeInitializer {
  AvatarRiveRuntimeInitializer._();

  static Future<Object?>? _initialization;
  static bool _nativeInitializationEnabled = true;

  static Future<Object?> ensureInitialized() {
    if (!_nativeInitializationEnabled) {
      return Future<Object?>.value(null);
    }

    return _initialization ??= _initializeSafely();
  }

  static Future<Object?> _initializeSafely() async {
    try {
      await RiveFile.initialize();
      return null;
    } catch (error) {
      return error;
    }
  }

  @visibleForTesting
  static void setNativeInitializationEnabledForTesting(bool enabled) {
    _nativeInitializationEnabled = enabled;
    _initialization = null;
  }

  @visibleForTesting
  static void resetForTesting() {
    _nativeInitializationEnabled = true;
    _initialization = null;
  }
}
