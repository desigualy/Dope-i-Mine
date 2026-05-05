import 'package:flutter/material.dart';

/// Avatar V2 is the production avatar model.
///
/// This schema is deliberately more detailed than the legacy avatar profile.
/// Apple/Meta-quality avatars need structured traits, not one flat enum list.
@immutable
class AvatarV2Profile {
  const AvatarV2Profile({
    this.id = 'local-avatar-v2',
    this.mode = AvatarV2Mode.inspiredByMe,
    this.renderMode = AvatarV2RenderMode.realtimeVector,
    this.realismLevel = AvatarV2RealismLevel.semiRealistic,
    this.lightingStyle = AvatarV2LightingStyle.softStudio,
    this.cameraStyle = AvatarV2CameraStyle.headAndShoulders,
    this.agePresentation = AvatarV2AgePresentation.adult,
    this.face = const AvatarV2Face(),
    this.skin = const AvatarV2Skin(),
    this.hair = const AvatarV2Hair(),
    this.facialHair = const AvatarV2FacialHair(),
    this.body = const AvatarV2Body(),
    this.accessibility = const AvatarV2Accessibility(),
    this.clothing = const AvatarV2Clothing(),
    this.referenceImage = const AvatarV2ReferenceImage.none(),
    this.displayName,
    this.pronouns,
    this.avatarName,
    this.updatedAt,
  });

  final String id;
  final AvatarV2Mode mode;
  final AvatarV2RenderMode renderMode;
  final AvatarV2RealismLevel realismLevel;
  final AvatarV2LightingStyle lightingStyle;
  final AvatarV2CameraStyle cameraStyle;
  final AvatarV2AgePresentation agePresentation;
  final AvatarV2Face face;
  final AvatarV2Skin skin;
  final AvatarV2Hair hair;
  final AvatarV2FacialHair facialHair;
  final AvatarV2Body body;
  final AvatarV2Accessibility accessibility;
  final AvatarV2Clothing clothing;
  final AvatarV2ReferenceImage referenceImage;
  final String? displayName;
  final String? pronouns;
  final String? avatarName;
  final DateTime? updatedAt;

  bool get isChildLike =>
      agePresentation == AvatarV2AgePresentation.child ||
      agePresentation == AvatarV2AgePresentation.preTeen;

  bool get canRenderFacialHair => !isChildLike;

