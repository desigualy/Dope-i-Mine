import '../../domain/analytics/analytics_event.dart';

class AnalyticsRepositoryImpl {
  Future<void> track(
    AnalyticsEvent event, {
    Map<String, dynamic> parameters = const <String, dynamic>{},
  }) async {
    // Replace with real analytics backend later.
  }
}
