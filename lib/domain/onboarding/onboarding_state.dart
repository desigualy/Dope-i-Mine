import '../branding/pronunciation_option.dart';
import '../tasks/task_state_snapshot.dart';

enum SexAtBirth {
  preferNotToSay,
  female,
  male,
  intersex,
}

enum GenderIdentity {
  preferNotToSay,
  girl,
  boy,
  woman,
  man,
  nonBinary,
  transGirl,
  transBoy,
  transWoman,
  transMan,
  genderFluid,
  agender,
  other,
}

enum PronounSet {
  preferNotToSay,
  sheHer,
  heHim,
  theyThem,
  sheThey,
  heThey,
  custom,
}

extension SexAtBirthLabel on SexAtBirth {
  String get label {
    return switch (this) {
      SexAtBirth.preferNotToSay => 'Prefer not to say',
      SexAtBirth.female => 'Female',
      SexAtBirth.male => 'Male',
      SexAtBirth.intersex => 'Intersex',
    };
  }
}

extension GenderIdentityLabel on GenderIdentity {
  String get label {
    return switch (this) {
      GenderIdentity.preferNotToSay => 'Prefer not to say',
      GenderIdentity.girl => 'Girl',
      GenderIdentity.boy => 'Boy',
      GenderIdentity.woman => 'Woman',
      GenderIdentity.man => 'Man',
      GenderIdentity.nonBinary => 'Non-binary',
      GenderIdentity.transGirl => 'Trans girl',
      GenderIdentity.transBoy => 'Trans boy',
      GenderIdentity.transWoman => 'Trans woman',
      GenderIdentity.transMan => 'Trans man',
      GenderIdentity.genderFluid => 'Gender-fluid',
      GenderIdentity.agender => 'Agender',
      GenderIdentity.other => 'Other',
    };
  }
}

extension PronounSetLabel on PronounSet {
  String get label {
    return switch (this) {
      PronounSet.preferNotToSay => 'Prefer not to say',
      PronounSet.sheHer => 'She/her',
      PronounSet.heHim => 'He/him',
      PronounSet.theyThem => 'They/them',
      PronounSet.sheThey => 'She/they',
      PronounSet.heThey => 'He/they',
      PronounSet.custom => 'Custom',
    };
  }
}

enum OnboardingRole { self, caregiver, supported, both }

extension OnboardingRoleLabel on OnboardingRole {
  String get label {
    return switch (this) {
      OnboardingRole.self => 'Self',
      OnboardingRole.caregiver => 'Caregiver',
      OnboardingRole.supported => 'Supported user',
      OnboardingRole.both => 'Self & supported',
    };
  }
}

class OnboardingState {
  const OnboardingState({
    this.role = OnboardingRole.self,
    this.ageBand = AgeBand.adult,
    this.sexAtBirth = SexAtBirth.preferNotToSay,
    this.genderIdentity = GenderIdentity.preferNotToSay,
    this.pronouns = PronounSet.preferNotToSay,
    this.customPronouns = '',
    this.assistantDisplayName = 'Dope-i',
    this.pronunciation = PronunciationOption.dopeEe,
    this.mode = SupportMode.audhd,
    this.reducedAnimation = false,
    this.largeText = false,
    this.softColors = true,
    this.soundEnabled = true,
    this.iconMode = false,
    this.reduceSurprises = true,
    this.praiseLevel = 'medium',
    this.voiceEnabled = true,
    this.speechRate = 0.45,
    this.autoReadSteps = false,
    this.autoReadSidequests = false,
    this.activeVoiceProfileId,
    this.notificationsEnabled = false,
    this.microphoneEnabled = false,
    this.bodyDoubleEnabled = false,
    this.sideQuestsEnabled = false,
  });

  final AgeBand ageBand;
  final SexAtBirth sexAtBirth;
  final GenderIdentity genderIdentity;
  final PronounSet pronouns;
  final String customPronouns;
  final String assistantDisplayName;
  final PronunciationOption pronunciation;
  final SupportMode mode;
  final bool reducedAnimation;
  final bool largeText;
  final bool softColors;
  final bool soundEnabled;
  final bool iconMode;
  final bool reduceSurprises;
  final String praiseLevel;
  final bool voiceEnabled;
  final OnboardingRole role;

  // Voice setup
  final double speechRate;
  final bool autoReadSteps;
  final bool autoReadSidequests;
  final String? activeVoiceProfileId;

  // Permissions preferences (best-effort; platform may override)
  final bool notificationsEnabled;
  final bool microphoneEnabled;
  final bool bodyDoubleEnabled;
  final bool sideQuestsEnabled;

  String get pronounDisplay {
    if (pronouns == PronounSet.custom && customPronouns.trim().isNotEmpty) {
      return customPronouns.trim();
    }
    return pronouns.label;
  }

  OnboardingState copyWith({
    OnboardingRole? role,
    AgeBand? ageBand,
    SexAtBirth? sexAtBirth,
    GenderIdentity? genderIdentity,
    PronounSet? pronouns,
    String? customPronouns,
    String? assistantDisplayName,
    PronunciationOption? pronunciation,
    SupportMode? mode,
    bool? reducedAnimation,
    bool? largeText,
    bool? softColors,
    bool? soundEnabled,
    bool? iconMode,
    bool? reduceSurprises,
    String? praiseLevel,
    bool? voiceEnabled,
    double? speechRate,
    bool? autoReadSteps,
    bool? autoReadSidequests,
    String? activeVoiceProfileId,
    bool? notificationsEnabled,
    bool? microphoneEnabled,
    bool? bodyDoubleEnabled,
    bool? sideQuestsEnabled,
  }) {
    return OnboardingState(
      role: role ?? this.role,
      ageBand: ageBand ?? this.ageBand,
      sexAtBirth: sexAtBirth ?? this.sexAtBirth,
      genderIdentity: genderIdentity ?? this.genderIdentity,
      pronouns: pronouns ?? this.pronouns,
      customPronouns: customPronouns ?? this.customPronouns,
      assistantDisplayName: assistantDisplayName ?? this.assistantDisplayName,
      pronunciation: pronunciation ?? this.pronunciation,
      mode: mode ?? this.mode,
      reducedAnimation: reducedAnimation ?? this.reducedAnimation,
      largeText: largeText ?? this.largeText,
      softColors: softColors ?? this.softColors,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      iconMode: iconMode ?? this.iconMode,
      reduceSurprises: reduceSurprises ?? this.reduceSurprises,
      praiseLevel: praiseLevel ?? this.praiseLevel,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      speechRate: speechRate ?? this.speechRate,
      autoReadSteps: autoReadSteps ?? this.autoReadSteps,
      autoReadSidequests: autoReadSidequests ?? this.autoReadSidequests,
      activeVoiceProfileId: activeVoiceProfileId ?? this.activeVoiceProfileId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      microphoneEnabled: microphoneEnabled ?? this.microphoneEnabled,
      bodyDoubleEnabled: bodyDoubleEnabled ?? this.bodyDoubleEnabled,
      sideQuestsEnabled: sideQuestsEnabled ?? this.sideQuestsEnabled,
    );
  }
}

enum OnboardingRole { self, caregiver, supported, both }