  AvatarV2Profile copyWith({
    String? id,
    AvatarV2Mode? mode,
    AvatarV2RenderMode? renderMode,
    AvatarV2RealismLevel? realismLevel,
    AvatarV2LightingStyle? lightingStyle,
    AvatarV2CameraStyle? cameraStyle,
    AvatarV2AgePresentation? agePresentation,
    AvatarV2Face? face,
    AvatarV2Skin? skin,
    AvatarV2Hair? hair,
    AvatarV2FacialHair? facialHair,
    AvatarV2Body? body,
    AvatarV2Accessibility? accessibility,
    AvatarV2Clothing? clothing,
    AvatarV2ReferenceImage? referenceImage,
    String? displayName,
    String? pronouns,
    String? avatarName,
    DateTime? updatedAt,
    bool clearDisplayName = false,
    bool clearPronouns = false,
    bool clearAvatarName = false,
  }) {
    return AvatarV2Profile(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      renderMode: renderMode ?? this.renderMode,
      realismLevel: realismLevel ?? this.realismLevel,
      lightingStyle: lightingStyle ?? this.lightingStyle,
      cameraStyle: cameraStyle ?? this.cameraStyle,
      agePresentation: agePresentation ?? this.agePresentation,
      face: face ?? this.face,
      skin: skin ?? this.skin,
      hair: hair ?? this.hair,
      facialHair: facialHair ?? this.facialHair,
      body: body ?? this.body,
      accessibility: accessibility ?? this.accessibility,
      clothing: clothing ?? this.clothing,
      referenceImage: referenceImage ?? this.referenceImage,
      displayName: clearDisplayName ? null : displayName ?? this.displayName,
      pronouns: clearPronouns ? null : pronouns ?? this.pronouns,
      avatarName: clearAvatarName ? null : avatarName ?? this.avatarName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'schema': 'avatar_v2.pass_1',
        'id': id,
        'mode': mode.name,
        'renderMode': renderMode.name,
        'realismLevel': realismLevel.name,
        'lightingStyle': lightingStyle.name,
        'cameraStyle': cameraStyle.name,
        'agePresentation': agePresentation.name,
        'face': face.toJson(),
        'skin': skin.toJson(),
        'hair': hair.toJson(),
        'facialHair': facialHair.toJson(),
        'body': body.toJson(),
        'accessibility': accessibility.toJson(),
        'clothing': clothing.toJson(),
        'referenceImage': referenceImage.toJson(),
        if (displayName != null) 'displayName': displayName,
        if (pronouns != null) 'pronouns': pronouns,
        if (avatarName != null) 'avatarName': avatarName,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  factory AvatarV2Profile.fromJson(Map<String, dynamic> json) {
    return AvatarV2Profile(
      id: _string(json['id'], 'local-avatar-v2'),
      mode: _enumValue(json['mode'], AvatarV2Mode.values, AvatarV2Mode.inspiredByMe),
      renderMode: _enumValue(
        json['renderMode'],
        AvatarV2RenderMode.values,
        AvatarV2RenderMode.realtimeVector,
      ),
      realismLevel: _enumValue(
        json['realismLevel'],
        AvatarV2RealismLevel.values,
        AvatarV2RealismLevel.semiRealistic,
      ),
      lightingStyle: _enumValue(
        json['lightingStyle'],
        AvatarV2LightingStyle.values,
        AvatarV2LightingStyle.softStudio,
      ),
      cameraStyle: _enumValue(
        json['cameraStyle'],
        AvatarV2CameraStyle.values,
        AvatarV2CameraStyle.headAndShoulders,
      ),
      agePresentation: _enumValue(
        json['agePresentation'],
        AvatarV2AgePresentation.values,
        AvatarV2AgePresentation.adult,
      ),
      face: AvatarV2Face.fromJson(_map(json['face'])),
      skin: AvatarV2Skin.fromJson(_map(json['skin'])),
      hair: AvatarV2Hair.fromJson(_map(json['hair'])),
      facialHair: AvatarV2FacialHair.fromJson(_map(json['facialHair'])),
      body: AvatarV2Body.fromJson(_map(json['body'])),
      accessibility: AvatarV2Accessibility.fromJson(_map(json['accessibility'])),
      clothing: AvatarV2Clothing.fromJson(_map(json['clothing'])),
      referenceImage: AvatarV2ReferenceImage.fromJson(_map(json['referenceImage'])),
      displayName: json['displayName'] as String?,
      pronouns: json['pronouns'] as String?,
      avatarName: json['avatarName'] as String?,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}

@immutable
class AvatarV2Face {
  const AvatarV2Face({
    this.shape = AvatarV2FaceShape.oval,
    this.jaw = AvatarV2JawShape.soft,
    this.cheekbones = AvatarV2CheekboneStyle.soft,
    this.chin = AvatarV2ChinStyle.rounded,
    this.nose = AvatarV2NoseShape.medium,
    this.eyeShape = AvatarV2EyeShape.almond,
    this.eyeColour = AvatarV2EyeColour.brown,
    this.eyebrowShape = AvatarV2EyebrowShape.natural,
    this.mouth = AvatarV2MouthShape.softSmile,
    this.earSize = AvatarV2EarSize.medium,
    this.expression = AvatarV2Expression.calm,
  });

  final AvatarV2FaceShape shape;
  final AvatarV2JawShape jaw;
  final AvatarV2CheekboneStyle cheekbones;
  final AvatarV2ChinStyle chin;
  final AvatarV2NoseShape nose;
  final AvatarV2EyeShape eyeShape;
  final AvatarV2EyeColour eyeColour;
  final AvatarV2EyebrowShape eyebrowShape;
  final AvatarV2MouthShape mouth;
  final AvatarV2EarSize earSize;
  final AvatarV2Expression expression;

  AvatarV2Face copyWith({
    AvatarV2FaceShape? shape,
    AvatarV2JawShape? jaw,
    AvatarV2CheekboneStyle? cheekbones,
    AvatarV2ChinStyle? chin,
    AvatarV2NoseShape? nose,
    AvatarV2EyeShape? eyeShape,
    AvatarV2EyeColour? eyeColour,
    AvatarV2EyebrowShape? eyebrowShape,
    AvatarV2MouthShape? mouth,
    AvatarV2EarSize? earSize,
    AvatarV2Expression? expression,
  }) {
    return AvatarV2Face(
      shape: shape ?? this.shape,
      jaw: jaw ?? this.jaw,
      cheekbones: cheekbones ?? this.cheekbones,
      chin: chin ?? this.chin,
      nose: nose ?? this.nose,
      eyeShape: eyeShape ?? this.eyeShape,
      eyeColour: eyeColour ?? this.eyeColour,
      eyebrowShape: eyebrowShape ?? this.eyebrowShape,
      mouth: mouth ?? this.mouth,
      earSize: earSize ?? this.earSize,
      expression: expression ?? this.expression,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'shape': shape.name,
        'jaw': jaw.name,
        'cheekbones': cheekbones.name,
        'chin': chin.name,
        'nose': nose.name,
        'eyeShape': eyeShape.name,
        'eyeColour': eyeColour.name,
        'eyebrowShape': eyebrowShape.name,
        'mouth': mouth.name,
        'earSize': earSize.name,
        'expression': expression.name,
      };

  factory AvatarV2Face.fromJson(Map<String, dynamic> json) => AvatarV2Face(
        shape: _enumValue(json['shape'], AvatarV2FaceShape.values, AvatarV2FaceShape.oval),
        jaw: _enumValue(json['jaw'], AvatarV2JawShape.values, AvatarV2JawShape.soft),
        cheekbones: _enumValue(
          json['cheekbones'],
          AvatarV2CheekboneStyle.values,
          AvatarV2CheekboneStyle.soft,
        ),
        chin: _enumValue(json['chin'], AvatarV2ChinStyle.values, AvatarV2ChinStyle.rounded),
        nose: _enumValue(json['nose'], AvatarV2NoseShape.values, AvatarV2NoseShape.medium),
        eyeShape: _enumValue(json['eyeShape'], AvatarV2EyeShape.values, AvatarV2EyeShape.almond),
        eyeColour: _enumValue(json['eyeColour'], AvatarV2EyeColour.values, AvatarV2EyeColour.brown),
        eyebrowShape: _enumValue(
          json['eyebrowShape'],
          AvatarV2EyebrowShape.values,
          AvatarV2EyebrowShape.natural,
        ),
        mouth: _enumValue(json['mouth'], AvatarV2MouthShape.values, AvatarV2MouthShape.softSmile),
        earSize: _enumValue(json['earSize'], AvatarV2EarSize.values, AvatarV2EarSize.medium),
        expression: _enumValue(json['expression'], AvatarV2Expression.values, AvatarV2Expression.calm),
      );
}

@immutable
class AvatarV2Skin {
  const AvatarV2Skin({
    this.tone = AvatarV2SkinTone.medium,
    this.undertone = AvatarV2SkinUndertone.neutral,
    this.texture = AvatarV2SkinTexture.smoothNatural,
    this.freckles = const AvatarV2Freckles(),
    this.vitiligo = const AvatarV2Vitiligo(),
    this.birthmarks = const <AvatarV2Birthmark>[],
    this.scars = const <AvatarV2Scar>[],
    this.matureLines = const AvatarV2MatureLines(),
  });

  final AvatarV2SkinTone tone;
  final AvatarV2SkinUndertone undertone;
  final AvatarV2SkinTexture texture;
  final AvatarV2Freckles freckles;
  final AvatarV2Vitiligo vitiligo;
  final List<AvatarV2Birthmark> birthmarks;
  final List<AvatarV2Scar> scars;
  final AvatarV2MatureLines matureLines;

  AvatarV2Skin copyWith({
    AvatarV2SkinTone? tone,
    AvatarV2SkinUndertone? undertone,
    AvatarV2SkinTexture? texture,
    AvatarV2Freckles? freckles,
    AvatarV2Vitiligo? vitiligo,
    List<AvatarV2Birthmark>? birthmarks,
    List<AvatarV2Scar>? scars,
    AvatarV2MatureLines? matureLines,
  }) {
    return AvatarV2Skin(
      tone: tone ?? this.tone,
      undertone: undertone ?? this.undertone,
      texture: texture ?? this.texture,
      freckles: freckles ?? this.freckles,
      vitiligo: vitiligo ?? this.vitiligo,
      birthmarks: birthmarks ?? this.birthmarks,
      scars: scars ?? this.scars,
      matureLines: matureLines ?? this.matureLines,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tone': tone.name,
        'undertone': undertone.name,
        'texture': texture.name,
        'freckles': freckles.toJson(),
        'vitiligo': vitiligo.toJson(),
        'birthmarks': birthmarks.map((item) => item.toJson()).toList(growable: false),
        'scars': scars.map((item) => item.toJson()).toList(growable: false),
        'matureLines': matureLines.toJson(),
      };

  factory AvatarV2Skin.fromJson(Map<String, dynamic> json) => AvatarV2Skin(
        tone: _enumValue(json['tone'], AvatarV2SkinTone.values, AvatarV2SkinTone.medium),
        undertone: _enumValue(
          json['undertone'],
          AvatarV2SkinUndertone.values,
          AvatarV2SkinUndertone.neutral,
        ),
        texture: _enumValue(
          json['texture'],
          AvatarV2SkinTexture.values,
          AvatarV2SkinTexture.smoothNatural,
        ),
        freckles: AvatarV2Freckles.fromJson(_map(json['freckles'])),
        vitiligo: AvatarV2Vitiligo.fromJson(_map(json['vitiligo'])),
        birthmarks: _listOfMaps(json['birthmarks'])
            .map(AvatarV2Birthmark.fromJson)
            .toList(growable: false),
        scars: _listOfMaps(json['scars']).map(AvatarV2Scar.fromJson).toList(growable: false),
        matureLines: AvatarV2MatureLines.fromJson(_map(json['matureLines'])),
      );
}

@immutable
class AvatarV2Freckles {
  const AvatarV2Freckles({
    this.density = AvatarV2FreckleDensity.none,
    this.distribution = AvatarV2FreckleDistribution.noseAndCheeks,
  });

  final AvatarV2FreckleDensity density;
  final AvatarV2FreckleDistribution distribution;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'density': density.name,
        'distribution': distribution.name,
      };

  factory AvatarV2Freckles.fromJson(Map<String, dynamic> json) => AvatarV2Freckles(
        density: _enumValue(
          json['density'],
          AvatarV2FreckleDensity.values,
          AvatarV2FreckleDensity.none,
        ),
        distribution: _enumValue(
          json['distribution'],
          AvatarV2FreckleDistribution.values,
          AvatarV2FreckleDistribution.noseAndCheeks,
        ),
      );
}

@immutable
class AvatarV2Vitiligo {
  const AvatarV2Vitiligo({
    this.pattern = AvatarV2VitiligoPattern.none,
    this.intensity = AvatarV2DetailIntensity.subtle,
  });

  final AvatarV2VitiligoPattern pattern;
  final AvatarV2DetailIntensity intensity;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'pattern': pattern.name,
        'intensity': intensity.name,
      };

  factory AvatarV2Vitiligo.fromJson(Map<String, dynamic> json) => AvatarV2Vitiligo(
        pattern: _enumValue(
          json['pattern'],
          AvatarV2VitiligoPattern.values,
          AvatarV2VitiligoPattern.none,
        ),
        intensity: _enumValue(
          json['intensity'],
          AvatarV2DetailIntensity.values,
          AvatarV2DetailIntensity.subtle,
        ),
      );
}

@immutable
class AvatarV2Birthmark {
  const AvatarV2Birthmark({
    this.type = AvatarV2BirthmarkType.flatPatch,
    this.location = AvatarV2FaceRegion.leftCheek,
    this.size = AvatarV2DetailSize.medium,
    this.intensity = AvatarV2DetailIntensity.visible,
  });

  final AvatarV2BirthmarkType type;
  final AvatarV2FaceRegion location;
  final AvatarV2DetailSize size;
  final AvatarV2DetailIntensity intensity;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'location': location.name,
        'size': size.name,
        'intensity': intensity.name,
      };

  factory AvatarV2Birthmark.fromJson(Map<String, dynamic> json) => AvatarV2Birthmark(
        type: _enumValue(json['type'], AvatarV2BirthmarkType.values, AvatarV2BirthmarkType.flatPatch),
        location: _enumValue(json['location'], AvatarV2FaceRegion.values, AvatarV2FaceRegion.leftCheek),
        size: _enumValue(json['size'], AvatarV2DetailSize.values, AvatarV2DetailSize.medium),
        intensity: _enumValue(
          json['intensity'],
          AvatarV2DetailIntensity.values,
          AvatarV2DetailIntensity.visible,
        ),
      );
}

@immutable
class AvatarV2Scar {
  const AvatarV2Scar({
    this.type = AvatarV2ScarType.fineLine,
    this.location = AvatarV2FaceRegion.rightCheek,
    this.orientation = AvatarV2MarkOrientation.diagonal,
    this.size = AvatarV2DetailSize.medium,
    this.intensity = AvatarV2DetailIntensity.visible,
  });

  final AvatarV2ScarType type;
  final AvatarV2FaceRegion location;
  final AvatarV2MarkOrientation orientation;
  final AvatarV2DetailSize size;
  final AvatarV2DetailIntensity intensity;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'location': location.name,
        'orientation': orientation.name,
        'size': size.name,
        'intensity': intensity.name,
      };

  factory AvatarV2Scar.fromJson(Map<String, dynamic> json) => AvatarV2Scar(
        type: _enumValue(json['type'], AvatarV2ScarType.values, AvatarV2ScarType.fineLine),
        location: _enumValue(json['location'], AvatarV2FaceRegion.values, AvatarV2FaceRegion.rightCheek),
        orientation: _enumValue(
          json['orientation'],
          AvatarV2MarkOrientation.values,
          AvatarV2MarkOrientation.diagonal,
        ),
        size: _enumValue(json['size'], AvatarV2DetailSize.values, AvatarV2DetailSize.medium),
        intensity: _enumValue(
          json['intensity'],
          AvatarV2DetailIntensity.values,
          AvatarV2DetailIntensity.visible,
        ),
      );
}

@immutable
class AvatarV2MatureLines {
  const AvatarV2MatureLines({
    this.forehead = AvatarV2LineStrength.none,
    this.crowsFeet = AvatarV2LineStrength.none,
    this.smileLines = AvatarV2LineStrength.none,
    this.underEye = AvatarV2LineStrength.none,
    this.neck = AvatarV2LineStrength.none,
  });

  final AvatarV2LineStrength forehead;
  final AvatarV2LineStrength crowsFeet;
  final AvatarV2LineStrength smileLines;
  final AvatarV2LineStrength underEye;
  final AvatarV2LineStrength neck;

  bool get hasAny =>
      forehead != AvatarV2LineStrength.none ||
      crowsFeet != AvatarV2LineStrength.none ||
      smileLines != AvatarV2LineStrength.none ||
      underEye != AvatarV2LineStrength.none ||
      neck != AvatarV2LineStrength.none;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'forehead': forehead.name,
        'crowsFeet': crowsFeet.name,
        'smileLines': smileLines.name,
        'underEye': underEye.name,
        'neck': neck.name,
      };

  factory AvatarV2MatureLines.fromJson(Map<String, dynamic> json) => AvatarV2MatureLines(
        forehead: _enumValue(json['forehead'], AvatarV2LineStrength.values, AvatarV2LineStrength.none),
        crowsFeet: _enumValue(json['crowsFeet'], AvatarV2LineStrength.values, AvatarV2LineStrength.none),
        smileLines: _enumValue(json['smileLines'], AvatarV2LineStrength.values, AvatarV2LineStrength.none),
        underEye: _enumValue(json['underEye'], AvatarV2LineStrength.values, AvatarV2LineStrength.none),
        neck: _enumValue(json['neck'], AvatarV2LineStrength.values, AvatarV2LineStrength.none),
      );
}

@immutable
class AvatarV2Hair {
  const AvatarV2Hair({
    this.texture = AvatarV2HairTexture.wavy,
    this.style = AvatarV2HairStyle.shortWaves,
    this.length = AvatarV2HairLength.short,
    this.density = AvatarV2HairDensity.medium,
    this.volume = AvatarV2HairVolume.medium,
    this.parting = AvatarV2HairParting.none,
    this.hairline = AvatarV2Hairline.natural,
    this.colour = AvatarV2HairColour.brown,
    this.frontStrandPolicy = AvatarV2FrontStrandPolicy.noFaceOverlap,
  });

