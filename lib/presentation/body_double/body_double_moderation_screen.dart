import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../data/local/local_body_double_store.dart';
import '../../data/repositories/body_double_repository_impl.dart';
import '../../providers.dart';

class BodyDoubleModerationScreen extends ConsumerStatefulWidget {
  const BodyDoubleModerationScreen({super.key});

  @override
  ConsumerState<BodyDoubleModerationScreen> createState() =>
      _BodyDoubleModerationScreenState();
}

class _BodyDoubleModerationScreenState
    extends ConsumerState<BodyDoubleModerationScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _message;
  List<Map<String, dynamic>> _reports = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _auditEvents = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _messageModerationEvents =
      const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _restrictions = const <Map<String, dynamic>>[];

  BodyDoubleRepositoryImpl? _repository() {
    final client = ref.read(supabaseProvider);
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) return null;
    return BodyDoubleRepositoryImpl(
      localStore: ref.read(localBodyDoubleStoreProvider),
      client: client,
      userId: userId,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = _repository();
    if (repository == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final reports = await repository.loadModerationReports();
    final auditEvents = await repository.loadModerationAuditEvents();
    final messageModerationEvents =
        await repository.loadMessageModerationEvents();
    final restrictions = await repository.loadUserRestrictions();
    if (!mounted) return;
    setState(() {
      _reports = reports;
      _auditEvents = auditEvents;
      _messageModerationEvents = messageModerationEvents;
      _restrictions = restrictions;
      _loading = false;
    });
  }

  Future<void> _reviewReport(String reportId, String status) async {
    final repository = _repository();
    if (repository == null) return;
    setState(() => _saving = true);
    await repository.reviewModerationReport(reportId: reportId, status: status);
    await _load();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = 'Report marked $status.';
    });
  }

  Future<void> _restrictFromReport(Map<String, dynamic> report) async {
    final repository = _repository();
    if (repository == null) return;
    final reportedId = report['reported_id'] as String?;
    final reportId = report['id'] as String?;
    if (reportedId == null || reportId == null) return;
    setState(() => _saving = true);
    await repository.restrictUser(
      targetUserId: reportedId,
      restrictionType: 'random_suspended',
      reason:
          'Actioned from body double report: ${report['reason'] ?? 'Safety concern'}',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      reportId: reportId,
    );
    await _load();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = 'Random matching suspended for 7 days.';
    });
  }

  Future<void> _revokeRestriction(String restrictionId) async {
    final repository = _repository();
    if (repository == null) return;
    setState(() => _saving = true);
    await repository.revokeRestriction(
      restrictionId: restrictionId,
      reason: 'Revoked from moderation queue',
    );
    await _load();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = 'Restriction revoked.';
    });
  }

  Future<void> _runLifecycleCleanup() async {
    final repository = _repository();
    if (repository == null) return;
    setState(() => _saving = true);
    final result = await repository.cleanupRandomLifecycle();
    await _load();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = result == null
          ? 'Lifecycle cleanup could not run.'
          : 'Cleanup: ${result['expiredQueues']} queues expired, '
              '${result['stalePresence']} stale presence rows, '
              '${result['closedSessions']} sessions closed.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Body double moderation',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Moderator-only review for Phase 3A/3B/3C safety: reports, text moderation events, audit events, random suspensions, and lifecycle cleanup. Access is enforced by Supabase RLS/RPC policies.',
                      ),
                    ),
                  ),
                  if (_message != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(_message!),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _saving ? null : _runLifecycleCleanup,
                    icon: const Icon(Icons.cleaning_services_rounded),
                    label: const Text('Run lifecycle cleanup now'),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Report review queue'),
                  if (_reports.isEmpty)
                    const Text(
                        'No visible reports. Non-moderators will see none.')
                  else
                    ..._reports.map(_reportCard),
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Random text moderation events'),
                  const Text(
                    'Limited text previews are truncated for safety review. Use reports and restrictions for action; do not treat this as social chat history.',
                  ),
                  const SizedBox(height: 8),
                  if (_messageModerationEvents.isEmpty)
                    const Text('No visible text moderation events.')
                  else
                    ..._messageModerationEvents.map(_messageModerationCard),
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Active / recent restrictions'),
                  if (_restrictions.isEmpty)
                    const Text('No visible restrictions.')
                  else
                    ..._restrictions.map(_restrictionCard),
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Audit events'),
                  if (_auditEvents.isEmpty)
                    const Text('No visible audit events.')
                  else
                    ..._auditEvents.map(_auditCard),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _reportCard(Map<String, dynamic> report) {
    return Card(
      child: ListTile(
        title: Text('${report['reason'] ?? 'Report'} • ${report['status']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reported: ${report['reported_id']}\nReporter: ${report['reporter_id']}\n${report['details'] ?? ''}',
            ),
            const SizedBox(height: 4),
            _ReliabilityBadge(
              score: report['reported_profile']?['reliability_score'] as num?,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          enabled: !_saving,
          onSelected: (value) {
            if (value == 'suspend') {
              _restrictFromReport(report);
            } else {
              _reviewReport(report['id'] as String, value);
            }
          },
          itemBuilder: (context) => const <PopupMenuEntry<String>>[
            PopupMenuItem(value: 'reviewed', child: Text('Mark reviewed')),
            PopupMenuItem(value: 'dismissed', child: Text('Dismiss')),
            PopupMenuItem(
                value: 'suspend', child: Text('Suspend random 7 days')),
          ],
        ),
      ),
    );
  }

  Widget _restrictionCard(Map<String, dynamic> restriction) {
    final id = restriction['id'] as String? ?? '';
    return Card(
      child: ListTile(
        title: Text(
            '${restriction['restriction_type']} • ${restriction['status']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User: ${restriction['user_id']}\nReason: ${restriction['reason']}\nExpires: ${restriction['expires_at'] ?? 'manual review'}',
            ),
            const SizedBox(height: 4),
            _ReliabilityBadge(
              score: restriction['user_profile']?['reliability_score'] as num?,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: restriction['status'] == 'active'
            ? TextButton(
                onPressed: _saving ? null : () => _revokeRestriction(id),
                child: const Text('Revoke'),
              )
            : null,
      ),
    );
  }

  Widget _messageModerationCard(Map<String, dynamic> event) {
    return Card(
      child: ListTile(
        dense: true,
        title: Text(
            '${event['action'] ?? 'event'} • ${event['reason'] ?? 'reason'}'),
        subtitle: Text(
          'Session: ${event['session_id']}\nSender: ${event['sender_id']}\nReport: ${event['report_id'] ?? '—'}\nPreview: ${event['body_preview'] ?? ''}',
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _auditCard(Map<String, dynamic> event) {
    return Card(
      child: ListTile(
        dense: true,
        title: Text(event['event_type'] as String? ?? 'audit_event'),
        subtitle: Text('${event['created_at']}\n${event['metadata']}'),
      ),
    );
  }
}
class _ReliabilityBadge extends StatelessWidget {
  const _ReliabilityBadge({this.score});

  final num? score;

  @override
  Widget build(BuildContext context) {
    if (score == null) return const SizedBox.shrink();
    final s = score!.toDouble();
    final color = s > 0.8 ? Colors.green : (s > 0.5 ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        'Reliability: ${(s * 100).toStringAsFixed(0)}%',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
