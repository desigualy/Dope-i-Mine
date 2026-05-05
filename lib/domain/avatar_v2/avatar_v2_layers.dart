import 'avatar_v2_profile.dart';

/// Anatomical layer order for Avatar V2.
///
/// This is the part the legacy renderer lacked. Hair, face, facial hair,
/// glasses, and accessibility items must have an enforced order or the avatar
/// quickly becomes visually offensive.
enum AvatarV2LayerSlot {
  background,
  rearAccessories,
  backHair,
  shoulders,
  neck,
  earsBack,
  headSkin,
  earsFront,
  scalpHairCap,
  skinDetails,
  matureLines,
  eyebrows,
  eyes,
  nose,
  mouth,
  facialHair,
  glasses,
  hearingDevices,
  medicalDevices,
  safeFrontHair,
  clothing,
  foregroundEffects,
}

class AvatarV2LayerSpec {
  const AvatarV2LayerSpec({
    required this.slot,
    required this.id,
    required this.description,
    this.canOverlapFace = false,
    this.requiresFaceExclusionMask = false,
  });

  final AvatarV2LayerSlot slot;
  final String id;
  final String description;
  final bool canOverlapFace;
  final bool requiresFaceExclusionMask;
}

class AvatarV2LayerPlan {
  const AvatarV2LayerPlan(this.layers);

  final List<AvatarV2LayerSpec> layers;

  List<AvatarV2LayerSpec> get ordered {
    final copy = List<AvatarV2LayerSpec>.from(layers);
    copy.sort((a, b) => a.slot.index.compareTo(b.slot.index));
    return copy;
  }

  bool get hasUnsafeFaceOverlap {
    return ordered.any(
      (layer) => layer.requiresFaceExclusionMask && layer.canOverlapFace,
    );
  }
}

class AvatarV2LayerPlanner {
  const AvatarV2LayerPlanner();

  AvatarV2LayerPlan planFor(AvatarV2Profile profile) {
    final layers = <AvatarV2LayerSpec>[
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.background,
        id: 'background.gradient',
        description: 'Soft app background gradient',
      ),
    ];

    if (profile.mode == AvatarV2Mode.privateAbstract) {
      layers.addAll(const <AvatarV2LayerSpec>[
        AvatarV2LayerSpec(
          slot: AvatarV2LayerSlot.foregroundEffects,
          id: 'private.abstract.mark',
          description: 'Privacy-first abstract identity mark',
        ),
      ]);
      return AvatarV2LayerPlan(layers);
    }

    layers.addAll(<AvatarV2LayerSpec>[
      _hairBack(profile),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.shoulders,
        id: 'body.shoulders',
        description: 'Shoulders and upper body frame',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.neck,
        id: 'body.neck',
        description: 'Neck layer with posture-aware proportions',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.earsBack,
        id: 'face.ears.back',
        description: 'Rear ear structure',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.headSkin,
        id: 'face.head.skin',
        description: 'Face and head skin surface',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.earsFront,
        id: 'face.ears.front',
        description: 'Visible ear rim',
      ),
      _hairCap(profile),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.skinDetails,
        id: 'skin.details',
        description: 'Birthmarks, scars, freckles, vitiligo',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.matureLines,
        id: 'skin.mature_lines',
        description: 'Mature lines and expression lines',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.eyebrows,
        id: 'face.eyebrows',
        description: 'Eyebrows',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.eyes,
        id: 'face.eyes',
        description: 'Eyes',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.nose,
        id: 'face.nose',
        description: 'Nose',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.mouth,
        id: 'face.mouth',
        description: 'Mouth',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.facialHair,
        id: 'face.facial_hair',
        description: 'Lower-face facial hair only',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.glasses,
        id: 'accessibility.glasses',
        description: 'Glasses correctly aligned to eyes and nose bridge',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.hearingDevices,
        id: 'accessibility.hearing',
        description: 'Hearing aids or cochlear implant placement',
      ),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.medicalDevices,
        id: 'accessibility.medical',
        description: 'Medical patch or glucose monitor',
      ),
      _safeFrontHair(profile),
      const AvatarV2LayerSpec(
        slot: AvatarV2LayerSlot.clothing,
        id: 'clothing.visible',
        description: 'Visible clothing and neckline',
      ),
    ]);

    return AvatarV2LayerPlan(layers);
  }

  AvatarV2LayerSpec _hairBack(AvatarV2Profile profile) {
    return AvatarV2LayerSpec(
      slot: AvatarV2LayerSlot.backHair,
      id: 'hair.back.${profile.hair.texture.name}.${profile.hair.style.name}',
      description: 'Back hair, crown mass, side volume, locs, braids, twists',
      requiresFaceExclusionMask: true,
    );
  }

  AvatarV2LayerSpec _hairCap(AvatarV2Profile profile) {
    return AvatarV2LayerSpec(
      slot: AvatarV2LayerSlot.scalpHairCap,
      id: 'hair.scalp_cap.${profile.hair.style.name}',
      description: 'Safe scalp cap and hairline roots',
      requiresFaceExclusionMask: true,
    );
  }

  AvatarV2LayerSpec _safeFrontHair(AvatarV2Profile profile) {
    final allowsFringe =
        profile.hair.frontStrandPolicy == AvatarV2FrontStrandPolicy.fringeAllowed;
    return AvatarV2LayerSpec(
      slot: AvatarV2LayerSlot.safeFrontHair,
      id: 'hair.front.${profile.hair.frontStrandPolicy.name}',
      description: allowsFringe
          ? 'Small fringe only, clipped above the eyebrow line'
          : 'No front-face hair overlap',
      canOverlapFace: allowsFringe,
      requiresFaceExclusionMask: true,
    );
  }
}

class AvatarV2AnatomyZones {
  const AvatarV2AnatomyZones._();

  static const String scalp = 'scalp';
  static const String crownHalo = 'crown_halo';
  static const String templeSide = 'temple_side';
  static const String shoulderSide = 'shoulder_side';
  static const String eyeZone = 'eye_zone';
  static const String noseZone = 'nose_zone';
  static const String mouthZone = 'mouth_zone';
  static const String moustacheZone = 'moustache_zone';
  static const String chinZone = 'chin_zone';
  static const String jawZone = 'jaw_zone';

  static const Set<String> headHairAllowedZones = <String>{
    scalp,
    crownHalo,
    templeSide,
    shoulderSide,
  };

  static const Set<String> headHairForbiddenZones = <String>{
    eyeZone,
    noseZone,
    mouthZone,
    moustacheZone,
    chinZone,
    jawZone,
  };

  static const Set<String> facialHairAllowedZones = <String>{
    moustacheZone,
    chinZone,
    jawZone,
  };
}
