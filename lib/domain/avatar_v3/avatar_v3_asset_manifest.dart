import 'avatar_v3_enums.dart';
import 'avatar_v3_layer.dart';
import 'avatar_v3_options.dart';
import 'avatar_v3_profile.dart';

class AvatarV3AssetManifest {
  const AvatarV3AssetManifest({
    required this.version,
    required this.layers,
  });

  final int version;
  final List<AvatarV3Layer> layers;

  static const AvatarV3AssetManifest starter = AvatarV3AssetManifest(
    version: 1,
    layers: <AvatarV3Layer>[
      AvatarV3Layer(
        id: 'background.soft_studio',
        slot: AvatarV3LayerSlot.background,
        assetPath: 'assets/avatar_v3/overlays/background_soft_studio.svg',
        zIndex: 0,
      ),
      AvatarV3Layer(
        id: 'body.meta.average.black_top',
        slot: AvatarV3LayerSlot.body,
        assetPath: 'assets/avatar_v3/base/body/meta_average_black_top.svg',
        zIndex: 100,
      ),
      AvatarV3Layer(
        id: 'body.neck.medium.tan',
        slot: AvatarV3LayerSlot.neck,
        assetPath: 'assets/avatar_v3/base/neck/medium_tan.svg',
        zIndex: 180,
      ),
      AvatarV3Layer(
        id: 'hair.ringlet_afro.back.long_copper',
        slot: AvatarV3LayerSlot.backHair,
        assetPath: 'assets/avatar_v3/hair/ringlet_afro/back/long_copper.svg',
        zIndex: 220,
      ),
      AvatarV3Layer(
        id: 'head.oval.tan',
        slot: AvatarV3LayerSlot.head,
        assetPath: 'assets/avatar_v3/base/head/oval_tan.svg',
        zIndex: 300,
      ),
      AvatarV3Layer(
        id: 'ears.tan',
        slot: AvatarV3LayerSlot.ears,
        assetPath: 'assets/avatar_v3/base/head/ears_tan.svg',
        zIndex: 310,
      ),
      AvatarV3Layer(
        id: 'face.apple_meta.default',
        slot: AvatarV3LayerSlot.face,
        assetPath: 'assets/avatar_v3/base/face/apple_meta_default.svg',
        zIndex: 500,
      ),
      AvatarV3Layer(
        id: 'skin.freckles.nose_cheeks.medium',
        slot: AvatarV3LayerSlot.skinDetail,
        assetPath: 'assets/avatar_v3/skin/freckles/nose_cheeks_medium.svg',
        zIndex: 530,
      ),
      AvatarV3Layer(
        id: 'hair.ringlet_afro.front.long_copper',
        slot: AvatarV3LayerSlot.frontHair,
        assetPath: 'assets/avatar_v3/hair/ringlet_afro/front/long_copper.svg',
        zIndex: 720,
      ),
      AvatarV3Layer(
        id: 'facial_hair.none',
        slot: AvatarV3LayerSlot.facialHair,
        assetPath: 'assets/avatar_v3/facial_hair/none.svg',
        zIndex: 700,
        opacity: 0,
      ),
      AvatarV3Layer(
        id: 'accessories.glasses.round_clear',
        slot: AvatarV3LayerSlot.accessories,
        assetPath: 'assets/avatar_v3/accessories/glasses/round_clear.svg',
        zIndex: 800,
      ),
      AvatarV3Layer(
        id: 'lighting.soft',
        slot: AvatarV3LayerSlot.lighting,
        assetPath: 'assets/avatar_v3/overlays/lighting_soft.svg',
        zIndex: 900,
      ),
    ],
  );

  AvatarV3Layer? layerById(String id) {
    for (final layer in layers) {
      if (layer.id == id) return layer;
    }
    return null;
  }
}

class AvatarV3LayerResolver {
  const AvatarV3LayerResolver({
    this.manifest = AvatarV3AssetManifest.starter,
  });

  final AvatarV3AssetManifest manifest;

  List<AvatarV3Layer> resolve(AvatarV3Profile profile) {
    final normalized = AvatarV3Options.normalize(profile);
    final result = <AvatarV3Layer>[];

    void add(String id) {
      final layer = manifest.layerById(id);
      if (layer != null) result.add(layer);
    }

    add('background.soft_studio');
    add('body.meta.average.black_top');
    add('body.neck.medium.tan');

    if (normalized.hair.type == AvatarV3HairType.ringletAfro ||
        normalized.hair.style == AvatarV3HairStyle.longRingletAfro ||
        normalized.hair.style == AvatarV3HairStyle.sidePartAfro) {
      add('hair.ringlet_afro.back.long_copper');
    }

    add('head.oval.tan');
    add('ears.tan');
    add('face.apple_meta.default');

    if (normalized.skin.freckles.amount != AvatarV3DetailAmount.none) {
      add('skin.freckles.nose_cheeks.medium');
    }

    if (normalized.facialHair.type == AvatarV3FacialHair.none) {
      add('facial_hair.none');
    }

    if (normalized.hair.type == AvatarV3HairType.ringletAfro ||
        normalized.hair.style == AvatarV3HairStyle.longRingletAfro ||
        normalized.hair.style == AvatarV3HairStyle.sidePartAfro) {
      add('hair.ringlet_afro.front.long_copper');
    }

    if (normalized.accessories.items.contains(AvatarV3Accessory.glasses)) {
      add('accessories.glasses.round_clear');
    }

    add('lighting.soft');

    result.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return result;
  }
}
