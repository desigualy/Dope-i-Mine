
String tempId(String prefix) => '$prefix-${DateTime.now().millisecondsSinceEpoch}';

String stableClientToken(String seed) {
  final sanitized = seed.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return '${sanitized.isEmpty ? 'item' : sanitized}-${DateTime.now().microsecondsSinceEpoch}';
}
