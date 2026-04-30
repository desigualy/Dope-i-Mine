import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/companion/dopei_mood.dart';

class AvatarState {
  const AvatarState({
    this.mood = DopeiMood.neutral,
  });

  final DopeiMood mood;

  AvatarState copyWith({DopeiMood? mood}) {
    return AvatarState(mood: mood ?? this.mood);
  }
}

final avatarControllerProvider =
    StateNotifierProvider<AvatarController, AvatarState>((ref) {
  return AvatarController();
});

class AvatarController extends StateNotifier<AvatarState> {
  AvatarController() : super(const AvatarState());

  void setMood(DopeiMood mood) {
    state = state.copyWith(mood: mood);
  }

  void reset() {
    state = const AvatarState();
  }
}
