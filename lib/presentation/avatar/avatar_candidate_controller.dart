import 'package:flutter/foundation.dart';

import '../../data/avatar/avatar_batch_generator.dart';
import '../../domain/avatar/avatar_generation_batch_request.dart';
import '../../domain/avatar/avatar_generation_batch_result.dart';
import '../../domain/avatar/avatar_generation_candidate.dart';
import '../../domain/avatar/avatar_seed.dart';
import '../../domain/avatar/avatar_style_preset.dart';
import '../../domain/avatar/avatar_variation_strength.dart';
import '../../domain/avatar/user_avatar_profile.dart';

@immutable
class AvatarCandidateState {
  const AvatarCandidateState({
    required this.profile,
    this.loading = false,
    this.errorMessage,
    this.result,
    this.selectedCandidate,
    this.stylePreset = AvatarStylePreset.semiRealisticPremium,
    this.variationStrength = AvatarVariationStrength.medium,
    this.seed,
  });

  final UserAvatarProfile profile;
  final bool loading;
  final String? errorMessage;
  final AvatarGenerationBatchResult? result;
  final AvatarGenerationCandidate? selectedCandidate;
  final AvatarStylePreset stylePreset;
  final AvatarVariationStrength variationStrength;
  final AvatarSeed? seed;

  AvatarCandidateState copyWith({
    UserAvatarProfile? profile,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    AvatarGenerationBatchResult? result,
    bool clearResult = false,
    AvatarGenerationCandidate? selectedCandidate,
    bool clearSelectedCandidate = false,
    AvatarStylePreset? stylePreset,
    AvatarVariationStrength? variationStrength,
    AvatarSeed? seed,
  }) {
    return AvatarCandidateState(
      profile: profile ?? this.profile,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      result: clearResult ? null : result ?? this.result,
      selectedCandidate: clearSelectedCandidate
          ? null
          : selectedCandidate ?? this.selectedCandidate,
      stylePreset: stylePreset ?? this.stylePreset,
      variationStrength: variationStrength ?? this.variationStrength,
      seed: seed ?? this.seed,
    );
  }
}

class AvatarCandidateController extends ChangeNotifier {
  AvatarCandidateController({
    required AvatarBatchGenerator generator,
    UserAvatarProfile initialProfile = UserAvatarProfile.defaultAdult,
  })  : _generator = generator,
        _state = AvatarCandidateState(profile: initialProfile);

  final AvatarBatchGenerator _generator;
  AvatarCandidateState _state;

  AvatarCandidateState get state => _state;

  void updateProfile(UserAvatarProfile profile) {
    _state = _state.copyWith(profile: profile, clearError: true);
    notifyListeners();
  }

  void updateStylePreset(AvatarStylePreset preset) {
    _state = _state.copyWith(stylePreset: preset, clearError: true);
    notifyListeners();
  }

  void updateVariationStrength(AvatarVariationStrength strength) {
    _state = _state.copyWith(variationStrength: strength, clearError: true);
    notifyListeners();
  }

  Future<void> generateCandidates({int count = 4}) async {
    _state = _state.copyWith(
      loading: true,
      clearError: true,
      clearResult: true,
      clearSelectedCandidate: true,
    );
    notifyListeners();

    try {
      final seed = _state.seed ?? AvatarSeed.create();
      final request = AvatarGenerationBatchRequest.fromProfile(
        profile: _state.profile,
        stylePreset: _state.stylePreset,
        variationStrength: _state.variationStrength,
        seed: seed,
        count: count,
      );

      final result = await _generator.generateBatch(request);

      _state = _state.copyWith(
        loading: false,
        result: result,
        selectedCandidate: result.bestCandidate,
        seed: seed,
      );
      notifyListeners();
    } on AvatarBatchGenerationException catch (error) {
      _state = _state.copyWith(
        loading: false,
        errorMessage: error.message,
      );
      notifyListeners();
    } catch (_) {
      _state = _state.copyWith(
        loading: false,
        errorMessage: 'Avatar candidate generation failed. Please try again.',
      );
      notifyListeners();
    }
  }

  Future<void> regenerateVariation({AvatarVariationStrength? strength}) async {
    final nextSeed = (_state.seed ?? AvatarSeed.create()).nextVersion();
    _state = _state.copyWith(
      seed: nextSeed,
      variationStrength: strength ?? _state.variationStrength,
    );
    await generateCandidates();
  }

  void selectCandidate(AvatarGenerationCandidate candidate) {
    _state = _state.copyWith(selectedCandidate: candidate, clearError: true);
    notifyListeners();
  }

  UserAvatarProfile acceptSelectedCandidate() {
    final candidate = _state.selectedCandidate;
    if (candidate == null) return _state.profile;

    final updated = _state.profile.copyWith(
      generatedImageUrl: candidate.imageUrl,
      localImagePath: candidate.localPath,
      renderMode: _state.stylePreset.renderMode,
      realismLevel: _state.stylePreset.realismLevel,
    );

    _state = _state.copyWith(profile: updated, clearError: true);
    notifyListeners();

    return updated;
  }
}
