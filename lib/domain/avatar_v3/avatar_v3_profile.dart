import 'avatar_v3_enums.dart';
import 'avatar_v3_reference_image.dart';

class AvatarV3Profile {
  const AvatarV3Profile({
    this.id = 'local-avatar-v3',
    this.mode = AvatarV3Mode.inspiredByMe,
    this.visualStyle = AvatarV3VisualStyle.hybridAppleMeta,
    this.renderMode = AvatarV3RenderMode.assetLayered,
    this.camera = AvatarV3Camera.bust,
    this.agePresentation = AvatarV3AgePresentation.adult,
    this.head = const AvatarV3HeadProfile(),
    this.face = const AvatarV3FaceProfile(),
    this.neck = const AvatarV3NeckProfile(),
    this.body = const AvatarV3BodyProfile(),
    this.skin = const AvatarV3SkinProfile(),
    this.hair = const AvatarV3HairProfile(),
    this.facialHair = const AvatarV3FacialHairProfile(),
    this.clothing = const AvatarV3ClothingProfile(),
    this.accessories = const AvatarV3AccessoryProfile(),
    this.referenceImage,
    this.updatedAt,
    this.syncStatus = AvatarV3SyncStatus.synced,
  });

  final String id;
  final AvatarV3Mode mode;
  final AvatarV3VisualStyle visualStyle;
  final AvatarV3RenderMode renderMode;
  final AvatarV3Camera camera;
  final AvatarV3AgePresentation agePresentation;
  final AvatarV3HeadProfile head;
  final AvatarV3FaceProfile face;
  final AvatarV3NeckProfile neck;
  final AvatarV3BodyProfile body;
  final AvatarV3SkinProfile skin;
  final AvatarV3HairProfile hair;
  final AvatarV3FacialHairProfile facialHair;
  final AvatarV3ClothingProfile clothing;
  final AvatarV3AccessoryProfile accessories;
  final AvatarV3ReferenceImage? referenceImage;
  final DateTime? updatedAt;
  final AvatarV3SyncStatus syncStatus;

  bool get canRenderFacialHair =>
      agePresentation != AvatarV3AgePresentation.child &&
      agePresentation != AvatarV3AgePresentation.preTeen;

