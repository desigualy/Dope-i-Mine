import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  test('missing asset validation reports missingAsset issue', () {
    final validation = AvatarV4RiveContractValidation.missingAsset();

    expect(validation.isValid, isFalse);
    expect(validation.canAttemptRender, isFalse);
    expect(validation.issues.single.code, AvatarV4RiveContractIssueCode.missingAsset);
    expect(validation.summary, contains('Missing Rive asset'));
  });

  test('valid validation can render', () {
    final validation = AvatarV4RiveContractValidation.valid();

    expect(validation.isValid, isTrue);
    expect(validation.canAttemptRender, isTrue);
    expect(validation.issues, isEmpty);
  });

  test('missing input validation can still attempt render with diagnostics', () {
    const validation = AvatarV4RiveContractValidation(
      assetPath: AvatarV4RiveContract.baseRigAssetPath,
      artboardName: AvatarV4RiveContract.artboardName,
      stateMachineName: AvatarV4RiveContract.stateMachineName,
      issues: <AvatarV4RiveContractIssue>[
        AvatarV4RiveContractIssue(
          code: AvatarV4RiveContractIssueCode.missingNumberInput,
          name: 'skinTone',
          message: 'Missing required Rive number input: skinTone',
        ),
      ],
    );

    expect(validation.isValid, isFalse);
    expect(validation.canAttemptRender, isTrue);
    expect(validation.summary, contains('skinTone'));
  });
}
