# ⧉ WEB_ATLAS — arifOS Web Federation Constitution

> **STATUS:** SEAL · 2026-08-01
> **OWNER:** ARIF (F13 SOVEREIGN)
> **CANON REPO:** `/root/web-canon` (source of truth)
> **LIVE MIRROR:** `https://arif-fazil.com/canon/`
> **CODE X LINK:** ATLAS333 — `333_MIND_ATLAS.md` · `ATLAS333_BRIDGE.md` · `atlas.py`
> **DOCTRINE:** DITEMPA BUKAN DIBERI

---

## THE ONE LAW

> **No page may define its own identity, navigation, route, color, or proof status.**
> **It must inherit from Atlas.**
>
> Human edits consult Atlas. Coder edits implement Atlas. Agent edits obey Atlas.
> Automation verifies against Atlas.

---

## §1 · The Ten Truths (invariants)

1. **The root explains the whole.** `arif-fazil.com` is the entry point. Every other surface links back.
2. **Organ sites deepen one domain.** GEOX=earth, WEALTH=capital, WELL=readiness. No crossover without explicit handoff.
3. **MCP connects machines.** `mcp.arif-fazil.com` is transport, not a marketing site.
4. **arifOS governs authority.** Kernel (8088) adjudicates. Observatory proves. Separate surfaces.
5. **A-FORGE executes only after approval.** No self-authorizing builds.
6. **The Observatory proves current state.** Signed snapshots. Release must match.
7. **VAULT999 preserves receipts.** Immutable append-only. Never edited, never deleted.
8. **Arif remains final authority.** F13 SOVEREIGN. 888 decides irreversible.
9. **Unknown must remain unknown.** Down = "Unknown", never fabricated healthy.
10. **Live state never hard-coded into page copy.** Tool counts, organ status, versions — from Observatory or live probes only.

## §2 · Canon file set (the law books)

| File | What it governs | Agent must |
|---|---|---|
| `canon/navigation.json` | Trinity nav, sovereign strip, breadcrumb, footer | Never invent nav. Read + inherit. |
| `canon/design-tokens.json` | Colors, rings (SOUL/MIND/BODY), spacing, radius | Never pick a color. Query token by ring. |
| `canon/typography.json` | Fonts, scales, weights | Never choose a font. |
| `canon/components.json` | Allowed components + props | Never create new design. Fill known containers. |
| `canon/templates.json` | Page types (home/proof/article/status/tool/organ/archive/error/redirect) | Never design from zero. Use the template. |
| `canon/routes.yaml` | Route registry, owner, audience, canonical/retired status | Never add a route without registry entry. |
| `canon/redirects.yaml` | Old paths → canonical paths | Never break a redirect. |
| `canon/sites.yaml` | All federation sites + contracts | Never cross site boundaries. |
| `canon/public-state.schema.json` | Machine-readable truth schema | Never publish state outside schema. |
| `canon/federation.json` | Organ topology | Never claim an organ that isn't in the map. |
| `canon/geometry.json` | Ring geometry | Never invent structure. |
| `docs/SITE_CONTRACTS.md` | Per-site Must / Must NOT | Never violate a contract. |
| `docs/ROUTING_INVARIANTS.md` | Routing invariants | Never break a routing law. |
| `docs/AGENT_LAYOUT_CONTRACT.md` | Layout for agents | Never invent layout. |
| `atlas/WEB-FEDERATION-MAP.md` | Repos, webroots, wire topology | Consult before touching infra. |
| `atlas/STATIC_VS_DYNAMIC.md` | The automation paradox doctrine | Read before mutating any surface. |
| `atlas/INVARIANTS_OF_AGENTIC_SITES.md` | The 13 core invariants (I1-I13) | Bind every mutation. The law. |

## §3 · Route registry (canonical)

| Route | Owner | Audience | Purpose |
|---|---|---|---|
| `/` | SOUL | human | Identity root |
| `/000` | SOUL | agent+human | Genesis, scars, wisdom |
| `/999` | VERIFY | auditors | Verification, proof, vault |
| `/arifos` | MIND | human+agent | Observatory proof |
| `/aaa` | BODY | operators | Cockpit |
| `/geox` | EARTH | analysts | Earth intelligence |
| `/wealth` | CAPITAL | analysts | Capital intelligence |
| `/economics` | CAPITAL | human | Briefing (redirect target) |
| `/well` | READINESS | self | Vitality |
| `/mcp` | MCP | developers | Gateway |
| `/forge` | EXECUTION | agents | A-FORGE surface |
| `/canon` | ATLAS | all | This constitution, live |
| `/politics/ns-election` | SOUL | human | PRN16 results |
| `/politics/shadow` | SOUL | human | Shadow Decoder (sovereign door) |

