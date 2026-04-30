import 'package:flutter/foundation.dart';

import '../../data/avatar/realistic_avatar_generator.dart';
import '../../domain/avatar/avatar_enums.dart';
import '../../domain/avatar/realistic_avatar_generation_request.dart';
import '../../domain/avatar/user_avatar_profile.dart';

@immutable
class RealisticAvatarState {
  const RealisticAvatarState({
    required this.profile,
    this.loading = false,
    this.errorMessage,
  });

  final UserAvatarProfile profile;
  final bool loading;
  final String? errorMessage;

  RealisticAvatarState copyWith({
    UserAvatarProfile? profile,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RealisticAvatarState(
      profile: profile ?? this.profile,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class RealisticAvatarController extends ChangeNotifier {
  RealisticAvatarController({
    required RealisticAvatarGenerator generator,
    UserAvatarProfile initialProfile = UserAvatarProfile.defaultAdult,
  })  : _generator = generator,
        _state = RealisticAvatarState(profile: initialProfile);

  final RealisticAvatarGenerator _generator;
  RealisticAvatarState _state;

  RealisticAvatarState get state => _state;

  void updateProfile(UserAvatarProfile profile) {
    _state = _state.copyWith(profile: profile, clearError: true);
    notifyListeners();
  }

  Future<void> generateRealisticAvatar() async {
    final profile = _state.profile.copyWith(
      renderMode: AvatarRenderMode.ultraRealistic,
      realismLevel: AvatarRealismLevel.ultraRealistic,
    );

    _state = _state.copyWith(profile: profile, loading: true, clearError: true);
    notifyListeners();

    try {
      final request = RealisticAvatarGenerationRequest.fromProfile(profile);
      final result = await _generator.generate(request);

      _state = _state.copyWith(
        loading: false,
        profile: profile.copyWith(
          generatedImageUrl: result.imageUrl,
          localImagePath: result.localPath,
        ),
      );
      notifyListeners();
    } on RealisticAvatarGenerationException catch (error) {
      _state = _state.copyWith(loading: false, errorMessage: error.message);
      notifyListeners();
    } catch (_) {
      _state = _state.copyWith(
        loading: false,
        errorMessage: 'Avatar generation failed. Please try again.',
      );
      notifyListeners();
    }
  }

  void clearGeneratedAvatar() {
    _state = _state.copyWith(
      profile: _state.profile.copyWith(
        clearGeneratedImageUrl: true,
        clearLocalImagePath: true,
        renderMode: AvatarRenderMode.premiumPortrait,
        realismLevel: AvatarRealismLevel.soft,
      ),
      clearError: true,
    );
    notifyListeners();
  }
}