  final AvatarV2HairTexture texture;
  final AvatarV2HairStyle style;
  final AvatarV2HairLength length;
  final AvatarV2HairDensity density;
  final AvatarV2HairVolume volume;
  final AvatarV2HairParting parting;
  final AvatarV2Hairline hairline;
  final AvatarV2HairColour colour;
  final AvatarV2FrontStrandPolicy frontStrandPolicy;

  AvatarV2Hair copyWith({
    AvatarV2HairTexture? texture,
    AvatarV2HairStyle? style,
    AvatarV2HairLength? length,
    AvatarV2HairDensity? density,
    AvatarV2HairVolume? volume,
    AvatarV2HairParting? parting,
    AvatarV2Hairline? hairline,
    AvatarV2HairColour? colour,
    AvatarV2FrontStrandPolicy? frontStrandPolicy,
  }) {
    return AvatarV2Hair(
      texture: texture ?? this.texture,
      style: style ?? this.style,
      length: length ?? this.length,
      density: density ?? this.density,
      volume: volume ?? this.volume,
      parting: parting ?? this.parting,
      hairline: hairline ?? this.hairline,
      colour: colour ?? this.colour,
      frontStrandPolicy: frontStrandPolicy ?? this.frontStrandPolicy,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'texture': texture.name,
        'style': style.name,
        'length': length.name,
        'density': density.name,
        'volume': volume.name,
        'parting': parting.name,
        'hairline': hairline.name,
        'colour': colour.name,
        'frontStrandPolicy': frontStrandPolicy.name,
      };

  factory AvatarV2Hair.fromJson(Map<String, dynamic> json) => AvatarV2Hair(
        texture: _enumValue(json['texture'], AvatarV2HairTexture.values, AvatarV2HairTexture.wavy),
        style: _enumValue(json['style'], AvatarV2HairStyle.values, AvatarV2HairStyle.shortWaves),
        length: _enumValue(json['length'], AvatarV2HairLength.values, AvatarV2HairLength.short),
        density: _enumValue(json['density'], AvatarV2HairDensity.values, AvatarV2HairDensity.medium),
        volume: _enumValue(json['volume'], AvatarV2HairVolume.values, AvatarV2HairVolume.medium),
        parting: _enumValue(json['parting'], AvatarV2HairParting.values, AvatarV2HairParting.none),
        hairline: _enumValue(json['hairline'], AvatarV2Hairline.values, AvatarV2Hairline.natural),
        colour: _enumValue(json['colour'], AvatarV2HairColour.values, AvatarV2HairColour.brown),
        frontStrandPolicy: _enumValue(
          json['frontStrandPolicy'],
          AvatarV2FrontStrandPolicy.values,
          AvatarV2FrontStrandPolicy.noFaceOverlap,
        ),
      );
}

@immutable
class AvatarV2FacialHair {
  const AvatarV2FacialHair({
    this.type = AvatarV2FacialHairType.none,
    this.density = AvatarV2FacialHairDensity.medium,
    this.length = AvatarV2FacialHairLength.short,
    this.colour = AvatarV2HairColour.brown,
    this.moustache = AvatarV2MoustacheStyle.none,
    this.cheekCoverage = AvatarV2CheekCoverage.none,
    this.jawCoverage = AvatarV2JawCoverage.none,
    this.chinCoverage = AvatarV2ChinCoverage.none,
  });

