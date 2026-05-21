import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_scaffold.dart';
import '../../domain/body_double/moderation/body_double_moderation.dart';
import '../../providers.dart';

class BodyDoubleModerationScreen extends ConsumerStatefulWidget {
  const BodyDoubleModerationScreen({super.key, this.repositoryOverride});

  final BodyDoubleModerationRepository? repositoryOverride;

  @override
  ConsumerState<BodyDoubleModerationScreen> createState() =>
      _BodyDoubleModerationScreenState();
}

class _BodyDoubleModerationScreenState
    extends ConsumerState<BodyDoubleModerationScreen> {
  bool _loading = true;
  bool _saving = false;
  bool _isModerator = false;
  String? _message;
  BodyDoubleModerationReport? _selectedReport;
  BodyDoubleModerationReportDetails? _details;
  List<BodyDoubleModerationReport> _reports = const [];
  List<BodyDoubleAuditEvent> _auditEvents = const [];
  List<BodyDoubleModerationEvent> _moderationEvents = const [];
  List<BodyDoubleUserRestriction> _restrictions = const [];

  BodyDoubleModerationRepository _repository() =>
      widget.repositoryOverride ?? ref.read(bodyDoubleRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = _repository();
    setState(() => _loading = true);
    final isModerator = await repository.isCurrentUserModerator();
    if (!mounted) return;
    if (!isModerator) {
      setState(() {
        _isModerator = false;
        _loading = false;
        _reports = const [];
        _auditEvents = const [];
        _moderationEvents = const [];
        _restrictions = const [];
      });
      return;
    }
    final reports = await repository.loadModerationReports();
    final auditEvents = await repository.loadBodyDoubleAuditEvents();
    final moderationEvents = await repository.loadModerationEvents();
    final restrictions = await repository.loadUserRestrictions();
    BodyDoubleModerationReportDetails? details;
    if (_selectedReport != null) {
      details =
          await repository.loadModerationReportDetails(_selectedReport!.id);
    }
    if (!mounted) return;
    setState(() {
      _isModerator = true;
      _reports = reports;
      _auditEvents = auditEvents;
      _moderationEvents = moderationEvents;
      _restrictions = restrictions;
      _details = details;
      _loading = false;
    });
  }

  Future<void> _openReport(BodyDoubleModerationReport report) async {
    final details = await _repository().loadModerationReportDetails(report.id);
    if (!mounted) return;
    setState(() {
      _selectedReport = report;
      _details = details;
      _message = details == null ? 'Report details could not be loaded.' : null;
    });
  }

  Future<void> _reviewReport(BodyDoubleReportStatus status) async {
    final report = _details?.report ?? _selectedReport;
    if (report == null) return;
    setState(() => _saving = true);
    await _repository()
        .reviewModerationReport(reportId: report.id, status: status);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = 'Report marked ${status.value}.';
    });
    await _load();
  }

  Future<void> _restrictFromReport() async {
    final report = _details?.report ?? _selectedReport;
    final targetUserId = report?.reported?.userId;
    if (report == null || targetUserId == null || targetUserId.isEmpty) return;
    final reason = await _reasonDialog(
      title: 'Restrict user',
      initial: 'Action taken from report ${report.id}: ${report.reason}',
    );
    if (reason == null || reason.trim().isEmpty) return;
    setState(() => _saving = true);
    await _repository().restrictUser(
      targetUserId: targetUserId,
      restrictionType: BodyDoubleRestrictionType.randomSuspended,
      reason: reason.trim(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      reportId: report.id,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = 'Restriction applied.';
    });
    await _load();
  }

  Future<void> _revokeRestriction(BodyDoubleUserRestriction restriction) async {
    final reason = await _reasonDialog(
      title: 'Revoke restriction',
      initial: 'Restriction revoked after moderator review.',
    );
    if (reason == null || reason.trim().isEmpty) return;
    setState(() => _saving = true);
    await _repository().revokeRestriction(
      restrictionId: restriction.id,
      reason: reason.trim(),
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = 'Restriction revoked.';
    });
    await _load();
  }

  Future<void> _runRetentionCleanup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Run retention cleanup?'),
        content: const Text(
          'This moderator-only action scrubs aged moderation previews and old audit events. It does not run automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Run cleanup'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    final result = await _repository().runModerationRetentionCleanup();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = result == null
          ? 'Retention cleanup could not run.'
          : 'Retention cleanup complete: ${result.allowedPreviewsScrubbed} allowed previews, ${result.blockedPreviewsScrubbed} blocked previews, ${result.reportedPreviewsScrubbed} reported previews scrubbed.';
    });
    await _load();
  }

  Future<String?> _reasonDialog(
      {required String title, required String initial}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          key: const ValueKey('moderation-reason-field'),
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Reason',
            helperText: 'Required for audit trail',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Moderation operations',
      showOfflineBanner: false,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_isModerator
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Access denied. This console is available only to body-double moderators.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _moderatorList(),
    );
  }

  Widget _moderatorList() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Moderator-only safety review for random body-double sessions. Lists show limited operational metadata, report details, moderation previews, restrictions, and audit trail only.',
              ),
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Semantics(liveRegion: true, child: Text(_message!)),
          ],
          const SizedBox(height: 16),
          _dashboardCards(),
          const SizedBox(height: 20),
          _sectionTitle('Pending reports'),
          ..._reportList(
            _reports.where((report) => report.isPending),
            empty: 'No pending reports.',
          ),
          const SizedBox(height: 20),
          _sectionTitle('Reviewed reports'),
          ..._reportList(
            _reports.where((report) => !report.isPending),
            empty: 'No reviewed, actioned, or dismissed reports.',
          ),
          if (_details != null) ...[
            const SizedBox(height: 20),
            _sectionTitle('Report details'),
            _detailsCard(_details!),
          ],
          const SizedBox(height: 20),
          _sectionTitle('Active restrictions'),
          ..._restrictionList(
            _restrictions.where((item) => item.isActive),
            empty: 'No active restrictions.',
          ),
          const SizedBox(height: 20),
          _sectionTitle('Expired or revoked restrictions'),
          ..._restrictionList(
            _restrictions.where((item) => !item.isActive),
            empty: 'No expired or revoked restrictions.',
          ),
          const SizedBox(height: 20),
          _sectionTitle('Recent moderation events'),
          if (_moderationEvents.isEmpty)
            const Text('No recent moderation events.')
          else
            ..._moderationEvents.take(10).map(_moderationEventCard),
          const SizedBox(height: 20),
          _sectionTitle('Recent audit events'),
          if (_auditEvents.isEmpty)
            const Text('No recent audit events.')
          else
            ..._auditEvents.take(10).map(_auditEventCard),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const ValueKey('retention-cleanup-button'),
            onPressed: _saving ? null : _runRetentionCleanup,
            icon: const Icon(Icons.cleaning_services_rounded),
            label: const Text('Run retention cleanup'),
          ),
        ],
      ),
    );
  }

  Widget _dashboardCards() {
    final pending = _reports
        .where((r) => r.status == BodyDoubleReportStatus.pending)
        .length;
    final reviewed = _reports
        .where((r) => r.status == BodyDoubleReportStatus.reviewed)
        .length;
    final actioned = _reports
        .where((r) => r.status == BodyDoubleReportStatus.actioned)
        .length;
    final dismissed = _reports
        .where((r) => r.status == BodyDoubleReportStatus.dismissed)
        .length;
    final activeRestrictions = _restrictions.where((r) => r.isActive).length;
    return Wrap(spacing: 8, runSpacing: 8, children: [
      _MetricChip(label: 'Pending reports', value: pending),
      _MetricChip(label: 'Reviewed reports', value: reviewed),
      _MetricChip(label: 'Actioned reports', value: actioned),
      _MetricChip(label: 'Dismissed reports', value: dismissed),
      _MetricChip(label: 'Active restrictions', value: activeRestrictions),
      _MetricChip(
          label: 'Recent moderation events', value: _moderationEvents.length),
      _MetricChip(label: 'Recent audit events', value: _auditEvents.length),
    ]);
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      );

  Iterable<Widget> _reportList(Iterable<BodyDoubleModerationReport> reports,
      {required String empty}) {
    final list = reports.toList();
    if (list.isEmpty) return [Text(empty)];
    return list.map(_reportCard);
  }

  Widget _reportCard(BodyDoubleModerationReport report) => Card(
        child: ListTile(
          key: ValueKey('moderation-report-${report.id}'),
          title: Text('${report.reason} • ${report.status.value}'),
          subtitle: Text(
            'Reported user: ${report.reported?.safeLabel ?? 'Limited user'}\n'
            'Reporter: ${report.reporter?.safeLabel ?? 'Limited user'}\n'
            'Session: ${_shortId(report.sessionId)} • Created: ${_date(report.createdAt)}',
          ),
          isThreeLine: true,
          trailing: TextButton(
            key: ValueKey('review-report-${report.id}'),
            onPressed: _saving ? null : () => _openReport(report),
            child: const Text('Review report'),
          ),
        ),
      );

  Widget _detailsCard(BodyDoubleModerationReportDetails details) {
    final report = details.report;
    return Card(
      key: const ValueKey('moderation-report-detail'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Report ${_shortId(report.id)}',
              style: Theme.of(context).textTheme.titleMedium),
          Text('Reason: ${report.reason}'),
          if (report.details?.trim().isNotEmpty == true)
            Text('Details: ${report.details!.trim()}'),
          Text(
              'Reported user: ${report.reported?.safeLabel ?? 'Limited user'}'),
          Text('Reporter: ${report.reporter?.safeLabel ?? 'Limited user'}'),
          Text(
              'Linked session: ${details.session == null ? _shortId(report.sessionId) : '${details.session!.mode} • ${details.session!.status} • ${details.session!.communicationMode}'}'),
          const Divider(),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton(
                key: const ValueKey('mark-report-reviewed'),
                onPressed: _saving
                    ? null
                    : () => _reviewReport(BodyDoubleReportStatus.reviewed),
                child: const Text('Mark reviewed')),
            OutlinedButton(
                key: const ValueKey('dismiss-report'),
                onPressed: _saving
                    ? null
                    : () => _reviewReport(BodyDoubleReportStatus.dismissed),
                child: const Text('Dismiss report')),
            OutlinedButton(
                key: const ValueKey('mark-report-actioned'),
                onPressed: _saving
                    ? null
                    : () => _reviewReport(BodyDoubleReportStatus.actioned),
                child: const Text('Mark actioned')),
            FilledButton(
                key: const ValueKey('restrict-random-user'),
                onPressed: _saving ? null : _restrictFromReport,
                child: const Text('Restrict user')),
          ]),
          const Divider(),
          Text('Linked moderation events',
              style: Theme.of(context).textTheme.titleSmall),
          if (details.moderationEvents.isEmpty)
            const Text('No linked moderation event previews.')
          else
            ...details.moderationEvents.map(_moderationEventCard),
          const SizedBox(height: 8),
          Text('Current restriction state',
              style: Theme.of(context).textTheme.titleSmall),
          if (details.restrictions.isEmpty)
            const Text('No restrictions for reported user.')
          else
            ...details.restrictions.map(_restrictionCard),
          const SizedBox(height: 8),
          Text('Linked audit trail',
              style: Theme.of(context).textTheme.titleSmall),
          if (details.auditEvents.isEmpty)
            const Text('No linked audit events.')
          else
            ...details.auditEvents.map(_auditEventCard),
        ]),
      ),
    );
  }

  Iterable<Widget> _restrictionList(
      Iterable<BodyDoubleUserRestriction> restrictions,
      {required String empty}) {
    final list = restrictions.toList();
    if (list.isEmpty) return [Text(empty)];
    return list.map(_restrictionCard);
  }

  Widget _restrictionCard(BodyDoubleUserRestriction restriction) => Card(
        child: ListTile(
          title: Text(
              '${restriction.restrictionType.label} • ${restriction.status.value}'),
          subtitle: Text(
              'User: ${restriction.user.safeLabel}\nReason: ${restriction.reason}\nExpires: ${_date(restriction.expiresAt)}'),
          isThreeLine: true,
          trailing: restriction.isActive
              ? TextButton(
                  key: ValueKey('revoke-restriction-${restriction.id}'),
                  onPressed:
                      _saving ? null : () => _revokeRestriction(restriction),
                  child: const Text('Revoke restriction'),
                )
              : null,
        ),
      );

  Widget _moderationEventCard(BodyDoubleModerationEvent event) => Card(
        child: ListTile(
          dense: true,
          title: Text(
              '${event.action ?? 'event'} • ${event.reason ?? 'safety review'}'),
          subtitle: Text(
              'Session: ${_shortId(event.sessionId)} • Sender: ${_shortId(event.senderId)}\nPreview: ${event.bodyPreview ?? 'No retained preview'}'),
        ),
      );

  Widget _auditEventCard(BodyDoubleAuditEvent event) => Card(
        child: ListTile(
          dense: true,
          title: Text(event.eventType ?? 'audit_event'),
          subtitle: Text(
              '${_date(event.createdAt)} • Actor: ${_shortId(event.actorId)}\n${event.metadata}'),
        ),
      );

  static String _shortId(String? value) {
    if (value == null || value.isEmpty) return '—';
    return value.length <= 8 ? value : value.substring(0, 8);
  }

  static String _date(DateTime? value) => value?.toLocal().toString() ?? '—';
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Chip(label: Text('$label: $value'));
}
