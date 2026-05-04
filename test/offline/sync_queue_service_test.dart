import 'package:dope_i_mine/core/sync/sync_queue_item.dart';
import 'package:dope_i_mine/core/sync/sync_queue_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('sync queue stores and counts pending items', () async {
    final prefs = await SharedPreferences.getInstance();
    final queue = SyncQueueService(preferences: prefs);

    await queue.enqueue(SyncQueueItem.create(
      type: 'complete_step',
      idempotencyKey: 'step-1',
      payload: <String, dynamic>{'stepId': 'step-1'},
    ));

    expect(await queue.pendingCount(), 1);
    final items = await queue.loadQueue();
    expect(items.single.type, 'complete_step');
  });

  test('synced items are cleared', () async {
    final prefs = await SharedPreferences.getInstance();
    final queue = SyncQueueService(preferences: prefs);
    final item = SyncQueueItem.create(
      type: 'complete_step',
      idempotencyKey: 'step-1',
      payload: <String, dynamic>{'stepId': 'step-1'},
    );

    await queue.enqueue(item);
    await queue.markSynced(item.id);
    await queue.clearSynced();

    expect(await queue.pendingCount(), 0);
  });
}