  final AvatarV2FacialHairType type;
  final AvatarV2FacialHairDensity density;
  final AvatarV2FacialHairLength length;
  final AvatarV2HairColour colour;
  final AvatarV2MoustacheStyle moustache;
  final AvatarV2CheekCoverage cheekCoverage;
  final AvatarV2JawCoverage jawCoverage;
  final AvatarV2ChinCoverage chinCoverage;

  bool get isNone => type == AvatarV2FacialHairType.none;

  AvatarV2FacialHair copyWith({
    AvatarV2FacialHairType? type,
    AvatarV2FacialHairDensity? density,
    AvatarV2FacialHairLength? length,
    AvatarV2HairColour? colour,
    AvatarV2MoustacheStyle? moustache,
    AvatarV2CheekCoverage? cheekCoverage,
    AvatarV2JawCoverage? jawCoverage,
    AvatarV2ChinCoverage? chinCoverage,
  }) {
    return AvatarV2FacialHair(
      type: type ?? this.type,
      density: density ?? this.density,
      length: length ?? this.length,
      colour: colour ?? this.colour,
      moustache: moustache ?? this.moustache,
      cheekCoverage: cheekCoverage ?? this.cheekCoverage,
      jawCoverage: jawCoverage ?? this.jawCoverage,
      chinCoverage: chinCoverage ?? this.chinCoverage,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'density': density.name,
        'length': length.name,
        'colour': colour.name,
        'moustache': moustache.name,
        'cheekCoverage': cheekCoverage.name,
        'jawCoverage': jawCoverage.name,
        'chinCoverage': chinCoverage.name,
      };

  factory AvatarV2FacialHair.fromJson(Map<String, dynamic> json) => AvatarV2FacialHair(
        type: _enumValue(json['type'], AvatarV2FacialHairType.values, AvatarV2FacialHairType.none),
        density: _enumValue(
          json['density'],
          AvatarV2FacialHairDensity.values,
          AvatarV2FacialHairDensity.medium,
        ),
        length: _enumValue(json['length'], AvatarV2FacialHairLength.values, AvatarV2FacialHairLength.short),
        colour: _enumValue(json['colour'], AvatarV2HairColour.values, AvatarV2HairColour.brown),
        moustache: _enumValue(
          json['moustache'],
          AvatarV2MoustacheStyle.values,
          AvatarV2MoustacheStyle.none,
        ),
        cheekCoverage: _enumValue(
          json['cheekCoverage'],
          AvatarV2CheekCoverage.values,
          AvatarV2CheekCoverage.none,
        ),
        jawCoverage: _enumValue(json['jawCoverage'], AvatarV2JawCoverage.values, AvatarV2JawCoverage.none),
        chinCoverage: _enumValue(
          json['chinCoverage'],
          AvatarV2ChinCoverage.values,
          AvatarV2ChinCoverage.none,
        ),
      );
}

@immutable
class AvatarV2Body {
  const AvatarV2Body({
    this.frame = AvatarV2BodyFrame.average,
    this.shoulderWidth = AvatarV2ShoulderWidth.medium,
    this.neck = AvatarV2NeckStyle.average,
    this.posture = AvatarV2Posture.relaxed,
    this.visibleRange = AvatarV2VisibleRange.headAndShoulders,
  });

