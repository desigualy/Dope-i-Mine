import 'package:flutter/material.dart';

import '../offline/offline_status_banner.dart';
import 'app_back_button.dart';

class PrimaryScaffold extends StatelessWidget {
  const PrimaryScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backFallbackRoute = '/home',
    this.floatingActionButton,
    this.showOfflineBanner = true,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final String backFallbackRoute;
  final Widget? floatingActionButton;
  final bool showOfflineBanner;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: leading ??
              (showBackButton
                  ? AppBackButton(fallbackRoute: backFallbackRoute)
                  : null),
          title: Text(title),
          actions: actions,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                if (showOfflineBanner) const OfflineStatusBanner(),
                Expanded(child: child),
              ],
            ),
          ),
        ),
        floatingActionButton: floatingActionButton,
      );
}
