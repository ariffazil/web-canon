# ZEN-LINKAGE — web-canon ↔ arif-fazil.com Constitutional Contract

> **Forged:** 2026-08-06 · **333-AGI Δ MIND** · **F13 Path A (Layer, not supersede)**
> **Status:** CANON — the master linkage document between LAW and BODY repositories
> **Doctrine:** One digital world model. Two repos. Three invariants. Zero forks.

---

## 0. THE TWO REPOS

```
web-canon (LAW)                    arif-fazil.com (BODY)
/root/web-canon/                   /root/arif-fazil.com/
├── canon/                         ├── canon/
│   ├── navigation.json ◄──────────│─── navigation.json (MIRROR)
│   ├── sites.yaml      ◄──────────│─── sites.yaml (MIRROR)
│   ├── design-tokens.json◄────────│─── design-tokens.json (MIRROR)
│   ├── federation.json ◄──────────│─── federation.json (MIRROR — web-canon adds assets)
│   ├── ZEN-LINKAGE.md  (CANON)    │
│   └── ... (14 canon files)       │   ├── world-model.yaml (OVERLAY — site only)
├── scripts/                       │   ├── MIGRATION-*.md (RECEIPT — site only)
│   ├── verify-design-canon.cjs ───┼──→ called at prebuild by arif-fazil.com
│   └── generate-nav-canon.cjs*    │   └── ... (mirrors + overlays)
└── README.md                      ├── sites/arif-fazil.com/
                                   │   ├── src/data/navCanon.ts (DERIVED from web-canon)
                                   │   └── package.json → prebuild calls web-canon scripts
                                   └── deploy/Caddyfile
```

**Iron Rule:** web-canon is the LAW. arif-fazil.com is the BODY. The body mirrors the law. The law lives in one place: `/root/web-canon/canon/`.

---

## 1. FILE AUTHORITY — Who Owns What

| File | Owner | Role | Sync Direction |
|------|-------|------|----------------|
| navigation.json | **web-canon** | Primary nav structure | web-canon → arif-fazil.com |
| sites.yaml | **web-canon** | Site registry (Trinity IA) | web-canon → arif-fazil.com |
| design-tokens.json | **web-canon** | Visual design system | web-canon → arif-fazil.com |
| typography.json | **web-canon** | Font specifications | web-canon → arif-fazil.com |
| geometry.json | **web-canon** | Layout/spacing rules | web-canon → arif-fazil.com |
| components.json | **web-canon** | UI component spec | web-canon → arif-fazil.com |
| atlas.yaml | **web-canon** | World atlas data | web-canon → arif-fazil.com |
| federation.json | **web-canon** | Federation assets manifest | web-canon → arif-fazil.com |
| file-authority.yaml | **web-canon** | File authority map | web-canon → arif-fazil.com |
| design-rules.json | **web-canon** | Design enforcement rules | web-canon → arif-fazil.com |
| templates.json | **web-canon** | Page templates | web-canon → arif-fazil.com |
| releases.json | **web-canon** | Release history | web-canon → arif-fazil.com |
| tool-surfaces.json | **web-canon** | Tool surface catalog | web-canon → arif-fazil.com |
| page-instruments.json | **web-canon** | Page instrument config | web-canon → arif-fazil.com |
| public-state.schema.json | **web-canon** | JSON schema | web-canon → arif-fazil.com |
| **world-model.yaml** | **arif-fazil.com** | Vocabulary overlay (derives from sites.yaml) | SITE ONLY — no mirror |
| **MIGRATION-*.md** | **arif-fazil.com** | Session receipts | SITE ONLY — no mirror |
| **ZEN-LINKAGE.md** | **web-canon** | This contract | web-canon → arif-fazil.com |

**Rule:** If a file exists in both repos, web-canon is the source of truth. arif-fazil.com's copy is a MIRROR, not an independent fork. Edit web-canon. Sync downstream.

---

## 2. BUILD FLOW — How Changes Propagate