  final AvatarV2BodyFrame frame;
  final AvatarV2ShoulderWidth shoulderWidth;
  final AvatarV2NeckStyle neck;
  final AvatarV2Posture posture;
  final AvatarV2VisibleRange visibleRange;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'frame': frame.name,
        'shoulderWidth': shoulderWidth.name,
        'neck': neck.name,
        'posture': posture.name,
        'visibleRange': visibleRange.name,
      };

  factory AvatarV2Body.fromJson(Map<String, dynamic> json) => AvatarV2Body(
        frame: _enumValue(json['frame'], AvatarV2BodyFrame.values, AvatarV2BodyFrame.average),
        shoulderWidth: _enumValue(
          json['shoulderWidth'],
          AvatarV2ShoulderWidth.values,
          AvatarV2ShoulderWidth.medium,
        ),
        neck: _enumValue(json['neck'], AvatarV2NeckStyle.values, AvatarV2NeckStyle.average),
        posture: _enumValue(json['posture'], AvatarV2Posture.values, AvatarV2Posture.relaxed),
        visibleRange: _enumValue(
          json['visibleRange'],
          AvatarV2VisibleRange.values,
          AvatarV2VisibleRange.headAndShoulders,
        ),
      );
}

@immutable
class AvatarV2Accessibility {
  const AvatarV2Accessibility({
    this.glasses = AvatarV2Glasses.none,
    this.hearingAid = AvatarV2HearingAid.none,
    this.cochlearImplant = AvatarV2CochlearImplant.none,
    this.medicalPatch = AvatarV2MedicalPatch.none,
    this.glucoseMonitor = AvatarV2GlucoseMonitor.none,
    this.sensoryHeadphones = AvatarV2SensoryHeadphones.none,
    this.mobilityAid = AvatarV2MobilityAid.none,
  });