  AvatarV3Profile copyWith({
    String? id,
    AvatarV3Mode? mode,
    AvatarV3VisualStyle? visualStyle,
    AvatarV3RenderMode? renderMode,
    AvatarV3Camera? camera,
    AvatarV3AgePresentation? agePresentation,
    AvatarV3HeadProfile? head,
    AvatarV3FaceProfile? face,
    AvatarV3NeckProfile? neck,
    AvatarV3BodyProfile? body,
    AvatarV3SkinProfile? skin,
    AvatarV3HairProfile? hair,
    AvatarV3FacialHairProfile? facialHair,
    AvatarV3ClothingProfile? clothing,
    AvatarV3AccessoryProfile? accessories,
    AvatarV3ReferenceImage? referenceImage,
    bool clearReferenceImage = false,
    DateTime? updatedAt,
    AvatarV3SyncStatus? syncStatus,
  }) {
    return AvatarV3Profile(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      visualStyle: visualStyle ?? this.visualStyle,
      renderMode: renderMode ?? this.renderMode,
      camera: camera ?? this.camera,
      agePresentation: agePresentation ?? this.agePresentation,
      head: head ?? this.head,
      face: face ?? this.face,
      neck: neck ?? this.neck,
      body: body ?? this.body,
      skin: skin ?? this.skin,
      hair: hair ?? this.hair,
      facialHair: facialHair ?? this.facialHair,
      clothing: clothing ?? this.clothing,
      accessories: accessories ?? this.accessories,
      referenceImage:
          clearReferenceImage ? null : referenceImage ?? this.referenceImage,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'mode': mode.name,
      'visualStyle': visualStyle.name,
      'renderMode': renderMode.name,
      'camera': camera.name,
      'agePresentation': agePresentation.name,
      'head': head.toJson(),
      'face': face.toJson(),
      'neck': neck.toJson(),
      'body': body.toJson(),
      'skin': skin.toJson(),
      'hair': hair.toJson(),
      'facialHair': facialHair.toJson(),
      'clothing': clothing.toJson(),
      'accessories': accessories.toJson(),
      'referenceImage': referenceImage?.toJson(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'syncStatus': syncStatus.name,
    };
  }

  factory AvatarV3Profile.fromJson(Map<String, dynamic> json) {
    return AvatarV3Profile(
      id: json['id'] as String? ?? 'local-avatar-v3',
      mode: _enum(json['mode'], AvatarV3Mode.values, AvatarV3Mode.inspiredByMe),
      visualStyle: _enum(
        json['visualStyle'],
        AvatarV3VisualStyle.values,
        AvatarV3VisualStyle.hybridAppleMeta,
      ),
      renderMode: AvatarV3RenderMode.assetLayered,
      camera: _enum(json['camera'], AvatarV3Camera.values, AvatarV3Camera.bust),
      agePresentation: _enum(
        json['agePresentation'],
        AvatarV3AgePresentation.values,
        AvatarV3AgePresentation.adult,
      ),
      head: json['head'] is Map<String, dynamic>
          ? AvatarV3HeadProfile.fromJson(json['head'] as Map<String, dynamic>)
          : const AvatarV3HeadProfile(),
      face: json['face'] is Map<String, dynamic>
          ? AvatarV3FaceProfile.fromJson(json['face'] as Map<String, dynamic>)
          : const AvatarV3FaceProfile(),
      neck: json['neck'] is Map<String, dynamic>
          ? AvatarV3NeckProfile.fromJson(json['neck'] as Map<String, dynamic>)
          : const AvatarV3NeckProfile(),
      body: json['body'] is Map<String, dynamic>
          ? AvatarV3BodyProfile.fromJson(json['body'] as Map<String, dynamic>)
          : const AvatarV3BodyProfile(),
      skin: json['skin'] is Map<String, dynamic>
          ? AvatarV3SkinProfile.fromJson(json['skin'] as Map<String, dynamic>)
          : const AvatarV3SkinProfile(),
      hair: json['hair'] is Map<String, dynamic>
          ? AvatarV3HairProfile.fromJson(json['hair'] as Map<String, dynamic>)
          : const AvatarV3HairProfile(),
      facialHair: json['facialHair'] is Map<String, dynamic>
          ? AvatarV3FacialHairProfile.fromJson(
              json['facialHair'] as Map<String, dynamic>,
            )
          : const AvatarV3FacialHairProfile(),
      clothing: json['clothing'] is Map<String, dynamic>
          ? AvatarV3ClothingProfile.fromJson(
              json['clothing'] as Map<String, dynamic>,
            )
          : const AvatarV3ClothingProfile(),
      accessories: json['accessories'] is Map<String, dynamic>
          ? AvatarV3AccessoryProfile.fromJson(
              json['accessories'] as Map<String, dynamic>,
            )
          : const AvatarV3AccessoryProfile(),
      referenceImage: json['referenceImage'] is Map<String, dynamic>
          ? AvatarV3ReferenceImage.fromJson(
              json['referenceImage'] as Map<String, dynamic>,
            )
          : null,
      updatedAt: json['updatedAt'] is String
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      syncStatus: _enum(
        json['syncStatus'],
        AvatarV3SyncStatus.values,
        AvatarV3SyncStatus.synced,
      ),
    );
  }

  static T _enum<T extends Enum>(Object? raw, List<T> values, T fallback) {
    if (raw is String) {
      for (final value in values) {
        if (value.name == raw) return value;
      }
    }
    return fallback;
  }
}

class AvatarV3HeadProfile {
  const AvatarV3HeadProfile({
    this.shape = AvatarV3HeadShape.oval,
    this.size = AvatarV3HeadSize.medium,
  });

  final AvatarV3HeadShape shape;
  final AvatarV3HeadSize size;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'shape': shape.name,
        'size': size.name,
      };