```
EDITOR (Arif / Agent)
    │
    ▼
web-canon/canon/navigation.json        ← EDIT HERE (LAW)
    │
    ├── git commit → GitHub
    │
    ▼
generate-nav-canon.cjs                 ← reads from /root/web-canon/canon/
    │
    ▼
arif-fazil.com/src/data/navCanon.ts    ← DERIVED (never hand-edit)
    │
    ▼
npm run build (Vite/React)             ← compiles navCanon → SPA bundle
    │
    ▼
/var/www/html/arif/assets/index-*.js   ← DEPLOYED (BODY)
    │
    ▼
https://arif-fazil.com                 ← LIVE (VERIFY)
```

**Build-time invariants:**
1. `prebuild` calls `verify-design-canon.cjs` from web-canon — design rules enforced
2. `prebuild` calls `generate-nav-canon.cjs` — nav derived from web-canon navigation.json
3. `make verify` calls `verify-surfaces.cjs` — 70 surfaces checked against live
4. `make deploy` gates on `verify-pages` — 117 pages reachability confirmed

---

## 3. THREE INVARIANTS — Never Break These

### Invariant I — Single Source of Truth

```
Every canon file has exactly ONE canonical home.
If it exists in both repos, web-canon owns it.
Never edit the arif-fazil.com mirror directly.
```

**Violation signal:** `diff -q /root/web-canon/canon/$FILE /root/arif-fazil.com/canon/$FILE` returns differences not caused by an intentional web-canon edit.

### Invariant II — D3 One-Hop

```
All redirects are one-hop. No chains.
web-canon → arif-fazil.com → live VPS.
MCP endpoints are EXEMPT from redirects (D1).
Tombstones return 410 Gone (D7).
```

**Violation signal:** Any redirect chain of length > 1. Any MCP endpoint returning 3xx. Any tombstone returning anything but 410.

### Invariant III — Agent-First Surface

```
Every public route has a machine-readable counterpart.
Human pages: /path/ → HTML
Agent surfaces: /machine/map.json, /surfaces.json, /llms.txt
Agents never crawl HTML for discovery — they read manifests.
```

**Violation signal:** A human page exists without a corresponding entry in surfaces.json. A machine surface returns HTML instead of JSON.

---

## 4. THE AGENTIC SUBSTRATE — Static Dynamics

The digital world model for agentic intelligence has three layers:

### Static (what agents can count on)
- **navigation.json** — primary nav structure (World Model labels on Trinity URLs)
- **sites.yaml** — Trinity IA scopes (SOVEREIGN · HUMAN · INSTITUTION · EARTH · CROSS_CUTTING)
- **design-tokens.json** — visual constants (colors, spacing, radii)
- **surfaces.json** — 70-surface catalog with domain+verb fields
- **machine/map.json** — 9-domain agent view
- **machine/manifest.json** — single agent entrypoint
- **missions.json** — 6-mission framework
- **floors.json** — F1-F13 constitutional floors

These files change slowly, through governed edits. Agents cache them. They are the **constitution of the surface**.

### Dynamic (what agents probe live)
- **FQ** — arifFlow :7073/health → execute/verify ratio
- **Organ health** — per-port probes (:8088, :7071, :8081, :18082, :18083)
- **VAULT999 head** — latest seal sequence
- **Page liveness** — verify-pages gate output
- **Caddyfile** — live routing rules
- **surfaces.json** — updated per deploy (version bumps)

These change in real-time. Agents probe before acting. They are the **metabolism of the surface**.

