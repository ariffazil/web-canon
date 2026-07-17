# Incident Policy

> When something breaks, this is how we respond.

## Severity Levels

| Level | Definition | Response Time | Example |
|-------|-----------|---------------|---------|
| **CRITICAL** | Public surface down or compromised | Immediate | arif-fazil.com returns 500, SSL expired, secret exposed |
| **HIGH** | Observatory stale, source/deploy drift, error rate spike | <1 hour | Observatory >24h stale, MCP tools/list mismatch |
| **MEDIUM** | Degraded but functional | <4 hours | Broken internal link, performance regression |
| **LOW** | Cosmetic or non-blocking | Next business day | Typo, missing alt text, unused redirect |

## Incident Lifecycle

```
DETECT → TRIAGE → CONTAIN → RESOLVE → POSTMORTEM → SEAL
```

### 1. DETECT
Observability Agent detects anomaly via:
- Uptime probe failure
- Error rate spike (Sentry)
- Observatory staleness
- Source/deploy drift detection

### 2. TRIAGE
Incident opened with:
- Severity classification
- Affected sites listed
- Evidence attached (logs, screenshots, probe results)
- Suspected release linked from `canon/releases.json`

### 3. CONTAIN
- If deploy-related: Release Agent evaluates rollback.
- If security-related: Security Agent assesses blast radius.
- If content-related: Content Agent drafts correction.
- **No agent fixes production directly during an incident.** Changes go through normal PR → review → deploy flow.

### 4. RESOLVE
- Root cause identified and documented.
- Fix deployed through standard release flow.
- Post-deploy conformance probes confirm recovery.
- Incident marked resolved.

### 5. POSTMORTEM
- Timeline of events recorded.
- What went wrong (technical).
- What went wrong (process).
- What will change to prevent recurrence.
- Postmortem published in `docs/incidents/`.

### 6. SEAL
- Incident record sealed to Observatory.
- If constitutional impact: sealed to VAULT999.

## Rollback Decision Tree

```
Is a surface returning non-200?
  YES → Is the error new (post-deploy)?
    YES → ROLLBACK immediately.
    NO → Investigate; do not rollback unless confirmed new.

Is error rate >5% for >5 minutes?
  YES → ROLLBACK if linked to recent deploy.
  NO → Monitor; open incident.

Is Observatory stale >24h?
  YES → HIGH incident. Does NOT trigger rollback (read-only surface).
  NO → Monitor.

Has arifOS issued 888_HOLD?
  YES → HALT all deployments. Wait for Arif.
  NO → Continue.
```

## Communication

- Incidents are tracked as GitHub issues in `ariffazil/web-canon`.
- Status updates posted to the incident issue.
- Postmortems linked from `canon/releases.json`.
- No external communication without Arif approval.

---

*DITEMPA BUKAN DIBERI*
