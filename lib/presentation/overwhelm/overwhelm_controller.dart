import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers.dart';

class OverwhelmState {
  const OverwhelmState({
    this.showOnlyCurrentStep = false,
    this.useMinimumVersion = false,
    this.supportiveAction,
  });

  final bool showOnlyCurrentStep;
  final bool useMinimumVersion;
  final String? supportiveAction;

  OverwhelmState copyWith({
    bool? showOnlyCurrentStep,
    bool? useMinimumVersion,
    String? supportiveAction,
  }) {
    return OverwhelmState(
      showOnlyCurrentStep: showOnlyCurrentStep ?? this.showOnlyCurrentStep,
      useMinimumVersion: useMinimumVersion ?? this.useMinimumVersion,
      supportiveAction: supportiveAction ?? this.supportiveAction,
    );
  }
}

final overwhelmControllerProvider =
    StateNotifierProvider<OverwhelmController, OverwhelmState>((ref) {
  return OverwhelmController(ref.watch(supabaseProvider));
});

class OverwhelmController extends StateNotifier<OverwhelmState> {
  OverwhelmController(this._client) : super(const OverwhelmState());

  final SupabaseClient? _client;

  Future<void> requestRescue() async {
    if (_client == null) {
      state = state.copyWith(
        showOnlyCurrentStep: true,
        useMinimumVersion: true,
        supportiveAction: 'Only do the smallest version right now.',
      );
      return;
    }
    final result = await _client.functions.invoke(
      'overwhelm-rescue',
      body: <String, dynamic>{},
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    state = state.copyWith(
      showOnlyCurrentStep: data['showOnlyCurrentStep'] as bool? ?? true,
      useMinimumVersion: true,
      supportiveAction: data['supportiveAction'] as String?,
    );
  }

  void pauseSafely() {
    state = state.copyWith(
      supportiveAction: 'Paused safely. You can come back later.',
    );
  }
}
