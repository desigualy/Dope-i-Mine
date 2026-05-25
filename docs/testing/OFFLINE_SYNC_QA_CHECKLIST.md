# Offline Sync QA Checklist

| Check | Expected result | Pass/Fail | Notes |
| --- | --- | --- | --- |
| Complete task step offline | Step shows completed locally. |  |  |
| Restart app before reconnecting | Completed step remains completed. |  |  |
| Pending sync appears | Offline queue shows pending work. |  |  |
| Reconnect and sync | Pending work syncs once. |  |  |
| XP after reconnect | No duplicate XP is awarded. |  |  |
| Progress log after reconnect | No duplicate progress log is created. |  |  |
| Notification read/dismiss offline | Read/dismiss state syncs later. |  |  |
| Caregiver action offline | Shows pending delivery, not delivered. |  |  |
| Random matching offline | Does not fake queue or match. |  |  |
| Poor network during sync | App shows pending/retry state without data loss. |  |  |

