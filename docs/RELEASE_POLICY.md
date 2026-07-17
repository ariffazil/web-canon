# Release Policy

> Every deployment is a constitutional act. Follow these rules or HOLD.

## Release Lifecycle

```
PLAN → BUILD → REVIEW → JUDGE → DEPLOY → VERIFY → SEAL
```

### 1. PLAN
- Web Governor classifies the request.
- Canon Agent checks shared truth.
- Release Agent creates release manifest.

### 2. BUILD
- Builder Agent creates isolated branch.
- All code changes committed to feature branch.
- Preview deployment created.

### 3. REVIEW
- Independent model reviews the diff (different model from builder).
- Domain steward validates meaning where applicable.
- QA Agent runs full test matrix.
- Security Agent scans for vulnerabilities.

### 4. JUDGE
- For T3/irreversible deploys: arifOS judge deliberates.
- For T1/T2: auto-proceed after all gates pass.

### 5. DEPLOY
- A-FORGE executes deployment of exact approved commit.
- `deploy-vps.sh` syncs static surfaces.
- Caddy reload only with `--reload-caddy` + 888_HOLD.

### 6. VERIFY
- Post-deploy conformance probes on all 8 surfaces.
- Source commit == build commit == deployed commit verified.
- Observatory snapshot matches release.

### 7. SEAL
- Release recorded in `canon/releases.json`.
- Observatory receipt published.
- VAULT999 sealed (for constitutional-grade releases).

## Mandatory Release Gates

A release fails when ANY of these fail:

```text
☐ typecheck
☐ lint
☐ unit tests
☐ contract tests (sites.yaml ↔ federation.json parity)
☐ Playwright critical journeys
☐ accessibility (zero critical violations)
☐ performance budget (Lighthouse ≥ 90)
☐ broken links (zero internal, zero cross-organ)
☐ canonical URL validation
☐ CodeQL (zero high/critical)
☐ dependency audit (zero critical CVEs)
☐ secret scan (zero findings)
☐ manifest/runtime agreement
☐ source/build/deployed commit agreement
☐ MCP tools/list agreement
☐ public-state schema validation
☐ post-deployment smoke test (all 8 surfaces 200)
☐ Observatory receipt generation
```

**Infrastructure-dependent tests (API probes, MCP lifecycle, Observatory) are non-blocking in PR CI but BLOCKING at release promotion.** They must pass after deployment before the release is marked operational.

## Rollback Policy

Trigger conditions:
- Any surface returns non-200 for >60s post-deploy.
- Error rate >5% for 5 minutes.
- Observatory snapshot stale or mismatched.
- arifOS 888_HOLD issued.

Rollback procedure:
1. Release Agent identifies last known-good release from `canon/releases.json`.
2. Executes rollback through A-FORGE.
3. Runs post-deploy conformance probes.
4. Logs incident.
5. Publishes rollback receipt.

## Tag Format

**vYYYY.MM.DD** — Iron Rule. Never arbitrary version numbers. Software matures by date, not counter.

---

*DITEMPA BUKAN DIBERI*
