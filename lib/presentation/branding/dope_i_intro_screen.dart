import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../core/widgets/section_header.dart';

class DopeIIntroScreen extends StatelessWidget {
  const DopeIIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Meet Dope-i',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Dope-i (Dopy), your Dope-i-Mine assistant',
            subtitle: 'Rewarding the chase of progress, one task at a time.',
          ),
          const SizedBox(height: 16),
          const Text('I break big tasks into wins you can feel immediately.'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/branding/pronunciation'),
              child: const Text('Set up assistant voice'),
            ),
          ),
        ],
      ),
    );
  }
}
