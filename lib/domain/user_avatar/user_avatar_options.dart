import 'user_avatar_profile.dart';

class UserAvatarOption {
  const UserAvatarOption({
    required this.id,
    required this.label,
    this.description,
    this.freeForever = true,
    this.identityRepresentation = true,
  });

  final String id;
  final String label;
  final String? description;
  final bool freeForever;
  final bool identityRepresentation;
}

class UserAvatarOptions {
  const UserAvatarOptions._();

  static const List<UserAvatarOption> avatarTypes = <UserAvatarOption>[
    UserAvatarOption(
      id: UserAvatarProfile.avatarTypeLooksLikeMe,
      label: 'Looks like me',
      description: 'Closest soft portrait likeness with natural proportions.',
    ),
    UserAvatarOption(
      id: UserAvatarProfile.avatarTypeInspiredByMe,
      label: 'Inspired by me',
      description: 'A recognisable portrait, gently stylised without pressure.',
    ),
    UserAvatarOption(
      id: UserAvatarProfile.avatarTypePrivateAbstract,
      label: 'Private / abstract',
      description: 'A non-identifying colour, shape, initials, or symbol mark.',
    ),
  ];

  static const List<UserAvatarOption> agePresentations = <UserAvatarOption>[
    UserAvatarOption(id: 'child', label: 'Child'),
    UserAvatarOption(id: 'pre_teen', label: 'Pre-teen'),
    UserAvatarOption(id: 'teen', label: 'Teen'),
    UserAvatarOption(id: 'young_adult', label: 'Young adult'),
    UserAvatarOption(id: 'adult', label: 'Adult'),
    UserAvatarOption(id: 'older_adult', label: 'Older adult'),
  ];

  static const List<UserAvatarOption> skinTones = <UserAvatarOption>[
    UserAvatarOption(id: 'very_light', label: 'Very light'),
    UserAvatarOption(id: 'light', label: 'Light'),
    UserAvatarOption(id: 'medium', label: 'Medium'),
    UserAvatarOption(id: 'olive', label: 'Olive'),
    UserAvatarOption(id: 'tan', label: 'Tan'),
    UserAvatarOption(id: 'brown', label: 'Brown'),
    UserAvatarOption(id: 'deep_brown', label: 'Deep brown'),
    UserAvatarOption(id: 'very_deep', label: 'Very deep'),
    UserAvatarOption(id: 'custom', label: 'Custom'),
  ];

  static const List<UserAvatarOption> skinDetails = <UserAvatarOption>[
    UserAvatarOption(id: 'vitiligo', label: 'Vitiligo pattern'),
    UserAvatarOption(id: 'freckles', label: 'Freckles'),
    UserAvatarOption(id: 'birthmark', label: 'Birthmark'),
    UserAvatarOption(id: 'scar', label: 'Scar'),
    UserAvatarOption(id: 'rosacea_blush', label: 'Rosacea / blush tone'),
  ];

  static const List<UserAvatarOption> hairTypes = <UserAvatarOption>[
    UserAvatarOption(id: 'straight', label: 'Straight'),
    UserAvatarOption(id: 'wavy', label: 'Wavy'),
    UserAvatarOption(id: 'curly', label: 'Curly'),
    UserAvatarOption(id: 'coily', label: 'Coily'),
    UserAvatarOption(id: 'afro_textured', label: 'Afro-textured'),
    UserAvatarOption(id: 'locs', label: 'Locs'),
    UserAvatarOption(id: 'braids', label: 'Braids'),
    UserAvatarOption(id: 'twists', label: 'Twists'),
    UserAvatarOption(id: 'shaved', label: 'Shaved'),
    UserAvatarOption(id: 'bald', label: 'Bald'),
  ];

