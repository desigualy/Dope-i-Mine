# Role Routing QA Checklist

| Check | Expected result | Pass/Fail | Notes |
| --- | --- | --- | --- |
| New normal user completes onboarding | User lands on home dashboard. |  |  |
| New caregiver signs in before confirmation | User routes to caregiver confirmation. |  |  |
| Confirmed caregiver signs in | User routes to caregiver dashboard or caregiver-aware home. |  |  |
| Supported user completes onboarding | User lands on normal home with support options available. |  |  |
| Both-role user completes onboarding | User can reach home and caregiver tools where account permissions allow. |  |  |
| Caregiver with temporary password signs in | Force-password-change route appears before other setup routes. |  |  |
| Force-password-change required | `/force-password-change` takes priority over onboarding and caregiver routing. |  |  |
| Normal user signs in | Normal user never routes to caregiver confirmation. |  |  |
| Logout then login | Correct route is preserved for the account type. |  |  |
| App restart after login | Role state and onboarding completion are preserved. |  |  |
| Onboarding incomplete user signs in | User routes to onboarding gate/setup. |  |  |
| Confirmed caregiver revisits confirmation URL | User is moved to caregiver dashboard. |  |  |

