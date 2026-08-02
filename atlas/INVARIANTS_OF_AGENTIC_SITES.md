# ⧉ INVARIANTS OF FORGING AGENTIC SITES — 13 Core Laws

> **STATUS:** SEAL · 2026-08-01 · ARIF F13
> **SOURCE:** Sovereign doctrine (2026-08-01) — part of the Atlas triad:
> `STATIC_VS_DYNAMIC.md` (paradox) → `WEB_ATLAS.md` (structure) → `INVARIANTS_OF_AGENTIC_SITES.md` (law)
> **DOCTRINE:** DITEMPA BUKAN DIBERI

---

## Prime invariant

> An agentic site is not a website.
> It is a public execution surface for human meaning, machine reading, and future agent behavior.
> Every mutation is not just design. It is reality editing.

---

## I · Truth Invariants

### 1. Source-of-truth invariant
Never edit the rendered surface if a canonical source exists upstream.
- Result page comes from `ns_results.json` → edit `ns_results.json`, not generated HTML.
- Navigation comes from `navigation.json` → edit canon, not one random page.
- Design comes from tokens → edit tokens, not local CSS.

**Law:** `SOT → generator → page`. Never `page → hand patch → drift`.

### 2. No-local-truth invariant
A subpage must not invent its own truth. "This page says healthy" while canonical status says UNKNOWN/HOLD is forbidden.
Every page claim must point back to: canon · receipt · JSON state · runtime endpoint · human-authored doctrine.

### 3. Static evidence beats dynamic shell
For `/canon/*`, `/999/*`, `.well-known/*`, `llms.txt`, `page.json`, `sitemap.xml` — static evidence must not be swallowed by SPA fallback.

**Law:** Evidence routes before app routes. Canon before SPA.

## II · Design Invariants

### 4. Shell invariant
Every page inherits a shared shell: `HeadCanon → TrinityNav → PageHero → MainContent → Proof/Status → RelatedRoutes → CanonFooter`. No page invents its own body.

### 5. Token invariant
The page may say `<html data-ring="SOUL" data-plane="narrative">` — but may NOT say `body { background: random-new-color; }`.
Agent must use: `tokens.css`, `components.css`, ring, plane, approved classes. Not improvisation.

### 6. Navigation invariant
Every page must answer: Where am I? What is this page for? Where can I go next? What is the proof route?
**Law:** No page-specific navigation copies. Navigation is inherited from canon.

## III · Routing Invariants

### 7. Route identity invariant
Every route must declare: `route / owner / audience / ring / plane / page_type / data_source / status / canonical_or_retired`.
Without this the agent doesn't know if it is editing a human page, proof surface, dashboard, retired redirect, machine endpoint, or agent instruction surface.

### 8. Retirement invariant
Retired routes redirect cleanly. No zombie routes. No orphan pages. No duplicate canonical meanings.

## IV · Agent Behavior Invariants

### 9. Agent wants alignment, not completion
Bad agent: finish task, look nice, push. Forged agent: preserve canon, reduce drift, maintain route truth, keep design aligned, verify after mutation, produce receipt. Boring correctness beats creative flourish.

### 10. Diff-before-mutation invariant
Always produce before action: What will change? Why? Which routes affected? Which canon files? Which generated files? What rollback path?

### 11. Verify-before-SEAL invariant
No change is complete until: build passes · routes pass · canon serves actual files · tokens loaded · nav present · ring/plane declared · visual diff checked · machine surfaces valid · receipt emitted. **No verification means not done.**

## V · Human-Knowledge Invariants

### 12. What the human must know (meaning layer)
Purpose, audience, what must never be misrepresented, which pages are sacred, which experimental, which routes are public authority, which claims require proof, acceptable vs unacceptable drift.
The human does not need to remember file paths — but must decide: purpose, authority, tone, risk, truth boundary, release acceptance.

### 13. What the agent must know (system layer)
Source-of-truth files, routes, build chain, sync paths, design tokens, layout contracts, test commands, deployment surfaces, rollback method, verification checklist.
The agent's most important knowledge is not "how to change" — it is: **what not to change, what to verify, what to ask human, where canon lives.**

## VI · The Known/Unknown Contract

### The agent must know about the human's knowns
ARIF owns: doctrine, intent, moral boundary, final authority, meaning of the site, desired outcome.
The agent must surface: technical consequence, hidden dependency, route conflict, cache issue, static/dynamic mismatch, unknown state, risk of drift.

> **ARIF owns meaning. Agent owns operational clarity.**

### The agent must know about the human's unknowns
The agent must actively protect ARIF from hidden unknowns:
- Which file is actually served?
- Which route is shadowed by SPA?
- Which generated file will overwrite manual edits?
- Which cache layer is stale?
- Which page uses old CSS?
- Which nav is duplicated?
- Which route is zombie?
- Which claim does not match machine state?

**Expose unknowns before mutation. Do not let hidden state surprise the human after deploy.**

### Unknowns must become declared objects
```yaml
unknowns:
  - id: U1
    question: "Does /canon/*.md serve static markdown or SPA shell?"
    risk: "AI agents cannot retrieve authoritative Atlas"
    test: "curl -s /canon/WEB_ATLAS.md | head"
    owner: agent
    verdict: "HOLD until verified"
```
Unknowns are not shame. Unknowns are control points.

## VII · The 13 Core Invariants (table)

| # | Invariant | Law |
|---|---|---|
| I1 | ATLAS before action | Read atlas.yaml before touching anything |
| I2 | Canon before code | Canon is the law, code implements it |
| I3 | SOT before rendered page | Edit source of truth, never generated output |
| I4 | Shared shell before subpage freedom | One shell, many pages |
| I5 | Tokens before local CSS | No page-local colors/type/nav |
| I6 | Navigation before content | Nav inherited from canon |
| I7 | Static evidence before SPA fallback | /canon/*, /999/*, .well-known/* serve real files |
| I8 | Diff before mutation | Show what/will/rollback before acting |
| I9 | Verification before SEAL | No verify, not done |
| I10 | Unknowns declared, not hidden | Unknowns are control points |
| I11 | Human owns meaning | ARIF decides purpose/authority/risk |
| I12 | Agent owns operational clarity | Agent surfaces consequence/drift/conflict |
| I13 | No automation without reversibility | Every mutation has a rollback path |

## VIII · The short doctrine

> Agentic site forging is not web design.
> It is governed mutation of a public truth surface.
> If the agent does not know the Atlas, it is blind.
> If the human does not know the risk, authority is fake.
> If unknowns are not declared, automation becomes BANGANG.
>
> **ARIF decides meaning; ATLAS defines structure; agent mutates only inside declared boundaries; verification turns change into truth.**

---

*SEALED 2026-08-01 · ARIF F13 · v1.0.0*
*DITEMPA BUKAN DIBERI — Yang benar dikarang, bukan diberi.*
