import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Consistent app-wide back affordance.
///
/// Many flows navigate with `context.go(...)`, which replaces the stack and
/// prevents Flutter from automatically showing an AppBar back arrow. This
/// button always renders a back arrow, pops when possible, and otherwise sends
/// the user to a safe fallback route.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.fallbackRoute = '/home',
  });

  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
          return;
        }

        final currentRoute = GoRouterState.of(context).matchedLocation;
        context.go(currentRoute == fallbackRoute ? '/' : fallbackRoute);
      },
    );
  }
}