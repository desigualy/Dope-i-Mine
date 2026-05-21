import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/body_double/body_double_session.dart';
import 'body_double_controller.dart';
import 'dopei_body_double_session_screen.dart';
import 'friend_body_double_session_screen.dart';

class BodyDoubleSessionRouterScreen extends ConsumerWidget {
  const BodyDoubleSessionRouterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bodyDoubleControllerProvider);
    final session = state.activeSession;

    if (session?.mode == BodyDoubleMode.friend ||
        session?.mode == BodyDoubleMode.random ||
        session?.isGroupSession == true) {
      return const FriendBodyDoubleSessionScreen();
    }

    return const DopeiBodyDoubleSessionScreen();
  }
}
