import 'avatar_generation_candidate.dart';

class AvatarGenerationBatchResult {
  const AvatarGenerationBatchResult({
    required this.candidates,
    this.batchId,
    this.providerId,
    this.revisedPrompt,
  });

  final List<AvatarGenerationCandidate> candidates;
  final String? batchId;
  final String? providerId;
  final String? revisedPrompt;

  AvatarGenerationCandidate? get bestCandidate {
    if (candidates.isEmpty) return null;

    final sorted = [...candidates]
      ..sort((a, b) => b.qualityScore.compareTo(a.qualityScore));

    final noWarning = sorted.where((candidate) => !candidate.hasWarnings);
    return noWarning.isNotEmpty ? noWarning.first : sorted.first;
  }

  factory AvatarGenerationBatchResult.fromJson(Map<String, dynamic> json) {
    final rawCandidates = json['candidates'] as List? ?? const <dynamic>[];

    return AvatarGenerationBatchResult(
      candidates: rawCandidates
          .whereType<Map>()
          .map((item) => AvatarGenerationCandidate.fromJson(
                item.cast<String, dynamic>(),
              ))
          .toList(),
      batchId: json['batchId'] as String?,
      providerId: json['providerId'] as String?,
      revisedPrompt: json['revisedPrompt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'candidates': candidates.map((candidate) => candidate.toJson()).toList(),
      'batchId': batchId,
      'providerId': providerId,
      'revisedPrompt': revisedPrompt,
    };
  }
}
