class AvatarV4ReferenceImageUpload {
  const AvatarV4ReferenceImageUpload({
    required this.userId,
    required this.storagePath,
    required this.consentVersion,
    required this.uploadedAtIso,
    this.originalFileName,
    this.mimeType,
  });

  final String userId;
  final String storagePath;
  final String consentVersion;
  final String uploadedAtIso;
  final String? originalFileName;
  final String? mimeType;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'storagePath': storagePath,
      'consentVersion': consentVersion,
      'uploadedAtIso': uploadedAtIso,
      'originalFileName': originalFileName,
      'mimeType': mimeType,
    };
  }

  static AvatarV4ReferenceImageUpload fromJson(Map<String, dynamic> json) {
    return AvatarV4ReferenceImageUpload(
      userId: _string(json['userId']),
      storagePath: _string(json['storagePath']),
      consentVersion: _string(json['consentVersion']),
      uploadedAtIso: _string(json['uploadedAtIso']),
      originalFileName:
          json['originalFileName'] is String ? json['originalFileName'] as String : null,
      mimeType: json['mimeType'] is String ? json['mimeType'] as String : null,
    );
  }

  static String _string(Object? value) {
    return value is String ? value : '';
  }
}
