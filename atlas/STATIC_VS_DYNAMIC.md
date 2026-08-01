---
title: STATIC ↔ DYNAMIC — The Agentic Web Split
version: 2026-08-01
epoch: SEAL-2026-08-01-web-zen-fix
actor: kimi-code/FI-008
sovereign: ARIF (F13)
doctrine: DITEMPA BUKAN DIBERI
atlas: web-canon/atlas/STATIC_VS_DYNAMIC.md
---

# ⧉ Static vs Dynamic — The Agentic Web Split

> **ATLAS333 self-note (P3):** This map is not the territory. The territory is the live federation
> at `/var/www/html/*` and the 7 organ ports. The map is committed to be useful (P17).
> The split is governance, not physics — static files *can* become dynamic, and dynamic
> services *can* write static artifacts. The rule is: **what is the source of truth, and
> who mutates it?**

## 1. The separating axis

```
                        source-of-truth →      mutation model
                        ────────────────      ──────────────
  STATIC ───────────►  git repo (web-canon)    rsync + md5 verify
                        + arif-fazil-wiki        (declared, scheduled,
                        + arif-fazil.com build    idempotent)

  DYNAMIC ──────────►  arifOS kernel (8088)    forge_pipeline +
                        + arifFlow (7073)        lease + SCT +
                        + per-organ port         seal to VAULT999
                                                (proved, lease-bound,
                                                 irreversible)
```

**The rule:** if the artifact is *files on disk served verbatim*, it is static.
If the artifact is *compute produced on request* (often without a file existing),
it is dynamic. Hybrid cases (e.g. `/missions` is a SPA shell that renders mission
cards) are classified by *what gets mutated* — the content is static, the shell
is dynamic.

## 2. Static surfaces — the file-truth registry

| Path | Source | Sync | Current HEAD |
|---|---|---|---|
| `/var/www/html/canon/` | `/root/web-canon/canon/` | `canon-sync.sh` | 6bb138a (12 JSON/YAML) |
| `/var/www/html/canon/atlas/` | `/root/web-canon/atlas/` | `atlas-sync.sh` (NEW) | (initial) |
| `/var/www/html/wiki/` | `/var/www/html/arif-fazil-wiki/` (rendered) | `wiki-sync.sh` (NEW) | (manual deploy) |
| `/var/www/html/_shared/` | `/root/arif-fazil.com/public/_shared/` | via `deploy-vps.sh` | (build artifact) |
| `/var/www/html/arif/` | `/root/arif-fazil.com/dist/` | via `deploy-vps.sh` | 9455e41 (SPA) |
| `/var/www/html/arifos/` | `/opt/arifos/app/static/` | via systemd `arifos` | (kernel build) |
| Root docs (`AGENTS.md`, `README.md`, `DEPLOY.md`, `FEDERATION.md`) | `/root/arif-fazil.com/` | via `deploy-vps.sh` | (committed) |
| Agent manifests (`llms.txt`, `agents.txt`, `missions.json`, `surfaces.json`) | `/root/arif-fazil.com/public/` | via `deploy-vps.sh` | (committed) |

**Static mutation contract (F1 AMANAH):**
- Source-of-truth = git repo
- Sync = `rsync -avz --delete` with explicit backup before each sync
- Drift = `diff -rq source live` after sync
- Drift detected = `exit 1` + arifFlow receipt with `floor_verdict: Hold`
- Failure recovery = `rsync backup → live` (reversible in seconds)

## 3. Dynamic surfaces — the compute-truth registry

