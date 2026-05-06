import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

import '../domain/avatar_v4_rive_contract.dart';
import '../domain/avatar_v4_rive_contract_validation.dart';
import 'avatar_rive_runtime_initializer.dart';

class AvatarRiveContractValidator {
  AvatarRiveContractValidator({
    AssetBundle? bundle,
    bool initializeNativeRuntime = true,
    bool parseRiveFile = true,
  })  : _bundle = bundle ?? rootBundle,
        _initializeNativeRuntime = initializeNativeRuntime,
        _parseRiveFile = parseRiveFile;

  final AssetBundle _bundle;
  final bool _initializeNativeRuntime;
  final bool _parseRiveFile;

  Future<AvatarV4RiveContractValidation> validate({
    String assetPath = AvatarV4RiveContract.baseRigAssetPath,
    String artboardName = AvatarV4RiveContract.artboardName,
    String stateMachineName = AvatarV4RiveContract.stateMachineName,
  }) async {
    final ByteData data;

    try {
      data = await _bundle.load(assetPath);
    } on FlutterError {
      return AvatarV4RiveContractValidation.missingAsset(assetPath: assetPath);
    } catch (error) {
      return _unreadableAsset(
        assetPath: assetPath,
        artboardName: artboardName,
        stateMachineName: stateMachineName,
        message: 'Could not read Rive asset $assetPath: $error',
      );
    }

    if (!_parseRiveFile) {
      return _unreadableAsset(
        assetPath: assetPath,
        artboardName: artboardName,
        stateMachineName: stateMachineName,
        message:
            'Rive parsing is disabled for this validation context: $assetPath',
      );
    }

    if (_initializeNativeRuntime) {
      final initError = await AvatarRiveRuntimeInitializer.ensureInitialized();
      if (initError != null) {
        return _unreadableAsset(
          assetPath: assetPath,
          artboardName: artboardName,
          stateMachineName: stateMachineName,
          message: 'Rive runtime could not initialize: $initError',
        );
      }
    }

    final dynamic file;
    try {
      file = RiveFile.import(data);
    } catch (error) {
      return _unreadableAsset(
        assetPath: assetPath,
        artboardName: artboardName,
        stateMachineName: stateMachineName,
        message: 'Could not parse Rive asset $assetPath: $error',
      );
    }

    final dynamic artboard = _readArtboardByName(file, artboardName);
    if (artboard == null) {
      return AvatarV4RiveContractValidation(
        assetPath: assetPath,
        artboardName: artboardName,
        stateMachineName: stateMachineName,
        issues: <AvatarV4RiveContractIssue>[
          AvatarV4RiveContractIssue(
            code: AvatarV4RiveContractIssueCode.missingArtboard,
            name: artboardName,
            message: 'Missing Rive artboard: $artboardName',
          ),
        ],
      );
    }

    final StateMachineController? controller =
        StateMachineController.fromArtboard(
      artboard as Artboard,
      stateMachineName,
    );

    if (controller == null) {
      return AvatarV4RiveContractValidation(
        assetPath: assetPath,
        artboardName: artboardName,
        stateMachineName: stateMachineName,
        issues: <AvatarV4RiveContractIssue>[
          AvatarV4RiveContractIssue(
            code: AvatarV4RiveContractIssueCode.missingStateMachine,
            name: stateMachineName,
            message: 'Missing Rive state machine: $stateMachineName',
          ),
        ],
      );
    }

    final issues = <AvatarV4RiveContractIssue>[];

    for (final input in AvatarV4RiveContract.requiredNumberInputs) {
      if (controller.findInput<double>(input) == null) {
        issues.add(
          AvatarV4RiveContractIssue(
            code: AvatarV4RiveContractIssueCode.missingNumberInput,
            name: input,
            message: 'Missing required Rive number input: $input',
          ),
        );
      }
    }

    for (final input in AvatarV4RiveContract.requiredBooleanInputs) {
      if (controller.findInput<bool>(input) == null) {
        issues.add(
          AvatarV4RiveContractIssue(
            code: AvatarV4RiveContractIssueCode.missingBooleanInput,
            name: input,
            message: 'Missing required Rive boolean input: $input',
          ),
        );
      }
    }

    controller.dispose();

    return AvatarV4RiveContractValidation(
      assetPath: assetPath,
      artboardName: artboardName,
      stateMachineName: stateMachineName,
      issues: List<AvatarV4RiveContractIssue>.unmodifiable(issues),
    );
  }

  static AvatarV4RiveContractValidation _unreadableAsset({
    required String assetPath,
    required String artboardName,
    required String stateMachineName,
    required String message,
  }) {
    return AvatarV4RiveContractValidation(
      assetPath: assetPath,
      artboardName: artboardName,
      stateMachineName: stateMachineName,
      issues: <AvatarV4RiveContractIssue>[
        AvatarV4RiveContractIssue(
          code: AvatarV4RiveContractIssueCode.unreadableAsset,
          name: assetPath,
          message: message,
        ),
      ],
    );
  }

  static dynamic _readArtboardByName(dynamic file, String artboardName) {
    try {
      return file.artboardByName(artboardName);
    } catch (_) {
      try {
        final dynamic mainArtboard = file.mainArtboard;
        if (mainArtboard != null && mainArtboard.name == artboardName) {
          return mainArtboard;
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