  factory AvatarV3HeadProfile.fromJson(Map<String, dynamic> json) {
    return AvatarV3HeadProfile(
      shape: AvatarV3Profile._enum(
        json['shape'],
        AvatarV3HeadShape.values,
        AvatarV3HeadShape.oval,
      ),
      size: AvatarV3Profile._enum(
        json['size'],
        AvatarV3HeadSize.values,
        AvatarV3HeadSize.medium,
      ),
    );
  }
}

class AvatarV3FaceProfile {
  const AvatarV3FaceProfile({
    this.shape = AvatarV3FaceShape.softRound,
  });

  final AvatarV3FaceShape shape;

  Map<String, dynamic> toJson() => <String, dynamic>{'shape': shape.name};

  factory AvatarV3FaceProfile.fromJson(Map<String, dynamic> json) {
    return AvatarV3FaceProfile(
      shape: AvatarV3Profile._enum(
        json['shape'],
        AvatarV3FaceShape.values,
        AvatarV3FaceShape.softRound,
      ),
    );
  }
}

class AvatarV3NeckProfile {
  const AvatarV3NeckProfile({
    this.size = AvatarV3NeckSize.medium,
  });

  final AvatarV3NeckSize size;

  Map<String, dynamic> toJson() => <String, dynamic>{'size': size.name};

  factory AvatarV3NeckProfile.fromJson(Map<String, dynamic> json) {
    return AvatarV3NeckProfile(
      size: AvatarV3Profile._enum(
        json['size'],
        AvatarV3NeckSize.values,
        AvatarV3NeckSize.medium,
      ),
    );
  }
}

class AvatarV3BodyProfile {
  const AvatarV3BodyProfile({
    this.presentation = AvatarV3BodyPresentation.average,
    this.belly = AvatarV3BodyBelly.average,
    this.waist = AvatarV3BodyWaist.average,
    this.hips = AvatarV3BodyHips.average,
    this.thighs = AvatarV3BodyThighs.average,
    this.chest = AvatarV3BodyChest.medium,
    this.bum = AvatarV3BodyBum.average,
    this.legs = AvatarV3BodyLegs.average,
  });

  final AvatarV3BodyPresentation presentation;
  final AvatarV3BodyBelly belly;
  final AvatarV3BodyWaist waist;
  final AvatarV3BodyHips hips;
  final AvatarV3BodyThighs thighs;
  final AvatarV3BodyChest chest;
  final AvatarV3BodyBum bum;
  final AvatarV3BodyLegs legs;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'presentation': presentation.name,
        'belly': belly.name,
        'waist': waist.name,
        'hips': hips.name,
        'thighs': thighs.name,
        'chest': chest.name,
        'bum': bum.name,
        'legs': legs.name,
      };

  factory AvatarV3BodyProfile.fromJson(Map<String, dynamic> json) {
    return AvatarV3BodyProfile(
      presentation: AvatarV3Profile._enum(
        json['presentation'],
        AvatarV3BodyPresentation.values,
        AvatarV3BodyPresentation.average,
      ),
      belly: AvatarV3Profile._enum(
        json['belly'],
        AvatarV3BodyBelly.values,
        AvatarV3BodyBelly.average,
      ),
      waist: AvatarV3Profile._enum(
        json['waist'],
        AvatarV3BodyWaist.values,
        AvatarV3BodyWaist.average,
      ),
      hips: AvatarV3Profile._enum(
        json['hips'],
        AvatarV3BodyHips.values,
        AvatarV3BodyHips.average,
      ),
      thighs: AvatarV3Profile._enum(
        json['thighs'],
        AvatarV3BodyThighs.values,
        AvatarV3BodyThighs.average,
      ),
      chest: AvatarV3Profile._enum(
        json['chest'],
        AvatarV3BodyChest.values,
        AvatarV3BodyChest.medium,
      ),
      bum: AvatarV3Profile._enum(
        json['bum'],
        AvatarV3BodyBum.values,
        AvatarV3BodyBum.average,
      ),
      legs: AvatarV3Profile._enum(
        json['legs'],
        AvatarV3BodyLegs.values,
        AvatarV3BodyLegs.average,
      ),
    );
  }
}