  final AvatarV2Glasses glasses;
  final AvatarV2HearingAid hearingAid;
  final AvatarV2CochlearImplant cochlearImplant;
  final AvatarV2MedicalPatch medicalPatch;
  final AvatarV2GlucoseMonitor glucoseMonitor;
  final AvatarV2SensoryHeadphones sensoryHeadphones;
  final AvatarV2MobilityAid mobilityAid;

  bool get hasVisibleHeadItem =>
      glasses != AvatarV2Glasses.none ||
      hearingAid != AvatarV2HearingAid.none ||
      cochlearImplant != AvatarV2CochlearImplant.none ||
      sensoryHeadphones != AvatarV2SensoryHeadphones.none;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'glasses': glasses.name,
        'hearingAid': hearingAid.name,
        'cochlearImplant': cochlearImplant.name,
        'medicalPatch': medicalPatch.name,
        'glucoseMonitor': glucoseMonitor.name,
        'sensoryHeadphones': sensoryHeadphones.name,
        'mobilityAid': mobilityAid.name,
      };

  factory AvatarV2Accessibility.fromJson(Map<String, dynamic> json) => AvatarV2Accessibility(
        glasses: _enumValue(json['glasses'], AvatarV2Glasses.values, AvatarV2Glasses.none),
        hearingAid: _enumValue(json['hearingAid'], AvatarV2HearingAid.values, AvatarV2HearingAid.none),
        cochlearImplant: _enumValue(
          json['cochlearImplant'],
          AvatarV2CochlearImplant.values,
          AvatarV2CochlearImplant.none,
        ),
        medicalPatch: _enumValue(json['medicalPatch'], AvatarV2MedicalPatch.values, AvatarV2MedicalPatch.none),
        glucoseMonitor: _enumValue(
          json['glucoseMonitor'],
          AvatarV2GlucoseMonitor.values,
          AvatarV2GlucoseMonitor.none,
        ),
        sensoryHeadphones: _enumValue(
          json['sensoryHeadphones'],
          AvatarV2SensoryHeadphones.values,
          AvatarV2SensoryHeadphones.none,
        ),
        mobilityAid: _enumValue(json['mobilityAid'], AvatarV2MobilityAid.values, AvatarV2MobilityAid.none),
      );
}

@immutable
class AvatarV2Clothing {
  const AvatarV2Clothing({
    this.top = AvatarV2TopClothing.hoodie,
    this.colour = AvatarV2ClothingColour.teal,
    this.accessory = AvatarV2ClothingAccessory.none,
  });

