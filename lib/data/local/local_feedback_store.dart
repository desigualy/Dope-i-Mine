import 'local_json_store.dart';

class LocalFeedbackStore {
  LocalFeedbackStore({LocalJsonStore? store}) : _store = store ?? LocalJsonStore('dope_i_mine.local.beta_feedback.v1');

  final LocalJsonStore _store;

  Future<List<Map<String, dynamic>>> loadFeedback() async {
    return _store.readList('feedback');
  }

  Future<void> saveFeedback(Map<String, dynamic> entry) async {
    final list = await _store.readList('feedback');
    await _store.writeList('feedback', <Map<String, dynamic>>[...list, entry]);
  }
}
