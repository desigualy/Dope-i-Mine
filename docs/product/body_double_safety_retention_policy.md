# Body Double Safety Retention Policy

This policy applies to Phase 3C-F random body double safety data: moderation event rows, truncated text previews, group session metadata, voice signaling audit logs, user reports, reliability trust signals, and moderation audit records. Random body doubling is intentionally limited to adult-only, opt-in communication; it is not a social chat or DM feature.

## Data retained

- **Allowed/Blocked random text preview:** up to the first 80 characters of a message processed via the safety RPC.
- **Voice signaling metadata:** timestamps and durations of "Push-to-Talk" events. **Audio content is not recorded or stored by Dope-i-Mine infrastructure.**
- **Group session metadata:** participant IDs, entry/exit timestamps, and role snapshots.
- **Reliability Trust Signals:** internal scores based on session completion and moderation history.
- **Reported session preview:** up to the first 80 characters of report details.
- **Linked safety metadata:** session ID, actor IDs, event type, action, reason, and created timestamp.

Full random text transcripts are not retained as a transcript product surface. The moderation table stores only short previews for safety review.

## Retention windows

- **Allowed previews:** retain for **30 days**, then delete or anonymise.
- **Blocked previews:** retain for **90 days**, then delete or anonymise unless attached to an active investigation.
- **Reliability trust signals:** retained as part of the internal user profile to assist matching quality. These are not public labels.
- **Reported previews and linked report records:** retain for **180 days after final moderation decision**, then delete or anonymise unless required for legal, trust-and-safety, or abuse-prevention reasons.
- **Audit events (without content previews):** retain for **1 year** for operational safety accountability.

If a user requests deletion, delete or anonymise eligible preview content earlier unless retention is required for an active safety investigation, legal obligation, or abuse-prevention enforcement.

## Access rules

- Regular users can only see their own report submissions where RLS permits it.
- Body double moderators can view moderation events, reports, restrictions, and audit events through moderator-only Supabase RLS/RPC access.
- Engineering/admin database access must be limited to production support, incident response, schema migration, and audited debugging needs.
- Previews must not be exposed as social chat history, searchable user transcripts, recommendations data, or marketing analytics.

## Deletion and anonymisation rules

- Prefer deleting `body_preview` content while preserving non-content safety metadata when aggregate abuse prevention still needs it.
- When preserving metadata, anonymise direct user identifiers where the safety case allows it.
- Reports linked to enforcement may keep report IDs and restriction IDs until the enforcement record expires or is no longer needed for appeals/repeat-abuse prevention.
- Backups should age out according to the platform backup retention schedule; restored backups must be re-scrubbed if they reintroduce expired preview content.

## Review and appeals

- False positives can be reviewed by moderators from linked report/moderation event context.
- Moderator actions should prefer the least restrictive safety outcome that protects users: dismiss, warn, temporary random suspension, or broader body double suspension.
- Stronger production moderation can add language-aware classifiers and PII/profanity models, but must keep this retention policy as the default privacy boundary.
