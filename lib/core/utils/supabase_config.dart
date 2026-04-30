String normalizeSupabaseUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return trimmed;

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return trimmed.replaceFirst(RegExp(r'/+$'), '');
  }

  final normalizedPath = uri.path.replaceAll(RegExp(r'/+$'), '').toLowerCase();
  if (normalizedPath == '/rest/v1' || uri.path.isEmpty || uri.path == '/') {
    return Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    ).toString().replaceFirst(RegExp(r'/+$'), '');
  }

  return trimmed.replaceFirst(RegExp(r'/+$'), '');
}
