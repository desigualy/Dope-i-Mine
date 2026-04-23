import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/reminders/reminder_model.dart';
import '../../providers.dart';

final reminderControllerProvider = StateNotifierProvider<ReminderController,
    AsyncValue<List<ReminderModel>>>((ref) {
  return ReminderController(ref.read(reminderRepositoryProvider));
});

class ReminderController
    extends StateNotifier<AsyncValue<List<ReminderModel>>> {
  ReminderController(this._repository)
      : super(const AsyncValue.data(<ReminderModel>[]));

  final ReminderRepositoryImpl _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final reminders = await _repository.getAll();
      state = AsyncValue.data(reminders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(ReminderModel reminder) async {
    final current = state.value ?? <ReminderModel>[];
    final updated = <ReminderModel>[...current, reminder];
    await _repository.saveAll(updated);
    state = AsyncValue.data(updated);
  }
}
