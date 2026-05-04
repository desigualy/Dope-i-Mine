import '../../domain/avatar/avatar_generation_batch_request.dart';
import '../../domain/avatar/avatar_generation_batch_result.dart';
import '../../domain/avatar/avatar_generation_candidate.dart';
import 'avatar_batch_generator.dart';

class LocalAvatarBatchGenerator implements AvatarBatchGenerator {
  const LocalAvatarBatchGenerator();

  @override
  Future<AvatarGenerationBatchResult> generateBatch(
    AvatarGenerationBatchRequest request,
  ) async {
    const fallbackLabels = <String>[
      'Calm Companion',
      'Focus Friend',
      'Cozy Helper',
      'Bright Starter',
      'Steady Helper',
      'Gentle Spark',
    ];

    final count = request.count.clamp(1, fallbackLabels.length).toInt();
    final candidates = <AvatarGenerationCandidate>[];

    for (var index = 0; index < count; index += 1) {
      final label = fallbackLabels[index];
      candidates.add(
        AvatarGenerationCandidate(
          id: 'offline_${request.seed.value}_${index + 1}',
          imageUrl: _svgDataUri(label, _colorForIndex(index)),
          qualityScore: 0.72,
          seed: '${request.seed.value}_${index + 1}',
          variationStrength: request.variationStrength,
          providerId: 'offline_fallback',
          revisedPrompt: _fallbackPrompt(request, label),
          warnings: const <String>[
            'Offline fallback avatar. Remote generation was unavailable.',
          ],
          metadata: <String, dynamic>{
            'offline': true,
            'fallback': true,
            'label': label,
            'stylePreset': request.stylePreset.name,
          },
        ),
      );
    }

    return AvatarGenerationBatchResult(
      candidates: candidates,
      batchId: 'offline_${request.seed.value}',
      providerId: 'offline_fallback',
      revisedPrompt: request.prompt,
    );
  }

  String _fallbackPrompt(
    AvatarGenerationBatchRequest request,
    String label,
  ) {
    final stylePreset = request.stylePreset.name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)!.toLowerCase()}',
        )
        .trim();

    return '$label, warm semi-realistic wellness app avatar portrait, '
        '$stylePreset style, no text, no watermark, friendly and calm.';
  }

  static int _colorForIndex(int index) {
    const colors = <int>[
      0xFF7DD3FC,
      0xFFA7F3D0,
      0xFFFDE68A,
      0xFFF0ABFC,
      0xFFC4B5FD,
      0xFFFCA5A5,
    ];
    return colors[index % colors.length];
  }

  static String _svgDataUri(String label, int color) {
    final hex = color.toRadixString(16).padLeft(8, '0').substring(2);
    final safeLabel = label
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');

    final svg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <rect width="512" height="512" rx="96" fill="#$hex"/>
  <circle cx="256" cy="210" r="82" fill="white" opacity="0.92"/>
  <path d="M154 384c14-58 56-94 102-94s88 36 102 94c7 29-16 54-46 54H200c-30 0-53-25-46-54z" fill="white" opacity="0.92"/>
  <circle cx="226" cy="205" r="10" fill="#1f2937" opacity="0.9"/>
  <circle cx="286" cy="205" r="10" fill="#1f2937" opacity="0.9"/>
  <path d="M226 247c18 18 42 18 60 0" stroke="#1f2937" stroke-width="10" stroke-linecap="round" fill="none" opacity="0.85"/>
  <text x="256" y="474" text-anchor="middle" font-family="Arial, sans-serif" font-size="32" font-weight="700" fill="#1f2937">$safeLabel</text>
</svg>
''';

    return 'data:image/svg+xml;utf8,${Uri.encodeComponent(svg)}';
  }
}
