import 'dart:math';

class AvatarSeed {
  const AvatarSeed({
    required this.value,
    required this.version,
    required this.createdAt,
  });

  final String value;
  final int version;
  final DateTime createdAt;

  factory AvatarSeed.create({Random? random}) {
    final rng = random ?? Random.secure();
    final now = DateTime.now().toUtc();
    final parts = List<String>.generate(
      4,
      (_) => rng.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0'),
    );

    return AvatarSeed(
      value: '${now.millisecondsSinceEpoch}-${parts.join('-')}',
      version: 1,
      createdAt: now,
    );
  }

  AvatarSeed nextVersion() {
    return AvatarSeed(
      value: value,
      version: version + 1,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'value': value,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AvatarSeed.fromJson(Map<String, dynamic> json) {
    return AvatarSeed(
      value: json['value'] as String,
      version: json['version'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
