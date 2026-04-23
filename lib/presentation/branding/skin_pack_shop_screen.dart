
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state_card.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../domain/branding/skin_pack_model.dart';
import '../../providers.dart';

final skinPackShopProvider = FutureProvider<List<SkinPackModel>>((ref) async {
  return ref.read(brandingRepositoryProvider).getSkinPackCatalogue();
});

class SkinPackShopScreen extends ConsumerWidget {
  const SkinPackShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(skinPackShopProvider);

    return PrimaryScaffold(
      title: 'Skin packs',
      child: state.when(
        data: (packs) {
          if (packs.isEmpty) {
            return const EmptyStateCard(
              title: 'No skin packs loaded',
              subtitle: 'Add catalogue data to see available packs.',
            );
          }
          return ListView.separated(
            itemCount: packs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final SkinPackModel pack = packs[index];
              final bool isFree = pack.tier == 'free';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              pack.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Chip(
                            label: Text(isFree ? 'Free' : pack.tier.toUpperCase()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(pack.description),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          if (pack.previewAssetPath != null)
                            Text(
                              'Preview source: ${pack.previewAssetPath}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: isFree ? null : () {},
                            child: Text(isFree ? 'Included' : 'Unlock'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load skin packs')),
      ),
    );
  }
}
