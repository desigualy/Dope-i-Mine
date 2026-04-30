import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers.dart';

class OverwhelmState {
  const OverwhelmState({
    this.isActive = false,
    this.isLowDemandMode = false,
    this.showOnlyCurrentStep = false,
    this.useMinimumVersion = false,
    this.supportiveAction,
  });

  final bool isActive;
  final bool isLowDemandMode;
  final bool showOnlyCurrentStep;
  final bool useMinimumVersion;
  final String? supportiveAction;

  OverwhelmState copyWith({
    bool? isActive,
    bool? isLowDemandMode,
    bool? showOnlyCurrentStep,
    bool? useMinimumVersion,
    String? supportiveAction,
  }) {
    return OverwhelmState(
      isActive: isActive ?? this.isActive,
      isLowDemandMode: isLowDemandMode ?? this.isLowDemandMode,
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

  void activateOverwhelmMode() {
    state = state.copyWith(
      isActive: true,
      isLowDemandMode: true,
      showOnlyCurrentStep: true,
      useMinimumVersion: true,
      supportiveAction: 'Calm mode activated. Let\'s do just one tiny thing together.',
    );
  }

  void exitOverwhelmMode() {
    state = state.copyWith(
      isActive: false,
      isLowDemandMode: false,
      showOnlyCurrentStep: false,
      useMinimumVersion: false,
      supportiveAction: null,
    );
  }

  Future<void> requestRescue() async {
    // Immediate local activation for speed
    activateOverwhelmMode();

    if (_client == null) return;

    try {
      final result = await _client!.functions.invoke(
        'overwhelm-rescue',
        body: <String, dynamic>{},
      );
      final data = Map<String, dynamic>.from(result.data as Map);
      state = state.copyWith(
        supportiveAction: data['supportiveAction'] as String? ?? state.supportiveAction,
      );
    } catch (e) {
      // Fallback already handled by local activation
    }
  }

  void pauseSafely() {
    state = state.copyWith(
      supportiveAction: 'Paused safely. You can come back whenever you are ready.',
    );
  }
}