  static const List<UserAvatarOption> hairStyles = <UserAvatarOption>[
    UserAvatarOption(id: 'buzz_cut', label: 'Buzz cut'),
    UserAvatarOption(id: 'fade', label: 'Fade'),
    UserAvatarOption(id: 'undercut', label: 'Undercut'),
    UserAvatarOption(id: 'bob', label: 'Bob'),
    UserAvatarOption(id: 'ponytail', label: 'Ponytail'),
    UserAvatarOption(id: 'bun', label: 'Bun'),
    UserAvatarOption(id: 'afro', label: 'Afro'),
    UserAvatarOption(id: 'cornrows', label: 'Cornrows'),
    UserAvatarOption(id: 'box_braids', label: 'Box braids'),
    UserAvatarOption(id: 'hidden_hair', label: 'Hidden hair / head covering'),
    UserAvatarOption(id: 'headwrap', label: 'Headwrap'),
  ];

  static const List<UserAvatarOption> hairColors = <UserAvatarOption>[
    UserAvatarOption(id: 'black', label: 'Black'),
    UserAvatarOption(id: 'brown', label: 'Brown'),
    UserAvatarOption(id: 'blonde', label: 'Blonde'),
    UserAvatarOption(id: 'ginger', label: 'Ginger'),
    UserAvatarOption(id: 'grey', label: 'Grey'),
    UserAvatarOption(id: 'white', label: 'White'),
    UserAvatarOption(id: 'dyed', label: 'Dyed colour'),
    UserAvatarOption(id: 'custom', label: 'Custom colour'),
  ];

  static const List<UserAvatarOption> faceOptions = <UserAvatarOption>[
    UserAvatarOption(id: 'eyes', label: 'Eyes'),
    UserAvatarOption(id: 'eyebrows', label: 'Eyebrows'),
    UserAvatarOption(id: 'nose', label: 'Nose'),
    UserAvatarOption(id: 'mouth', label: 'Mouth'),
    UserAvatarOption(id: 'facial_hair', label: 'Facial hair'),
    UserAvatarOption(id: 'glasses', label: 'Glasses'),
    UserAvatarOption(id: 'makeup', label: 'Makeup'),
    UserAvatarOption(id: 'wrinkles', label: 'Wrinkles'),
    UserAvatarOption(id: 'smile_lines', label: 'Smile lines'),
    UserAvatarOption(id: 'dimples', label: 'Dimples'),
  ];

  static const List<UserAvatarOption> bodyShapes = <UserAvatarOption>[
    UserAvatarOption(id: 'slim', label: 'Slim'),
    UserAvatarOption(id: 'average', label: 'Average'),
    UserAvatarOption(id: 'broad', label: 'Broad'),
    UserAvatarOption(id: 'larger_body', label: 'Larger body'),
    UserAvatarOption(id: 'muscular', label: 'Muscular'),
    UserAvatarOption(id: 'petite', label: 'Petite'),
    UserAvatarOption(id: 'tall', label: 'Tall'),
    UserAvatarOption(id: 'short', label: 'Short'),
    UserAvatarOption(id: 'wheelchair_seated', label: 'Wheelchair seated'),
  ];

  static const List<UserAvatarOption> accessibilityItems = <UserAvatarOption>[
    UserAvatarOption(id: 'glasses', label: 'Glasses'),
    UserAvatarOption(id: 'hearing_aids', label: 'Hearing aids'),
    UserAvatarOption(id: 'cochlear_implant', label: 'Cochlear implant'),
    UserAvatarOption(id: 'wheelchair', label: 'Wheelchair'),
    UserAvatarOption(id: 'walking_stick', label: 'Walking stick'),
    UserAvatarOption(id: 'crutches', label: 'Crutches'),
    UserAvatarOption(id: 'prosthetic_arm', label: 'Prosthetic arm'),
    UserAvatarOption(id: 'prosthetic_leg', label: 'Prosthetic leg'),
    UserAvatarOption(id: 'limb_difference', label: 'Limb difference'),
    UserAvatarOption(id: 'medical_patch', label: 'Medical patch'),
    UserAvatarOption(id: 'glucose_monitor', label: 'Glucose monitor'),
    UserAvatarOption(id: 'insulin_pump', label: 'Insulin pump'),
    UserAvatarOption(id: 'sensory_headphones', label: 'Sensory headphones'),
    UserAvatarOption(id: 'accessibility_badge', label: 'Accessibility badge'),
  ];

