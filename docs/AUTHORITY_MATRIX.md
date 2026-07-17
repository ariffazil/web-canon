# Authority Matrix

> Who can do what in the arifOS web federation. Enforced by GitHub Environments + Rulesets + arifOS judge gate.

## Agent Authority Table

| Agent | Observe | Draft Branch | Edit Code | Edit Copy | Create PR | Review PR | Merge | Deploy | Rollback | Access Secrets |
|-------|---------|-------------|-----------|-----------|-----------|-----------|-------|--------|----------|---------------|
| **Web Governor** | ✅ | ❌ | ❌ | ❌ | Issues only | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Canon Manifest** | ✅ | ✅ | ✅ (canon) | ❌ | ✅ | ✅ (canon) | ❌ | ❌ | ❌ | ❌ |
| **Info Architecture** | ✅ | ✅ | ✅ (nav) | ✅ (labels) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Frontend Builder** | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Content & SEO** | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **MCP Integration** | ✅ (probes) | ✅ | ✅ (schemas) | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Quality QA** | ✅ | ❌ | ❌ | ❌ | Issues only | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Security Reviewer** | ✅ (scans) | ❌ | ❌ | ❌ | Issues only | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Release & Deploy** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ (after gates) | ✅ (after SEAL) | ✅ | ✅ (runtime) |
| **Observability** | ✅ (monitor) | ❌ | ❌ | ❌ | Issues only | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Archive Provenance** | ✅ | ✅ | ✅ (archive) | ✅ (banners) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **GEOX Steward** | ✅ | ❌ | ❌ | ✅ (review) | ❌ | ✅ (geology) | ❌ | ❌ | ❌ | ❌ |
| **WEALTH Steward** | ✅ | ❌ | ❌ | ✅ (review) | ❌ | ✅ (capital) | ❌ | ❌ | ❌ | ❌ |
| **WELL Steward** | ✅ | ❌ | ❌ | ✅ (review) | ❌ | ✅ (readiness) | ❌ | ❌ | ❌ | ❌ |
| **arifOS Kernel** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **A-FORGE** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ (after SEAL) | ✅ | ✅ (runtime) |

## Permanent Separation

**No single agent possesses all three:**

```
production secrets + merge authority + deployment authority
```

| Capability | Who holds it |
|------------|-------------|
| Production secrets | Release Agent (runtime only), A-FORGE (runtime only) |
| Merge authority | Release Agent (only after all gates pass) |
| Deployment authority | A-FORGE (only after arifOS SEAL) |

## Action Classification

| Action | Tier | Gate |
|--------|------|------|
| Read, observe, plan | T1 AUTO-DO | None |
| Draft branch, edit code, create PR | T1 AUTO-DO | None |
| Multi-file refactor, new dependency | T2 ANNOUNCE | 10s window |
| Merge to main | T2 PRIVILEGED | All mandatory gates + Release Agent |
| Deploy to production | T2 PRIVILEGED | All gates + A-FORGE after SEAL |
| Caddy reload | T3 888_HOLD | Arif required |
| DNS change | T3 888_HOLD | Arif required |
| Delete production data | T3 888_HOLD | Arif required |
| Force push to main | HARAM | Never |
| VAULT999 deletion | HARAM | Never |

## Sovereign Override

Arif (F13 SOVEREIGN) may override any authority boundary. All agents must recognize sovereign signals: "buat ja la", "jalan terus", "just do it", "ok", "confirmed".

---

*DITEMPA BUKAN DIBERI*
