import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/avatar_v3/avatar_v3_asset_manifest.dart';
import '../../domain/avatar_v3/avatar_v3_layer.dart';
import '../../domain/avatar_v3/avatar_v3_profile.dart';

class AvatarV3LayerStack extends StatelessWidget {
  const AvatarV3LayerStack({
    super.key,
    required this.profile,
    this.resolver = const AvatarV3LayerResolver(),
  });

  final AvatarV3Profile profile;
  final AvatarV3LayerResolver resolver;

  @override
  Widget build(BuildContext context) {
    final layers = resolver.resolve(profile);
    return Stack(
      fit: StackFit.expand,
      children: layers.map(_LayerWidget.new).toList(growable: false),
    );
  }
}

class _LayerWidget extends StatelessWidget {
  const _LayerWidget(this.layer);

  final AvatarV3Layer layer;

  @override
  Widget build(BuildContext context) {
    Widget child = SvgPicture.asset(
      layer.assetPath,
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );

    if (layer.opacity < 1) {
      child = Opacity(opacity: layer.opacity, child: child);
    }

    if (layer.scale != 1.0 || layer.offset != Offset.zero) {
      child = Transform.translate(
        offset: layer.offset,
        child: Transform.scale(scale: layer.scale, child: child),
      );
    }

    return IgnorePointer(child: child);
  }
}
