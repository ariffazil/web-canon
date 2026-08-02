---
title: WEB-FEDERATION-MAP
version: 2026-08-01
epoch: SEAL-2026-08-01-web-zen-fix
actor: kimi-code/FI-008
sovereign: ARIF (F13)
audit_basis: F1-F13 verifier verdict (this session)
doctrine: DITEMPA BUKAN DIBERI
state: CANON
owner: ARIF
allowed_mutators: [A-FORGE, ARIF]
filed_under: atlas/
file_authority:
  state: CANON
  owner: ARIF
  allowed_mutators: [A-FORGE, ARIF]
  registry: canon/file-authority.yaml (sovereign SEAL 2026-08-01)
  origin: moved from /var/www/html/canon/WEB-FEDERATION-MAP.md (2026-08-01)
          — was orphan, would have been deleted by next canon-sync --delete.
          Now lives in web-canon/atlas/ where it survives sync.
---

# ⧉ Web Federation Map — 2026-08-01

> **ATLAS333 self-note (P3):** This map is not the territory. The territory is `/root/*` repos, `/var/www/html/` webroots, and the Caddy/Cloudflare membrane. The map is committed to be useful (P17). Forgery is detectable (P30).

## 1. Repositories (10 + 1 orphan + 1 setter)

| Repo | GitHub | Role | Local | Branch | HEAD | Dirty |
|---|---|---|---|---|---|---|
| `web-canon` | ariffazil/web-canon | **Canon source of truth** (12 files) | `/root/web-canon` | `chore/canon-lint-palette-zoning` | `6bb138a` | 0 |
| `arif-fazil.com` | ariffazil/arif-fazil.com | Site build (Vite + React) | `/root/arif-fazil.com` | `main` | `9455e41` | 3 |
| `arif-sites` | ariffazil/arif-fazil.com (same remote) | **ORPHAN** — duplicate of arif-fazil.com | `/root/arif-sites` | `main` | `9455e41` | 3 |
| `arif-fazil-wiki` | (NOT a repo) | Wiki docs at `/var/www/html/arif-fazil-wiki/` | filesystem | n/a | n/a | n/a |
| `arifOS` | ariffazil/arifOS | Constitutional kernel | `/root/arifOS` | `main` | (n) | 0 |
| `arifFlow` | ariffazil/arifFLOW | Receipt metabolism (port 7073) | `/root/arifFlow` | `next-horizon/unified-federation-low-entropy` | `424b25a` | 0 |
| `GEOX` | ariffazil/GEOX | Earth organ (port 8081) | `/root/GEOX` | `main` | (n) | 0 |
| `WEALTH` | ariffazil/WEALTH | Capital organ (port 18082) | `/root/WEALTH` | `main` | (n) | 0 |
| `WELL` | ariffazil/WELL | Vitality organ (port 18083) | `/root/WELL` | `main` | (n) | 0 |
| `AAA` | ariffazil/AAA | Federation cockpit (port 3001) | `/root/AAA` | `main` | (n) | 1 |
| `A-FORGE` | ariffazil/A-FORGE | Federated actuator (port 7071/7072) | `/root/A-FORGE` | `main` | (n) | 1 |
| `HERMES` | ariffazil/HERMES | Telegram bridge | `/root/HERMES` | `main` | (n) | 5 |

## 2. Live webroots under `/var/www/html/`

```
/var/www/html/
├── arif                       # arif-fazil.com main site (Vite + React)
├── arif-fazil-wiki/           # Wiki docs (NOT served — Caddy points to /wiki/)
├── wiki/                      # Placeholder 404.html + agents/ (Caddy serves here)
├── arifos/                    # arifOS kernel cockpit
├── aaa/                       # AAA A2A gateway
├── forge/                     # A-FORGE actuator
├── apex/                      # APEX adjudication
├── geox/                      # GEOX earth intelligence
├── waw/                       # WAW (placeholder)
├── wawa/                      # WAWA (placeholder)
├── arifosmcp/                 # arifOS MCP surface
├── canon/                     # web-canon live mirror (12 files, synced)
├── kanzu/                     # (legacy)
├── _shared/                   # shared assets
├── _legacy/                   # legacy content
├── abangsado-flex.mp4         # media
├── agents.txt                 # agents manifest
├── AGENTS.md, README.md, etc. # top-level docs
└── Caddyfile (symlink)        # /etc/caddy/Caddyfile
```

## 3. Wire topology (the diagram)

