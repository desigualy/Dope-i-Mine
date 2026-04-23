import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/caregiver_repository_impl.dart';
import '../../domain/caregiver/caregiver_link_model.dart';
import '../../providers.dart';

final caregiverControllerProvider = StateNotifierProvider<CaregiverController,
    AsyncValue<List<CaregiverLinkModel>>>((ref) {
  return CaregiverController(ref.read(caregiverRepositoryProvider));
});

class CaregiverController
    extends StateNotifier<AsyncValue<List<CaregiverLinkModel>>> {
  CaregiverController(this._repository)
      : super(const AsyncValue.data(<CaregiverLinkModel>[]));

  final CaregiverRepositoryImpl _repository;

  Future<void> load(String userId) async {
    state = const AsyncValue.loading();
    try {
      final links = await _repository.getLinks(userId);
      state = AsyncValue.data(links);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> link({
    required String primaryUserId,
    required String caregiverUserId,
    required String permissionLevel,
  }) async {
    await _repository.linkCaregiver(
      primaryUserId: primaryUserId,
      caregiverUserId: caregiverUserId,
      permissionLevel: permissionLevel,
    );
    await load(primaryUserId);
  }
}
