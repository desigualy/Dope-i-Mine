import 'package:rive/rive.dart';

import '../domain/avatar_v4_config.dart';
import '../domain/avatar_v4_rive_contract.dart';

class AvatarRiveController {
  AvatarRiveController(this.config);

  final AvatarV4Config config;

  StateMachineController? _stateMachineController;
  List<String> _missingInputs = const <String>[];

  List<String> get missingInputs => _missingInputs;

  void bind(Artboard artboard) {
    _stateMachineController = StateMachineController.fromArtboard(
      artboard,
      config.stateMachineName,
    );

    final controller = _stateMachineController;
    if (controller == null) {
      _missingInputs = AvatarV4RiveContract.requiredInputs;
      return;
    }

    artboard.addController(controller);
    applyConfig(config);
  }

  void applyConfig(AvatarV4Config config) {
    final controller = _stateMachineController;
    if (controller == null) {
      _missingInputs = AvatarV4RiveContract.requiredInputs;
      return;
    }

    final missing = <String>[];

    _setNumber(
      controller,
      AvatarV4RiveContract.skinToneInput,
      _hashToRange(config.skinTone),
      missing,
    );
    _setNumber(
      controller,
      AvatarV4RiveContract.faceShapeInput,
      _hashToRange(config.faceShape),
      missing,
    );
    _setNumber(
      controller,
      AvatarV4RiveContract.hairPackInput,
      _hashToRange(config.hairPackId),
      missing,
    );
    _setNumber(
      controller,
      AvatarV4RiveContract.hairStyleInput,
      _hashToRange(config.hairStyleId),
      missing,
    );
    _setNumber(
      controller,
      AvatarV4RiveContract.hairColorInput,
      _hashToRange(config.hairColor),
      missing,
    );
    _setNumber(
      controller,
      AvatarV4RiveContract.bodyPresetInput,
      _hashToRange(config.bodyPresetId),
      missing,
    );

    _setBoolean(
      controller,
      AvatarV4RiveContract.frecklesInput,
      config.freckles,
      missing,
    );
    _setBoolean(
      controller,
      AvatarV4RiveContract.vitiligoInput,
      config.vitiligo,
      missing,
    );
    _setBoolean(
      controller,
      AvatarV4RiveContract.hasFacialHairInput,
      config.facialHairStyleId != 'none',
      missing,
    );
    _setBoolean(
      controller,
      AvatarV4RiveContract.hasGlassesInput,
      config.accessoryIds.contains('glasses'),
      missing,
    );

    _missingInputs = List<String>.unmodifiable(missing);
  }

  void dispose() {
    _stateMachineController?.dispose();
    _stateMachineController = null;
  }

  static void _setBoolean(
    StateMachineController controller,
    String name,
    bool value,
    List<String> missing,
  ) {
    final input = controller.findInput<bool>(name);
    if (input == null) {
      missing.add(name);
      return;
    }
    input.value = value;
  }

  static void _setNumber(
    StateMachineController controller,
    String name,
    double value,
    List<String> missing,
  ) {
    final input = controller.findInput<double>(name);
    if (input == null) {
      missing.add(name);
      return;
    }
    input.value = value;
  }

  static double _hashToRange(String value) {
    if (value.isEmpty) return 0;
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = 0x1fffffff & (hash + unit);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    return (hash % 1000) / 1000.0;
  }
}