  final AvatarV2TopClothing top;
  final AvatarV2ClothingColour colour;
  final AvatarV2ClothingAccessory accessory;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'top': top.name,
        'colour': colour.name,
        'accessory': accessory.name,
      };

  factory AvatarV2Clothing.fromJson(Map<String, dynamic> json) => AvatarV2Clothing(
        top: _enumValue(json['top'], AvatarV2TopClothing.values, AvatarV2TopClothing.hoodie),
        colour: _enumValue(json['colour'], AvatarV2ClothingColour.values, AvatarV2ClothingColour.teal),
        accessory: _enumValue(
          json['accessory'],
          AvatarV2ClothingAccessory.values,
          AvatarV2ClothingAccessory.none,
        ),
      );
}

@immutable
class AvatarV2ReferenceImage {
  const AvatarV2ReferenceImage({
    required this.sourceType,
    this.localPath,
    this.remoteUrl,
    this.consentGranted = false,
    this.cropX = 0.5,
    this.cropY = 0.5,
    this.cropScale = 1.0,
  });

  const AvatarV2ReferenceImage.none()
      : sourceType = AvatarV2ReferenceImageSource.none,
        localPath = null,
        remoteUrl = null,
        consentGranted = false,
        cropX = 0.5,
        cropY = 0.5,
        cropScale = 1.0;

  final AvatarV2ReferenceImageSource sourceType;
  final String? localPath;
  final String? remoteUrl;
  final bool consentGranted;
  final double cropX;
  final double cropY;
  final double cropScale;

  bool get hasImage =>
      sourceType != AvatarV2ReferenceImageSource.none &&
      ((localPath?.isNotEmpty ?? false) || (remoteUrl?.isNotEmpty ?? false));

  Map<String, dynamic> toJson() => <String, dynamic>{
        'sourceType': sourceType.name,
        if (localPath != null) 'localPath': localPath,
        if (remoteUrl != null) 'remoteUrl': remoteUrl,
        'consentGranted': consentGranted,
        'cropX': cropX,
        'cropY': cropY,
        'cropScale': cropScale,
      };

  factory AvatarV2ReferenceImage.fromJson(Map<String, dynamic> json) => AvatarV2ReferenceImage(
        sourceType: _enumValue(
          json['sourceType'],
          AvatarV2ReferenceImageSource.values,
          AvatarV2ReferenceImageSource.none,
        ),
        localPath: json['localPath'] as String?,
        remoteUrl: json['remoteUrl'] as String?,
        consentGranted: json['consentGranted'] == true,
        cropX: _double(json['cropX'], 0.5),
        cropY: _double(json['cropY'], 0.5),
        cropScale: _double(json['cropScale'], 1.0),
      );
}

