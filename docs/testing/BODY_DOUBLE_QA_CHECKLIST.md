# Body Double QA Checklist

| Check | Expected result | Pass/Fail | Notes |
| --- | --- | --- | --- |
| Dope-i body double starts | Session opens. |  |  |
| Dope-i body double pauses | Session pauses without losing state. |  |  |
| Dope-i body double resumes | Session resumes. |  |  |
| Dope-i body double ends | Session closes and summary appears where implemented. |  |  |
| Known-person invite sends | Invite is created for known person. |  |  |
| Known-person invite accepts | Session opens for both sides. |  |  |
| Known-person invite declines | Invite closes without session. |  |  |
| Random eligibility blocks unsafe users | Restricted/ineligible users cannot enter random matching. |  |  |
| Random match opens anonymous session | Participant labels are anonymous. |  |  |
| Group body double respects max size if implemented | Group does not exceed configured maximum. |  |  |
| Leave button works | User can leave every session state. |  |  |
| Report participant works | Report is saved and user can leave. |  |  |
| Reported session appears in moderation console | Moderation console lists report. |  |  |
| Restricted user retries random/group | User cannot re-enter restricted matching. |  |  |
| Offline random matching | App does not fake queue or match while offline. |  |  |