| Path | Organ | Port | Lease | Seal |
|---|---|---|---|---|
| `/api/status`, `/api/build-info`, `/api/federation-probe` | arifOS / FLAME | 8088 / 18901 | required | yes |
| `/mcp`, `/mcp/<organ>` | arifOS MCP | 8088 | required | yes |
| `/sse` | arifOS SSE | 8088 | required | yes |
| `/arifos/*` | arifOS cockpit | 8088 | required | yes |
| `/federation/*`, `/verify/*`, `/organs/*` | arifOS | 8088 | required | yes |
| `/pulse/*` | arifFlow | 7073 | required | yes |
| `/audit/*` | arifOS | 8088 | required | yes |
| `/api/flame/*` | FLAME | 18901 | required | yes |
| `/api/organs/{arifos,geox,wealth,well,aforge,aaa}` | arifOS gateway | 8088 | required | yes |
| `/wealth/{gold,oil,gas}/*` | WEALTH | 18082 | required | yes |
| `/geox/*` | GEOX | 8081 | required | yes |
| `/well/*` | WELL | 18083 | required | yes |
| `/forge/*` | A-FORGE | 7071 | required | yes |
| `/aaa/*` | AAA | 3001 | required | yes |
| `/connect/*` | AAA Cockpit | 3001 | required | yes |

**Dynamic mutation contract (F13 SOVEREIGN + F11 AUDITABILITY):**
- Every call = `forge_pipeline` or `forge_execute` with `session_id` + `actor_id`
- Leases granted by `arifOS kernel arif_lease` (SCT-borne)
- Every irreversible action = `arif_seal` → VAULT999 append
- `floor_verdict: Void` = no execution; `Hold` = human review; `Pass` = clean

## 4. The orchestration — `agentic-web.sh`

```
┌──────────────────────────────────────────────────────────────┐
│  agentic-web.sh (single entry point)                         │
│  ─────────────────────────────────                           │
│                                                               │
│  1. STATIC PHASE (idempotent, scheduled)                       │
│     ├─ canon-sync.sh     ─► md5 verify                        │
│     ├─ atlas-sync.sh     ─► md5 verify                        │
│     ├─ wiki-sync.sh      ─► tree verify                       │
│     └─ emit: StaticSeal → arifFlow (floor_verdict: Pass)     │
│                                                               │
│  2. DYNAMIC PHASE (health, scheduled)                         │
│     ├─ forge_health_check (5 organs)                          │
│     ├─ flow_health (arifFlow FQ)                              │
│     └─ emit: DynamicSeal → arifFlow (floor_verdict: Pass)    │
│                                                               │
│  3. ENTROPY GATE (always)                                     │
│     ├─ diff source vs live (static)                           │
│     ├─ gate vs liveness (dynamic)                             │
│     └─ exit 0 only if both clean                              │
│                                                               │
│  Reversibility: every step is git-revertable and re-runnable. │
│  Authority: T1 (autonomous), T2 only on demand.              │
└──────────────────────────────────────────────────────────────┘
```

## 5. The irreducibles — 888_HOLD items

Two structural impossibilities remain outside autonomous lane:

1. **`/wiki/` Caddy handler** — T2 single-organ deploy. Caddy needs a
   `handle /wiki/* { root * /var/www/html/wiki file_server }` block above
   the catch-all SPA. **Reason for hold:** audit pattern requires 888 ack
   for first-time Caddy reload after audit verdict.

2. **`arif-sites` orphan decommission** — T3 irreversible. The directory
   `/root/arif-sites/` is a duplicate of `/root/arif-fazil.com/` (same
   git remote, same HEAD, different inode). **Reason for hold:** tracked
   repo deletion requires 888_HOLD per F1.

Both are documented in the wire map and will be re-surfaced each session
until 888 acts.

## 6. ATLAS333 paradoxes honored

| Paradox | Manifestation | Resolution |
|---|---|---|
| **P3** map≠territory | The map is committed as `map` in the atlas | Self-marked in §0 header |
| **P17** model wrong but useful | Model has gaps (2 holds, 6 stale refs) | Hold items named and tracked |
| **P26** gate prevents progress | `set -euo pipefail` aborts on every FAIL | Gates are honest — failure is witnessed |
| **P30** audit trail traces | Every sync → arifFlow receipt | Hash-chained, immutable |
| **P31** seal=irreversible | Once published, only git revert | Documented in §5 |

## 7. Doctrine — DITEMPA BUKAN DIBERI

This split is **forged, not given**. It is the result of one day of audit
(2026-07-31 → 2026-08-01) and may evolve. The test is always: does it
reduce entropy? Does it automate in a governed way? Does it honor F1-F13?

If the answer to any is *no*, the split is wrong.

— DITEMPA BUKAN DIBERI
