import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../domain/avatar_v4_config.dart';
import '../runtime/avatar_rive_asset_resolver.dart';
import '../runtime/avatar_rive_contract_validator.dart';
import '../runtime/avatar_rive_controller.dart';
import '../runtime/avatar_rive_runtime_initializer.dart';
import 'avatar_missing_rig_diagnostic.dart';

class AvatarRiveView extends StatelessWidget {
  AvatarRiveView({
    super.key,
    required this.config,
    this.size = 180,
    AvatarRiveAssetResolver? assetResolver,
    AvatarRiveContractValidator? contractValidator,
  })  : assetResolver = assetResolver ?? AvatarRiveAssetResolver(),
        contractValidator = contractValidator ?? AvatarRiveContractValidator();

  final AvatarV4Config config;
  final double size;
  final AvatarRiveAssetResolver assetResolver;
  final AvatarRiveContractValidator contractValidator;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: assetResolver.exists(config.rigAssetPath),
      builder: (context, assetSnapshot) {
        if (assetSnapshot.connectionState != ConnectionState.done) {
          return SizedBox.square(
            dimension: size,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (assetSnapshot.data != true) {
          return AvatarMissingRigDiagnostic(
            assetPath: config.rigAssetPath,
            size: size,
          );
        }

        return FutureBuilder(
          future: contractValidator.validate(
            assetPath: config.rigAssetPath,
            artboardName: config.artboardName,
            stateMachineName: config.stateMachineName,
          ),
          builder: (context, contractSnapshot) {
            final contract = contractSnapshot.data;

            if (contractSnapshot.connectionState != ConnectionState.done) {
              return SizedBox.square(
                dimension: size,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (contract == null || !contract.canAttemptRender) {
              return AvatarMissingRigDiagnostic(
                assetPath: config.rigAssetPath,
                size: size,
                details: contract?.summary,
              );
            }

            return FutureBuilder<Object?>(
              future: AvatarRiveRuntimeInitializer.ensureInitialized(),
              builder: (context, initSnapshot) {
                if (initSnapshot.connectionState != ConnectionState.done) {
                  return SizedBox.square(
                    dimension: size,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final initError = initSnapshot.data;
                if (initSnapshot.hasError || initError != null) {
                  return AvatarMissingRigDiagnostic(
                    assetPath: config.rigAssetPath,
                    size: size,
                    details: 'Rive runtime failed to initialize.',
                  );
                }

                return SizedBox.square(
                  key: const ValueKey<String>('avatar-v4-rive-view'),
                  dimension: size,
                  child: RiveAnimation.asset(
                    config.rigAssetPath,
                    artboard: config.artboardName,
                    fit: BoxFit.contain,
                    onInit: (artboard) {
                      final controller = AvatarRiveController(config);
                      controller.bind(artboard);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