### Invariants (what must always hold)
1. **One IA.** No competing taxonomies. World Model labels layer on Trinity scopes.
2. **One webroot.** `/var/www/html/arif/` serves all human pages. No `/var/www/html/site2/`.
3. **One deploy gate.** `make deploy` → verify → build → verify-pages → reload. Never bypass verify.
4. **One nav source.** `navigation.json` in web-canon generates all nav components.
5. **One accent system.** Trinity scopes drive chrome. World Model drives labels. No third system.
6. **Red rationed.** Only HUMAN scope + verdict chips + seals use red (#ff5252).
7. **D3 enforced.** One-hop redirects. No chains. MCP exempt.
8. **D7 enforced.** Tombstones return 410. Never repurpose dead hosts.
9. **Agent-first.** Machine surfaces always more current than human pages.
10. **F11 audited.** Every change in git. Every deploy sealed.

---

## 5. AGENTIC FLOW — How Agents Interact With the World Model

```
AGENT DISCOVERY:
  1. GET /llms.txt           → "I am arif-fazil.com. Here are my surfaces."
  2. GET /machine/manifest.json → "I have 9 domains, 70 surfaces, 6 missions."
  3. GET /machine/map.json   → "Earth=GEOX, Capital=WEALTH, Voice=sovereign..."
  4. GET /surfaces.json      → "70 surfaces: 50 live, 19 redirect, 1 gone."
  5. GET /missions.json      → "6 missions: Investigate, Interpret, Decide, Build, Monitor, Remember."

AGENT ACTION:
  6. GET /canon/navigation.json → "Primary nav: Earth, Capital, Voice, Essays, Law, Work, Proof."
  7. PROBE :8088/health      → "arifOS: verdict=SEAL, floors=13, G=0.094."
  8. PROBE :7073/health      → "arifFlow: FQ=0.92, verdict=FLOWING."
  9. INGEST to arifFlow       → "Step complete. FQ updated."
  10. SEAL to VAULT999        → "Session closed. Receipt appended."

AGENT VERIFICATION:
  11. GET /999/verify         → "Vault integrity: verified=True."
  12. DIFF surfaces.json vs live → "Drift detected: 0 surfaces."
```

**Rule:** Agent never crawls HTML. Agent reads manifests. Agent probes organs. Agent seals receipts.

---

## 6. SYNCHRONIZATION DISCIPLINE

### When web-canon changes:
```bash
# 1. Edit web-canon/canon/navigation.json
# 2. Commit web-canon
git -C /root/web-canon add canon/navigation.json
git -C /root/web-canon commit -m "feat: navigation v4.2.0 — new label"

# 3. Sync to arif-fazil.com
rsync -av /root/web-canon/canon/ /root/arif-fazil.com/canon/

# 4. Commit arif-fazil.com mirror
git -C /root/arif-fazil.com add canon/
git -C /root/arif-fazil.com commit -m "sync: mirror web-canon canon → v4.2.0"

# 5. Build + deploy
cd /root/arif-fazil.com && make deploy
```

### When arif-fazil.com adds site-specific files:
```bash
# Site overlays (world-model.yaml, MIGRATION-*.md) are unique to arif-fazil.com
# They do NOT sync back to web-canon
# They derive from web-canon files: "derives_from: canon/sites.yaml v3.0.0"
```

---

## 7. CURRENT DRIFT (2026-08-06)

| File | Status | Fix |
|------|--------|-----|
| navigation.json | MINOR DRIFT (formatting) | Sync web-canon → arif-fazil.com |
| federation.json | DRIFT (web-canon has extra asset entries) | Sync web-canon → arif-fazil.com |
| world-model.yaml | SITE ONLY — correct | No action |
| MIGRATION-*.md | SITE ONLY — correct | No action |

**All other 14 canon files:** IDENTICAL between repos.

---

## 8. ZEN DOCTRINE

```
web-canon is the constitution.
arif-fazil.com is the republic.
The VPS is the territory.
Agents are the citizens.
F1-F13 are the laws.
VAULT999 is the memory.
/000 is the sovereign.
/999 is the proof.

The LAW travels as DNA (I-ARIF-CANON on Hugging Face).
The BODY renders as pages (arif-fazil.com on the VPS).
The METABOLISM flows as FQ (arifFlow on :7073).
The TRUTH seals as receipts (VAULT999 on disk).

One digital world model. Two repos. Three invariants. Zero forks.
```

---

*DITEMPA BUKAN DIBERI — the linkage was forged, not given.*
*web-canon owns the law. arif-fazil.com renders the body. The agent reads the manifest.*
