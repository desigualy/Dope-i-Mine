class AvatarV4RiveContract {
  const AvatarV4RiveContract._();

  static const String baseRigAssetPath = 'assets/avatar_rive/base_avatar.riv';
  static const String artboardName = 'Avatar';
  static const String stateMachineName = 'AvatarState';

  static const String skinToneInput = 'skinTone';
  static const String faceShapeInput = 'faceShape';
  static const String hairPackInput = 'hairPack';
  static const String hairStyleInput = 'hairStyle';
  static const String hairColorInput = 'hairColor';
  static const String bodyPresetInput = 'bodyPreset';

  static const String frecklesInput = 'freckles';
  static const String vitiligoInput = 'vitiligo';
  static const String hasFacialHairInput = 'hasFacialHair';
  static const String hasGlassesInput = 'hasGlasses';

  static const List<String> requiredNumberInputs = <String>[
    skinToneInput,
    faceShapeInput,
    hairPackInput,
    hairStyleInput,
    hairColorInput,
    bodyPresetInput,
  ];

  static const List<String> requiredBooleanInputs = <String>[
    frecklesInput,
    vitiligoInput,
    hasFacialHairInput,
    hasGlassesInput,
  ];

  static const List<String> requiredInputs = <String>[
    ...requiredNumberInputs,
    ...requiredBooleanInputs,
  ];

  static const Map<String, String> inputDescriptions = <String, String>{
    skinToneInput: 'Number 0..1. Drives material/skin palette selection.',
    faceShapeInput: 'Number 0..1. Drives head/face shape blend selection.',
    hairPackInput: 'Number 0..1. Selects installed hair pack family.',
    hairStyleInput: 'Number 0..1. Selects style inside the active hair pack.',
    hairColorInput: 'Number 0..1. Selects hair material/color palette.',
    bodyPresetInput: 'Number 0..1. Selects body presentation preset.',
    frecklesInput: 'Boolean. Enables freckle detail layer.',
    vitiligoInput: 'Boolean. Enables vitiligo detail layer.',
    hasFacialHairInput: 'Boolean. Enables facial hair group.',
    hasGlassesInput: 'Boolean. Enables glasses/accessory group.',
  };

  static bool isRequiredInput(String name) => requiredInputs.contains(name);

  static bool isRequiredNumberInput(String name) =>
      requiredNumberInputs.contains(name);

  static bool isRequiredBooleanInput(String name) =>
      requiredBooleanInputs.contains(name);
}
