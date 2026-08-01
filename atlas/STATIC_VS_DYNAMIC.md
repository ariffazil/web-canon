---
title: STATIC ↔ DYNAMIC — The Agentic Web Split
version: 2026-08-01
epoch: SEAL-2026-08-01-web-zen-fix
actor: kimi-code/FI-008
sovereign: ARIF (F13)
doctrine: DITEMPA BUKAN DIBERI
atlas: web-canon/atlas/STATIC_VS_DYNAMIC.md
supreme: web-canon/atlas/WEB_ATLAS.md (§2 row 15 — "The automation paradox doctrine")
state: CANON
owner: ARIF
allowed_mutators: [A-FORGE, ARIF]
filed_under: atlas/
mutation_class: EDIT_EXISTING
file_authority:
  state: CANON
  owner: ARIF
  allowed_mutators: [A-FORGE, ARIF]
  registry: canon/file-authority.yaml (sovereign SEAL 2026-08-01)
  process_scar: "I2 — initially created without sovereign promotion; sovereign
    named it in WEB_ATLAS §2 row 15 retroactively, then canonized via
    canon/file-authority.yaml. The scar is preserved below in
    Self-Attestation — not erased."
---

# ⧉ Static vs Dynamic — The Agentic Web Split

> **SUPREME CONSTITUTION:** [`WEB_ATLAS.md`](./WEB_ATLAS.md) — F13 SEAL · 2026-08-01.
> This doc is the *automation paradox layer* under §1 of the WEB_ATLAS.
> All work below must obey the One Law: **inherit from Atlas — never invent.**
>
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

---

## Self-Attestation Against I1–I13

```
State: SELF_ATTESTATION
Authority: Proposal evidence, not independent canon
Scope: this file's mutations (5 commits since 2026-08-01T13:23Z)
```

The 13 invariants proposed for multi-agent file governance (Atlas.md §8 leak).
Self-attestation is **proposal evidence**, not sovereign canon. The sovereign
verdict governs; this section only records what the agent did and did not do.

### Result — sharpened by sovereign review (2026-08-01T13:50Z)

| # | Invariant | Verdict | Evidence |
|---|---|---|---|
| I1 | One canon, many proposals | ✓ pass | Operated only in web-canon/atlas/ + web-canon/scripts/ |
| I2 | No new canonical file without promotion | ✓ closed | Originally created this file without sovereign promotion; sovereign later named it in WEB_ATLAS §2 row 15 (retroactive) **and** canonized via canon/file-authority.yaml (59440e0). Scar preserved — see below. |
| I3 | No write without file lease | ✗ hard gap | `lease.status: ABSENT` in every receipt (workaround, not fix) |
| I4 | No hand-edit of DERIVED files | ✓ pass | Wrote only to source (web-canon/{atlas,scripts}), never to build outputs |
| I5 | No duplicate docs for same authority | ✓ pass | Subordinated to WEB_ATLAS.md via frontmatter.supreme |
| I6 | All new files in allowed zone | ✓ pass | web-canon/atlas/ (atlas zone) and web-canon/scripts/ (script registry) |
| I7 | Every file declares state | ✓ pass | Sovereign created canon/file-authority.yaml (59440e0) — the registry is the answer |
| I8 | Unknown file authority = HOLD | n/a | Authority was known for every file touched |
| I9 | Patch existing canon before inventing | ✓ pass | Did not invent a competing Atlas |
| I10 | Every mutation includes rollback | ◐ conditional | atlas-sync: cp -a → ${dst}.bak.${TS} before rsync (proven) |
| I11 | Every mutation produces receipt | ◐ conditional | emit_receipt with UUID v4 → arifFlow 200 OK (live verified) |
| I12 | Agents propose / apply / verify, not decide truth | ✓ pass | Proposed doctrine, applied sync, verified drift |
| I13 | ARIF or Judge promotes proposal into canon | ✓ pass | Sovereign WEB_ATLAS.md + file-authority.yaml SEAL 2026-08-01 |

**Tally (post-sovereign):** 9 strong · 2 conditional (I10, I11) · 1 N/A (I8) ·
1 hard gap (I3, lease enforcement) · 0 scar (I2 closed by sovereign canonic promotion).

**Sovereign parallel work that closed the original gaps:**
- `59440e0 feat(file-authority): canon registry` — created /canon/file-authority.yaml with
  full state graph (CANON/DERIVED/SCRATCH/PROPOSAL/RECEIPT/RETIRED/UNKNOWN) + per-file
  owner + allowed_mutators. Closes I7 directly.
- `b69f9ac feat(atlas): WEB_ATLAS constitution + 13 invariants + file authority groundwork`
  — added INVARIANTS_OF_AGENTIC_SITES.md as the 13-invariant doctrine.
- `e0dba56 feat(nav): canon navigation.json now owns primary nav` — `primary_links`
  synced from src/data/siteContent.ts. No page-owned navigation.

### Why the gaps are not closing this session

- **I3 lease** — `forge_lease` MCP exists but is not wired into rsync paths.
  Wiring it would be a **T2 governance change** that requires sovereign
  authorization to define who deserves a lease. Per sovereign verdict 2026-08-01:
  *do not fake a lease. Declare absence truthfully.* This is honored by
  `lease.status: ABSENT` in every receipt.
- **I7 state declaration** — closed at the **system level** by sovereign's
  canon/file-authority.yaml (59440e0). The registry IS the answer to I7;
  per-file state declaration is now redundant with the registry.

### Proposal envelope (per I2)

If sovereign authorizes the file-authority registry, the schema is:

```yaml
# /canon/file-authority.yaml (PROPOSAL — not yet created)
files:
  - path: web-canon/atlas/STATIC_VS_DYNAMIC.md
    state: PROPOSAL_PROMOTED
    owner: kimi-code/FI-008
    promoted_by: WEB_ATLAS.md §2 row 15
    mutation_class: EDIT_EXISTING
  - path: web-canon/atlas/WEB-FEDERATION-MAP.md
    state: PROPOSAL
    owner: kimi-code/FI-008
    promotion_required: true
  - path: web-canon/scripts/lib.sh
    state: TOOL
    owner: kimi-code/FI-008
    mutation_class: REPLACEABLE
  - path: web-canon/scripts/canon-sync.sh
    state: TOOL
    owner: kimi-code/FI-008
    mutation_class: REPLACEABLE
```

This is the **proposal only**. Per I2, the file itself must wait for
sovereign/Judge promotion. Until then, this section is the schema reference.

— DITEMPA BUKAN DIBERI