  static const List<UserAvatarOption> clothingItems = <UserAvatarOption>[
    UserAvatarOption(id: 'hoodie', label: 'Hoodie'),
    UserAvatarOption(id: 't_shirt', label: 'T-shirt'),
    UserAvatarOption(id: 'jumper', label: 'Jumper'),
    UserAvatarOption(id: 'school_uniform', label: 'School uniform'),
    UserAvatarOption(id: 'smart_casual', label: 'Smart casual'),
    UserAvatarOption(id: 'workwear', label: 'Workwear'),
    UserAvatarOption(id: 'pyjamas', label: 'Pyjamas'),
    UserAvatarOption(id: 'sportswear', label: 'Sportswear'),
    UserAvatarOption(id: 'dress', label: 'Dress'),
    UserAvatarOption(id: 'skirt', label: 'Skirt'),
    UserAvatarOption(id: 'jeans', label: 'Jeans'),
    UserAvatarOption(id: 'leggings', label: 'Leggings'),
    UserAvatarOption(id: 'coat', label: 'Coat'),
  ];

  static const List<UserAvatarOption> culturalItems = <UserAvatarOption>[
    UserAvatarOption(id: 'hijab', label: 'Hijab'),
    UserAvatarOption(id: 'turban', label: 'Turban'),
    UserAvatarOption(id: 'headwrap', label: 'Headwrap'),
    UserAvatarOption(id: 'kippah', label: 'Kippah'),
    UserAvatarOption(id: 'modest_clothing', label: 'Modest clothing'),
  ];

  static const List<UserAvatarOption> stylePreferences = <UserAvatarOption>[
    UserAvatarOption(id: 'soft_illustrated', label: 'Soft illustrated'),
    UserAvatarOption(id: 'masculine', label: 'Masculine'),
    UserAvatarOption(id: 'feminine', label: 'Feminine'),
    UserAvatarOption(id: 'androgynous', label: 'Androgynous'),
    UserAvatarOption(id: 'neutral', label: 'Neutral'),
    UserAvatarOption(id: 'expressive', label: 'Expressive'),
  ];

  static const List<UserAvatarOption> avatarStyleModes = <UserAvatarOption>[
    UserAvatarOption(id: 'portrait_soft', label: 'Soft portrait'),
    UserAvatarOption(id: 'portrait_detailed', label: 'Detailed portrait'),
    UserAvatarOption(id: 'abstract_private', label: 'Private abstract'),
  ];

  static const List<UserAvatarOption> privacyFirstOptions = <UserAvatarOption>[
    UserAvatarOption(id: 'colour_field', label: 'Colour field'),
    UserAvatarOption(id: 'gradient_orb', label: 'Gradient orb'),
    UserAvatarOption(id: 'initials', label: 'Initials'),
    UserAvatarOption(id: 'symbol', label: 'Symbol mark'),
    UserAvatarOption(id: 'pattern', label: 'Pattern'),
    UserAvatarOption(id: 'soft_silhouette', label: 'Soft silhouette'),
  ];

  static const Set<String> freeForeverCategories = <String>{
    'skin_tone',
    'body_shape',
    'disability_representation',
    'cultural_clothing_basics',
    'glasses',
    'hair_type',
    'age_presentation',
    'privacy_mode',
  };

  static const Set<String> paidCosmeticCategories = <String>{
    'premium_clothing_styles',
    'themed_packs',
    'animated_backgrounds',
    'seasonal_effects',
    'premium_accessories',
  };

  static bool canBePremiumOnly(String category) {
    return paidCosmeticCategories.contains(category) &&
        !freeForeverCategories.contains(category);
  }
}
