import 'package:flutter/material.dart';

import '../offline/offline_status_banner.dart';

class PrimaryScaffold extends StatelessWidget {
  const PrimaryScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.showOfflineBanner = true,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final bool showOfflineBanner;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: leading,
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