enum AvatarV2Mode { looksLikeMe, inspiredByMe, privateAbstract }
enum AvatarV2RenderMode { realtimeVector, assetLayered, generatedImage, hybrid }
enum AvatarV2RealismLevel { soft, semiRealistic, realistic }
enum AvatarV2LightingStyle { softStudio, naturalDaylight, warmRoom, dramatic, flatAccessible }
enum AvatarV2CameraStyle { headOnly, headAndShoulders, upperBody }
enum AvatarV2AgePresentation { child, preTeen, teen, youngAdult, adult, olderAdult }
enum AvatarV2FaceShape { oval, round, square, heart, diamond, long }
enum AvatarV2JawShape { soft, defined, square, narrow, rounded }
enum AvatarV2CheekboneStyle { soft, medium, high, full }
enum AvatarV2ChinStyle { rounded, pointed, square, cleft, soft }
enum AvatarV2NoseShape { small, medium, broad, narrow, aquiline, button, rounded }
enum AvatarV2EyeShape { almond, round, hooded, monolid, deepSet, upturned, downturned }
enum AvatarV2EyeColour { brown, darkBrown, hazel, green, blue, grey, amber }
enum AvatarV2EyebrowShape { natural, straight, arched, thick, thin, soft }
enum AvatarV2MouthShape { neutral, softSmile, full, narrow, wide, downturned }
enum AvatarV2EarSize { small, medium, large }
enum AvatarV2Expression { calm, neutral, happy, focused, playful, proud }
enum AvatarV2SkinTone { veryLight, light, medium, olive, tan, brown, deepBrown, veryDeep }
enum AvatarV2SkinUndertone { cool, neutral, warm, golden, red }
enum AvatarV2SkinTexture { smoothNatural, textured, acneScarring, mature, dry, oily }
enum AvatarV2FreckleDensity { none, light, medium, heavy }
enum AvatarV2FreckleDistribution { noseOnly, noseAndCheeks, fullFace, shouldersVisible }
enum AvatarV2VitiligoPattern { none, cheekPatch, foreheadPatch, aroundEyes, aroundMouth, bilateral, asymmetrical }
enum AvatarV2DetailIntensity { subtle, visible, strong }
enum AvatarV2BirthmarkType { flatPatch, beautyMark, portWineStain, moleCluster, cafeAuLait }
enum AvatarV2FaceRegion { forehead, leftCheek, rightCheek, noseBridge, mouthCorner, chin, jaw, neck, shoulder }
enum AvatarV2DetailSize { small, medium, large }
enum AvatarV2ScarType { fineLine, raisedScar, surgicalScar, burnScar, acneScarring }
enum AvatarV2MarkOrientation { vertical, horizontal, diagonal, curved }
enum AvatarV2LineStrength { none, subtle, visible, deep }
enum AvatarV2HairTexture { straight, wavy, curly, coily, afro, locs, braids, twists, shaved, bald, covered }
enum AvatarV2HairStyle {
  shortCrop,
  buzzCut,
  fade,
  bob,
  ponytail,
  bun,
  shortWaves,
  layeredWaves,
  shortCurls,
  shoulderCurls,
  longCurls,
  curlyPuff,
  coilyCrop,
  taperedCoils,
  miniAfro,
  fullAfro,
  roundedAfro,
  taperedAfro,
  sidePartAfro,
  afroPuff,
  twinPuffs,
  shortLocs,
  locBob,
  shoulderLocs,
  longLocs,
  locBun,
  cornrows,
  boxBraids,
  braidBob,
  longBraids,
  braidedPonytail,
  shortTwists,
  twistBob,
  longTwists,
  flatTwists,
  headwrap,
  covered,
}
enum AvatarV2HairLength { bald, shaved, short, medium, shoulder, long }
enum AvatarV2HairDensity { fine, medium, thick, dense }
enum AvatarV2HairVolume { flat, low, medium, high, halo }
enum AvatarV2HairParting { none, centre, left, right, side }
enum AvatarV2Hairline { natural, low, high, widowPeak, receding, shaved }
enum AvatarV2HairColour { black, darkBrown, brown, lightBrown, blonde, ginger, auburn, copper, grey, white, dyed }
enum AvatarV2FrontStrandPolicy { noFaceOverlap, fringeAllowed, sideOnly, covered }
enum AvatarV2FacialHairType { none, stubble, moustache, goatee, shortBeard, fullBeard, sideburns }
enum AvatarV2FacialHairDensity { light, medium, dense }
enum AvatarV2FacialHairLength { shadow, short, medium, long }
enum AvatarV2MoustacheStyle { none, light, natural, thick, handlebar }
enum AvatarV2CheekCoverage { none, low, medium, full }
enum AvatarV2JawCoverage { none, jawOnly, jawAndChin, full }
enum AvatarV2ChinCoverage { none, chinPatch, goatee, full }
enum AvatarV2BodyFrame { petite, slim, average, broad, larger, muscular }
enum AvatarV2ShoulderWidth { narrow, medium, broad }
enum AvatarV2NeckStyle { short, average, long }
enum AvatarV2Posture { relaxed, upright, leaning, seated }
enum AvatarV2VisibleRange { headOnly, headAndShoulders, upperBody }
enum AvatarV2Glasses { none, round, square, rectangle, catEye, aviator }
enum AvatarV2HearingAid { none, left, right, both }
enum AvatarV2CochlearImplant { none, left, right }
enum AvatarV2MedicalPatch { none, leftArm, rightArm, chest, neck }
enum AvatarV2GlucoseMonitor { none, leftArm, rightArm, abdomen }
enum AvatarV2SensoryHeadphones { none, onEar, overEar }
enum AvatarV2MobilityAid { none, wheelchairHint, caneHint, crutchesHint }
enum AvatarV2TopClothing { hoodie, tshirt, jumper, shirt, blouse, dress, schoolUniform, workwear, sportswear }
enum AvatarV2ClothingColour { teal, blue, red, pink, purple, green, yellow, black, white, grey }
enum AvatarV2ClothingAccessory { none, necklace, scarf, badge }
enum AvatarV2ReferenceImageSource { none, localFile, remoteUrl }

extension AvatarV2EnumLabel on Enum {
  String get label {
    final words = name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    return words[0].toUpperCase() + words.substring(1);
  }
}

T _enumValue<T extends Enum>(Object? value, List<T> values, T fallback) {
  if (value is String) {
    for (final item in values) {
      if (item.name == value) return item;
    }
  }
  return fallback;
}

String _string(Object? value, String fallback) => value is String ? value : fallback;

double _double(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value.whereType<Map>().map(Map<String, dynamic>.from).toList(growable: false);
}
