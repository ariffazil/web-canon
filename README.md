# 🌐 web-canon

> Shared canon repository for the arifOS web federation.
> **DITEMPA BUKAN DIBERI** — Forged, Not Given.

## What This Is

The **single source of truth** for every site in the `arif-fazil.com` family. Contains:

- **Canon files** (`canon/`) — machine-readable manifests for sites, navigation, design tokens, tool surfaces, and releases.
- **Agent definitions** (`.github/agents/`) — 14 specialized agents with narrow permissions and clear boundaries.
- **Shared packages** (`packages/`) — reusable UI components (navigation, footer, design tokens, public-state client).
- **Tests** (`tests/`) — contracts, links, accessibility, performance, and cross-site journeys.
- **Governance docs** (`docs/`) — site contracts, release policy, authority matrix, incident policy.

## Principle

**Do not give one super-agent every tool.** Build a web operations federation with specialized agents, shared canon files, independent review, and one controlled deployment path.

## The Team (14 Agents)

| # | Agent | Role | Authority |
|---|-------|------|-----------|
| 1 | Web Governor | Root orchestrator | Plan only |
| 2 | Canon Manifest | Shared truth keeper | Edit canon on branch |
| 3 | Information Architecture | Navigation designer | Edit nav on branch |
| 4 | Frontend Builder | Component implementer | Edit code on branch |
| 5 | Content & SEO | Meaning guardian | Edit copy on branch |
| 6 | MCP Integration | Machine surface integrator | Read probes, edit schemas |
| 7 | Quality QA | Adversarial tester | Test + open issues |
| 8 | Security Reviewer | Vulnerability detector | Scan + open issues |
| 9 | Release & Deployment | Controlled executor | Deploy after all gates |
| 10 | Observability | Drift detector | Monitor + open incidents |
| 11 | Archive & Provenance | Historical truth protector | Archive + redirect |
| 12 | GEOX Steward | Earth evidence guardian | Review geology content |
| 13 | WEALTH Steward | Capital computation guardian | Review finance content |
| 14 | WELL Steward | Human readiness guardian | Review readiness content |

## Release Flow

```
PLAN → BUILD → REVIEW → JUDGE → DEPLOY → VERIFY → SEAL
```

Every release must pass 18 mandatory gates before promotion.

## Quick Start

```bash
# Clone
git clone https://github.com/ariffazil/web-canon.git

# Validate canon files
for f in canon/*.json; do
  echo "Validating $f..."
  # ajv validate -s canon/public-state.schema.json -d "$f"
done

# Run contract tests
cd tests/contracts && npm test
```

## Related Repositories

- `ariffazil/arif-sites` — Web estate source, static sites, deployment scripts.
- `ariffazil/arifOS` — Constitutional kernel.
- `ariffazil/A-FORGE` — Execution shell.

---

*Maintained by the Canon Manifest Agent under arifOS F1-F13.*
