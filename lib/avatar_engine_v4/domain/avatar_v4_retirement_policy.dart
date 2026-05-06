class AvatarV4RetirementPolicy {
  const AvatarV4RetirementPolicy._();

  static const String activePublicEngine = 'Avatar Engine V4 / Rive';

  static const List<String> retiredPublicEngines = <String>[
    'Avatar V2 CustomPainter',
    'Avatar V3 SVG/blob/layer renderer',
    'UnifiedUserAvatar public fallback',
    'FloatingDopeiAvatar public fallback',
  ];

  static const List<String> publicSurfaceFiles = <String>[
    'lib/presentation/home/home_screen.dart',
    'lib/presentation/user_avatar/user_avatar_studio.dart',
    'lib/avatar_engine_v4/presentation/avatar_customizer_screen.dart',
  ];

  static const List<String> blockedPublicSymbols = <String>[
    'UnifiedUserAvatar',
    'FloatingDopeiAvatar',
    'AvatarV3Renderer',
    'AvatarV3LayerStack',
    'currentAvatarV3Provider',
  ];

  static const List<String> blockedPublicImportFragments = <String>[
    'presentation/avatar_v3/',
    'presentation/avatar/current_user_avatar_provider.dart',
    'presentation/avatar/user_avatar_renderer.dart',
  ];

  static bool isBlockedPublicSymbol(String symbol) {
    return blockedPublicSymbols.contains(symbol);
  }

  static bool isBlockedPublicImport(String importLine) {
    return blockedPublicImportFragments.any(importLine.contains);
  }
}
