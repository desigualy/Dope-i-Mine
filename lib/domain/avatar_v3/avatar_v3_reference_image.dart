class AvatarV3ReferenceImage {
  const AvatarV3ReferenceImage({
    required this.localPath,
    this.remoteUrl,
    this.width,
    this.height,
    this.capturedAt,
  });

  final String localPath;
  final String? remoteUrl;
  final int? width;
  final int? height;
  final DateTime? capturedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'localPath': localPath,
      'remoteUrl': remoteUrl,
      'width': width,
      'height': height,
      'capturedAt': capturedAt?.toUtc().toIso8601String(),
    };
  }

  factory AvatarV3ReferenceImage.fromJson(Map<String, dynamic> json) {
    return AvatarV3ReferenceImage(
      localPath: json['localPath'] as String? ?? '',
      remoteUrl: json['remoteUrl'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      capturedAt: json['capturedAt'] is String
          ? DateTime.tryParse(json['capturedAt'] as String)
          : null,
    );
  }
}