class AvatarV3SkinProfile {
  const AvatarV3SkinProfile({
    this.tone = AvatarV3SkinTone.medium,
    this.undertone = AvatarV3SkinUndertone.warm,
    this.freckles = const AvatarV3PlacementDetail(),
    this.vitiligo = const AvatarV3PlacementDetail(),
    this.scars = const <AvatarV3ScarDetail>[],
    this.birthmarks = const <AvatarV3BirthmarkDetail>[],
    this.matureLines = const <AvatarV3MatureLineDetail>[],
  });

  final AvatarV3SkinTone tone;
  final AvatarV3SkinUndertone undertone;
  final AvatarV3PlacementDetail freckles;
  final AvatarV3PlacementDetail vitiligo;
  final List<AvatarV3ScarDetail> scars;
  final List<AvatarV3BirthmarkDetail> birthmarks;
  final List<AvatarV3MatureLineDetail> matureLines;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tone': tone.name,
        'undertone': undertone.name,
        'freckles': freckles.toJson(),
        'vitiligo': vitiligo.toJson(),
        'scars': scars.map((e) => e.toJson()).toList(),
        'birthmarks': birthmarks.map((e) => e.toJson()).toList(),
        'matureLines': matureLines.map((e) => e.toJson()).toList(),
      };

  factory AvatarV3SkinProfile.fromJson(Map<String, dynamic> json) {
    return AvatarV3SkinProfile(
      tone: AvatarV3Profile._enum(
        json['tone'],
        AvatarV3SkinTone.values,
        AvatarV3SkinTone.medium,
      ),
      undertone: AvatarV3Profile._enum(
        json['undertone'],
        AvatarV3SkinUndertone.values,
        AvatarV3SkinUndertone.warm,
      ),
      freckles: json['freckles'] is Map<String, dynamic>
          ? AvatarV3PlacementDetail.fromJson(
              json['freckles'] as Map<String, dynamic>,
            )
          : const AvatarV3PlacementDetail(),
      vitiligo: json['vitiligo'] is Map<String, dynamic>
          ? AvatarV3PlacementDetail.fromJson(
              json['vitiligo'] as Map<String, dynamic>,
            )
          : const AvatarV3PlacementDetail(),
      scars: (json['scars'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(AvatarV3ScarDetail.fromJson)
          .toList(),
      birthmarks: (json['birthmarks'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(AvatarV3BirthmarkDetail.fromJson)
          .toList(),
      matureLines: (json['matureLines'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(AvatarV3MatureLineDetail.fromJson)
          .toList(),
    );
  }
}

class AvatarV3PlacementDetail {
  const AvatarV3PlacementDetail({
    this.amount = AvatarV3DetailAmount.none,
    this.placements = const <AvatarV3DetailPlacement>[],
  });

  final AvatarV3DetailAmount amount;
  final List<AvatarV3DetailPlacement> placements;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'amount': amount.name,
        'placements': placements.map((e) => e.name).toList(),
      };

  factory AvatarV3PlacementDetail.fromJson(Map<String, dynamic> json) {
    return AvatarV3PlacementDetail(
      amount: AvatarV3Profile._enum(
        json['amount'],
        AvatarV3DetailAmount.values,
        AvatarV3DetailAmount.none,
      ),
      placements: (json['placements'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .map(
            (value) => AvatarV3Profile._enum(
              value,
              AvatarV3DetailPlacement.values,
              AvatarV3DetailPlacement.cheeks,
            ),
          )
          .toList(),
    );
  }
}

class AvatarV3ScarDetail extends AvatarV3PlacementDetail {
  const AvatarV3ScarDetail({
    super.amount = AvatarV3DetailAmount.none,
    super.placements = const <AvatarV3DetailPlacement>[],
    this.shape = AvatarV3ScarShape.fineLine,
  });

  final AvatarV3ScarShape shape;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ...super.toJson(),
        'shape': shape.name,
      };

  factory AvatarV3ScarDetail.fromJson(Map<String, dynamic> json) {
    return AvatarV3ScarDetail(
      amount: AvatarV3Profile._enum(
        json['amount'],
        AvatarV3DetailAmount.values,
        AvatarV3DetailAmount.none,
      ),
      placements: (json['placements'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .map(
            (value) => AvatarV3Profile._enum(
              value,
              AvatarV3DetailPlacement.values,
              AvatarV3DetailPlacement.cheeks,
            ),
          )
          .toList(),
      shape: AvatarV3Profile._enum(
        json['shape'],
        AvatarV3ScarShape.values,
        AvatarV3ScarShape.fineLine,
      ),
    );
  }
}

class AvatarV3BirthmarkDetail extends AvatarV3PlacementDetail {
  const AvatarV3BirthmarkDetail({
    super.amount = AvatarV3DetailAmount.none,
    super.placements = const <AvatarV3DetailPlacement>[],
    this.shape = AvatarV3BirthmarkShape.beautyMark,
  });

  final AvatarV3BirthmarkShape shape;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ...super.toJson(),
        'shape': shape.name,
      };

  factory AvatarV3BirthmarkDetail.fromJson(Map<String, dynamic> json) {
    return AvatarV3BirthmarkDetail(
      amount: AvatarV3Profile._enum(
        json['amount'],
        AvatarV3DetailAmount.values,
        AvatarV3DetailAmount.none,
      ),
      placements: (json['placements'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .map(
            (value) => AvatarV3Profile._enum(
              value,
              AvatarV3DetailPlacement.values,
              AvatarV3DetailPlacement.cheeks,
            ),
          )
          .toList(),
      shape: AvatarV3Profile._enum(
        json['shape'],
        AvatarV3BirthmarkShape.values,
        AvatarV3BirthmarkShape.beautyMark,
      ),
    );
  }
}

class AvatarV3MatureLineDetail extends AvatarV3PlacementDetail {
  const AvatarV3MatureLineDetail({
    super.amount = AvatarV3DetailAmount.none,
    super.placements = const <AvatarV3DetailPlacement>[],
    this.area = AvatarV3MatureLineArea.forehead,
  });

  final AvatarV3MatureLineArea area;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ...super.toJson(),
        'area': area.name,
      };

  factory AvatarV3MatureLineDetail.fromJson(Map<String, dynamic> json) {
    return AvatarV3MatureLineDetail(
      amount: AvatarV3Profile._enum(
        json['amount'],
        AvatarV3DetailAmount.values,
        AvatarV3DetailAmount.none,
      ),
      placements: (json['placements'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .map(
            (value) => AvatarV3Profile._enum(
              value,
              AvatarV3DetailPlacement.values,
              AvatarV3DetailPlacement.forehead,
            ),
          )
          .toList(),
      area: AvatarV3Profile._enum(
        json['area'],
        AvatarV3MatureLineArea.values,
        AvatarV3MatureLineArea.forehead,
      ),
    );
  }
}

class AvatarV3HairProfile {
  const AvatarV3HairProfile({
    this.type = AvatarV3HairType.wavy,
    this.style = AvatarV3HairStyle.mediumWavy,
    this.length = AvatarV3HairLength.medium,
    this.volume = AvatarV3HairVolume.medium,
    this.frontPolicy = AvatarV3HairFrontPolicy.sideOnly,
    this.colour = AvatarV3HairColour.brown,
  });

  final AvatarV3HairType type;
  final AvatarV3HairStyle style;
  final AvatarV3HairLength length;
  final AvatarV3HairVolume volume;
  final AvatarV3HairFrontPolicy frontPolicy;
  final AvatarV3HairColour colour;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'style': style.name,
        'length': length.name,
        'volume': volume.name,
        'frontPolicy': frontPolicy.name,
        'colour': colour.name,
      };

  factory AvatarV3HairProfile.fromJson(Map<String, dynamic> json) {
    return AvatarV3HairProfile(
      type: AvatarV3Profile._enum(
        json['type'],
        AvatarV3HairType.values,
        AvatarV3HairType.wavy,
      ),
      style: AvatarV3Profile._enum(
        json['style'],
        AvatarV3HairStyle.values,
        AvatarV3HairStyle.mediumWavy,
      ),
      length: AvatarV3Profile._enum(
        json['length'],
        AvatarV3HairLength.values,
        AvatarV3HairLength.medium,
      ),
      volume: AvatarV3Profile._enum(
        json['volume'],
        AvatarV3HairVolume.values,
        AvatarV3HairVolume.medium,
      ),
      frontPolicy: AvatarV3Profile._enum(
        json['frontPolicy'],
        AvatarV3HairFrontPolicy.values,
        AvatarV3HairFrontPolicy.sideOnly,
      ),
      colour: AvatarV3Profile._enum(
        json['colour'],
        AvatarV3HairColour.values,
        AvatarV3HairColour.brown,
      ),
    );
  }
}

class AvatarV3FacialHairProfile {
  const AvatarV3FacialHairProfile({
    this.type = AvatarV3FacialHair.none,
    this.size = AvatarV3FacialHairSize.medium,
    this.shape = AvatarV3FacialHairShape.natural,
    this.colour = AvatarV3HairColour.brown,
  });

  final AvatarV3FacialHair type;
  final AvatarV3FacialHairSize size;
  final AvatarV3FacialHairShape shape;
  final AvatarV3HairColour colour;

  bool get isNone => type == AvatarV3FacialHair.none;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'size': size.name,
        'shape': shape.name,
        'colour': colour.name,
      };

  factory AvatarV3FacialHairProfile.fromJson(Map<String, dynamic> json) {
    return AvatarV3FacialHairProfile(
      type: AvatarV3Profile._enum(
        json['type'],
        AvatarV3FacialHair.values,
        AvatarV3FacialHair.none,
      ),
      size: AvatarV3Profile._enum(
        json['size'],
        AvatarV3FacialHairSize.values,
        AvatarV3FacialHairSize.medium,
      ),
      shape: AvatarV3Profile._enum(
        json['shape'],
        AvatarV3FacialHairShape.values,
        AvatarV3FacialHairShape.natural,
      ),
      colour: AvatarV3Profile._enum(
        json['colour'],
        AvatarV3HairColour.values,
        AvatarV3HairColour.brown,
      ),
    );
  }
}

class AvatarV3ClothingProfile {
  const AvatarV3ClothingProfile({
    this.top = AvatarV3ClothingTop.tShirt,
    this.bottom = AvatarV3ClothingBottom.jeans,
    this.shoes = AvatarV3Shoes.trainers,
  });

  final AvatarV3ClothingTop top;
  final AvatarV3ClothingBottom bottom;
  final AvatarV3Shoes shoes;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'top': top.name,
        'bottom': bottom.name,
        'shoes': shoes.name,
      };

  factory AvatarV3ClothingProfile.fromJson(Map<String, dynamic> json) {
    return AvatarV3ClothingProfile(
      top: AvatarV3Profile._enum(
        json['top'],
        AvatarV3ClothingTop.values,
        AvatarV3ClothingTop.tShirt,
      ),
      bottom: AvatarV3Profile._enum(
        json['bottom'],
        AvatarV3ClothingBottom.values,
        AvatarV3ClothingBottom.jeans,
      ),
      shoes: AvatarV3Profile._enum(
        json['shoes'],
        AvatarV3Shoes.values,
        AvatarV3Shoes.trainers,
      ),
    );
  }
}

class AvatarV3AccessoryProfile {
  const AvatarV3AccessoryProfile({
    this.items = const <AvatarV3Accessory>[],
  });

  final List<AvatarV3Accessory> items;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'items': items.map((e) => e.name).toList(),
      };

  factory AvatarV3AccessoryProfile.fromJson(Map<String, dynamic> json) {
    return AvatarV3AccessoryProfile(
      items: (json['items'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .map(
            (value) => AvatarV3Profile._enum(
              value,
              AvatarV3Accessory.values,
              AvatarV3Accessory.glasses,
            ),
          )
          .toList(),
    );
  }
}