## §4 · Design rings

| Ring | Token prefix | Role | Example |
|---|---|---|---|
| SOUL | `--red-*` | human, jagged, fractal | `/`, `/000` |
| MIND | `--cyan-*` | machine, grid, precise | `/arifos`, `/mcp` |
| BODY | `--gold-*` | action, rounded, organic | `/forge`, `/aaa` |

An agent may never say "this button should be blue". It must ask:
> Which ring is this page? Which token applies?

## §5 · Page types (templates)

`home` · `proof` · `article` · `system_status` · `tool` · `organ` · `archive` · `error` · `redirect`

Each template fixes: hero, purpose block, primary action, secondary action, proof block, related routes, footer, machine metadata. Agents fill containers, never invent.

## §6 · Content model (schema-bound)

Content lives in JSON, not random HTML:
```json
{
  "title": "…",
  "audience": "human|agent|auditor",
  "intent": "…",
  "ring": "SOUL|MIND|BODY",
  "proof": "…"
}
```
The page renders from the model. The agent edits the model, not the layout.

## §7 · Agent workflow (the only one allowed)

```
1. READ ATLAS          (canon/*.json + this file)
2. IDENTIFY ROUTES     (registry + redirects)
3. IDENTIFY COMPONENTS (components.json)
4. PROPOSE CHANGE      (diff)
5. SHOW DIFF           (no silent edits)
6. RUN BUILD
7. RUN ROUTE CHECKS    (web_zen doctor)
8. RUN VISUAL CHECKS
9. PRODUCE RECEIPT
10. WAIT FOR ARIF SEAL
```

PROMPT → EDIT → DEPLOY → HOPE is FORBIDDEN. It is entropy.

## §8 · ATLAS333 link (codex → web)

The web Atlas is the **territory map**. ATLAS333 is the **cognitive substrate** — 33 paradox axes,
7 zones, TEARFRAME thresholds, GPV routing.

| ATLAS333 artifact | Location | Web Atlas use |
|---|---|---|
| `333_MIND_ATLAS.md` | `/root/arifOS/static/arifos/theory/000/` | Paradox doctrine |
| `ATLAS333_BRIDGE.md` | `/root/arifOS/core/shared/` | Theory→runtime map |
| `atlas.py` | `/root/arifOS/core/shared/` | Λ/Θ/Φ routing engine |
| `paradox_gate.py` | `/root/arifOS/arifosmcp/core/enforcement/` | Mutation checks |

Key paradoxes binding web work:
- **P3** — Map is not territory. The repo + webroot + Caddy is reality; canon is the map.
- **P17** — Atlas must be useful, committed, current.
- **P30** — Forgery must be detectable (receipts, hashes).
- **Automation paradox** — autonomy saves hands, demands stronger judgment. Governance is survival architecture, not bureaucracy.

## §9 · Verification checklist (minimum gates)

- [ ] Build passes
- [ ] All canonical routes return 200
- [ ] Retired routes redirect correctly
- [ ] No broken internal links
- [ ] Trinity nav on every page (no site-specific copies)
- [ ] Design tokens loaded (no hardcoded colors)
- [ ] Machine files exist: `llms.txt`, `llms.json`, `page.json`, `sitemap.xml`
- [ ] No invented claims (F2)
- [ ] No orphan pages
- [ ] `web_zen doctor` GREEN

## §10 · Search & discovery strategy

**For humans:** `/canon/` index page lists every canon file with purpose.

**For agents:**
- `llms.txt` — references `/canon/WEB_ATLAS.md` (this file) as the site constitution
- `sitemap.xml` — includes `/canon/atlas/` long-form docs
- `robots.txt` — allows `/canon/` crawl
- `page.json` per page — audience + ring + intent machine metadata
- `.well-known/agent.json` — agent card declaring "I obey Atlas"

**For verification:** `web_zen.py doctor` checks canon files exist + canon-sync drift gate.

---

*SEALED 2026-08-01 · ARIF F13 · WEB_ATLAS v1.0.0*
*DITEMPA BUKAN DIBERI — Yang benar dikarang, bukan diberi.*