```
                  ┌──────────────────────────┐
                  │      web-canon           │  ← source of truth
                  │  (12 files, 6bb138a)     │
                  │  scripts/canon-sync.sh   │
                  └────────────┬─────────────┘
                               │
                  ┌────────────┴─────────────┐
                  │   canon-sync.sh gate     │  ← JSON/YAML validation
                  │   (CANON_SYNC_LIVE=1)    │     backup + drift test
                  └────────────┬─────────────┘
                  ┌────────────┴──────────────┐
                  │                           │
       ┌──────────▼────────┐        ┌─────────▼──────────┐
       │ arif-fazil.com/   │        │ /var/www/html/     │
       │ canon/            │        │ canon/             │
       │ (site copy)       │        │ (live mirror)      │
       │ 9455e41           │        │ md5 ✓ matches      │
       └───────────────────┘        └────────────────────┘
                                                  │
                                                  ▼
                                          Caddy :80/:443
                                                  │
                                                  ▼
                                       arif-fazil.com
                                       (public surface)
```

## 4. Wire state — what's done vs missing

### ✅ DONE (this session, 2026-08-01 ~12:55–13:02 UTC)
- `canon-sync.sh` created at `/root/web-canon/scripts/canon-sync.sh` (6325 bytes, 156 lines, commit `6bb138a`)
- `arif-fazil.com/canon/` wired (commit `9455e41`) — 4 new files + 5 updated
- `/var/www/html/canon/` synced — `design-tokens.json` md5 `049f6eec2d78a72df3a1a89b1cac1aab` matches across all 3 copies
- Zero diff: `web-canon/canon/ ↔ arif-fazil.com/canon/ ↔ /var/www/html/canon/`

### ❌ STILL MISSING (to be addressed by this wire — confirmed by audit F2)
1. **`deploy-vps.sh` does not call `canon-sync.sh`** — the wire is source-only; deploys won't sync. Atlas333 P26: gate prevents drift but also prevents forward motion; we wire it now.
2. **`/wiki/` returns 404** — Caddyfile points to `/var/www/html/wiki/` (placeholder 404.html only); real wiki at `/var/www/html/arif-fazil-wiki/`. **Path mismatch.** Atlas333 P3: the map (Caddyfile) doesn't match the territory (file system).
3. **`arif-sites` orphan** — separate directory, same git remote, same HEAD as arif-fazil.com. Different inode. Likely a leftover from `arif-sites → arif-fazil.com` rename. Atlas333 P9: the archive shapes what is knowable. Two archives, two truths.

### 🟡 HELD FOR 888_HOLD (next session)
- **2b. `wiki/` Caddy fix** — T2 single-organ deploy with `caddy reload`. Audit pattern: held for sovereign authorization.
- **2c. arif-sites decommission** — T3 irreversible. Audit verdict explicitly required sovereign authorization.

## 5. ATLAS333 paradoxes active in this work

| Paradox | Active because | Resolution |
|---|---|---|
| **P3** map≠territory | We are writing the map | Mark it as map (not territory) on every output |
| **P17** model wrong but useful | Our wire model has gaps | Hold 2b/2c openly; don't claim wire is complete |
| **P26** gate prevents progress | Holding 2b/2c for sovereign | 888_HOLD is the gate; we honor it |
| **P30** audit trail traces | carry_forward + cooling_ledger | Hash-chained; backup before edit |
| **P31** seal=irreversible | Kabarkan publishes to live canon | git revert is the only undo path |
| **P32** floor protects dignity | Audit verdict strict on scope substitution | We honor the verdict (W2 done in 1 step) |

## 6. arifFlow state (port 7073, live)

- FQ = **1.5329** (BALANCED 🟡)
- Worst actor: `arifprime` FQ=0.0 (Stuck); `aed-v1` FQ=0.39 (Stuck)
- `kimi-code/FI-008` FQ=1051.0 (Overheat) — this session
- `333-AGI` FQ=15002.7 (Overheat) — even hotter

## 7. Federated organs (live)

| Organ | Port | Status |
|---|---|---|
| arifOS | 8088 | ✅ healthy |
| A-FORGE | 7071 / 7072 | ✅ healthy |
| GEOX | 8081 | ✅ healthy |
| WEALTH | 18082 | ✅ healthy |
| WELL | 18083 | 🟡 degraded (biometric staleness) |
| AAA | 3001 | ✅ healthy |
| arifFlow | 7073 | ✅ healthy (FQ balanced) |

## 8. Doctrine

- **F1 AMANAH** — every wire step is git-revertable. backup before sync. never `--delete` without source-of-truth.
- **F2 TRUTH** — md5 parity across all 3 canon copies verified at the time of this map.
- **F4 CLARITY** — map is structured; gaps are named explicitly.
- **F11 AUDITABILITY** — every wire step has a receipt (cooling_ledger, arifFlow_FQ).
- **F13 SOVEREIGN** — hold items (2b/2c) require 888_HOLD.

— DITEMPA BUKAN DIBERI
