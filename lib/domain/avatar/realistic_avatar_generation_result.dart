class RealisticAvatarGenerationResult {
  const RealisticAvatarGenerationResult({
    required this.imageUrl,
    this.localPath,
    this.providerId,
    this.revisedPrompt,
  });

  final String imageUrl;
  final String? localPath;
  final String? providerId;
  final String? revisedPrompt;
}
