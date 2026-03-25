# Incident Response Runbook

## Severity levels

- **SEV-1**: production outage, data corruption risk, auth/security breach
- **SEV-2**: major feature unavailable, degraded core flow
- **SEV-3**: minor degradation with workaround

## First 15 minutes

1. Confirm incident scope (affected platform, users, module).
2. Open incident channel and assign incident commander.
3. Freeze risky deploys (`release-publish`, `supabase-deploy`) until triage.
4. Capture baseline evidence: logs, failing workflow URLs, timestamps.

## Triage checklist

- Is user data integrity at risk?
- Is authentication or RLS bypass suspected?
- Is rollback safer than hotfix?
- Which owner is required (`lib/`, `supabase/`, workflows)?

## Mitigation actions

- **App issue**: stop rollout / roll back store release.
- **Function issue**: run `.github/workflows/supabase-function-rollback.yml`.
- **Migration issue**: apply compensating migration and verify RLS/indexes.
- **Secret leak**: rotate secret immediately, invalidate compromised tokens.

## Communication

- Internal update every 30 minutes for SEV-1/SEV-2.
- Public status note if user impact is visible and prolonged.
- Record timeline (what happened, actions, outcomes).

## Recovery and closeout

1. Validate core flows (auth, check-in, sync, purchase, notifications).
2. Re-enable paused deployments.
3. Create postmortem within 24h (root cause, detection gap, prevention tasks).
4. Link postmortem action items to backlog and owners.
