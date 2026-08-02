# PRIMER-1 — Federation Design Canon

> **STATUS:** SEAL · 2026-08-01 · ARIF F13 · v1.0.0
> **INTENDED HOME:** canon/design-primer.md (human doctrine) + canon/design-tokens.json (machine law)
> **RATIFICATION PROTOCOL:** Phase 2 — promoted from proposal (forge_work/proposals/design/2026-08-01-primer-1/)
> **DOCTRINE:** DITEMPA BUKAN DIBERI — even the pixels are forged, not given.

---

## 0. Doctrine

**One canon, two renderings.** The human eye reads color, type, texture; the agent parser reads schema, channel, verdict. Both must express the same constitution — so every human token has a machine twin. Design is not decoration; it is the F4 Clarity floor made visible.

Three constraints from the Architect:

1. **Primer colors only** — red, blue, yellow, and their honest mixtures (green = blue + yellow). No purple, no gradients of the Google kind, no synthetic neons.
2. **One unified geometry** — orthogonal fractals (the grid) crossed with toroidals (the cycle). Straight lines for law, curves for life.
3. **Tactile** — every button must feel like a physical switch. The federation judges like a blowout preventer, not a vibe.

---

## 1. Color — cognitive semantics

Color is assigned by meaning, not taste. A visitor must know which organ they are inside within 300 ms, before reading a word.

### 1.1 The constitutional palette

| Family | Range | Cognitive meaning | Territory |
|---|---|---|---|
| YELLOW (primer) | amber → sand | warmth, vitality, the 2 a.m. human | /human/* — WELL, MakcikGPT, substrate |
| BLUE (primer) | deep marine → slate | law, structure, institutions, capital | /institution/* — arifOS, A-FORGE, AAA, WEALTH, PM shadows |
| GREEN-BLUE (mixture) | teal → viridian → basin green | earth, ocean, sediment, depth | /earth/* — GEOX, HERMES, Kinabalu Basin, mcp membrane |
| RED (primer, rationed) | maroon → signal red | sovereignty, scar, verdict, warning | /arif/* sovereign strip + ALL 888/void states + seals |

**Red is rationed.** It appears only where sovereignty or judgment is present: the /arif strip, verdict chips (888_HOLD, VOID), seal marks (999). If red is everywhere, it means nothing. Maruah is scarce by definition.

Neutral bedrock: warm paper (human side) and carbon (agent side) — see §5.

### 1.2 Scales (5 steps each, from primer to range)

**YELLOW (Human)**
| Token | Hex | Name | Use |
|---|---|---|---|
| y-100 | #FBF3D9 | paper-sand | backgrounds |
| y-300 | #F2D98C | soft amber | cards, fills |
| y-500 | #D9A62E | primary amber | actions, brand |
| y-700 | #8F6A14 | deep honey | text on light |
| y-900 | #4A3608 | umber | headlines |

**BLUE (Institution)**
| Token | Hex | Name | Use |
|---|---|---|---|
| b-100 | #E4EBF2 | mist | backgrounds |
| b-300 | #9DB8CE | steel | cards, borders |
| b-500 | #2E5F8A | marine | actions, brand |
| b-700 | #1B3A57 | deep marine | text |
| b-900 | #0C1F31 | abyss | headlines |

**GREEN-BLUE (Earth / GEOX)**
| Token | Hex | Name | Use |
|---|---|---|---|
| e-100 | #DFF0EA | shallow | backgrounds |
| e-300 | #8CC3B2 | reef | cards |
| e-500 | #2E8A70 | viridian | actions, brand |
| e-700 | #17584A | basin | text |
| e-900 | #0A2E27 | trench | headlines |

**RED (Sovereign — rationed)**
| Token | Hex | Name | Use |
|---|---|---|---|
| r-300 | #D97B6C | clay | seal backgrounds only |
| r-500 | #B3362B | signal | verdicts, 888, warnings |
| r-700 | #7A1F18 | maroon | sovereign text/strip |
| r-900 | #3D0E0A | deep scar | VOID state |

**NEUTRALS**
| Token | Hex | Name | Use |
|---|---|---|---|
| paper | #FAF7F0 | human-side canvas | warm, low saturation |
| ink | #1A1712 | human-side body text | |
| carbon | #101216 | agent-side canvas | |
| bone | #E8E6DF | agent-side primary text | |

**Contrast guarantees:** every *-500 action color passes WCAG AA (≥4.5:1) against its *-100 background and against ink. *-700/900 text colors pass AAA (≥7:1). Verify in CI (token lint) — a color that fails contrast is a constitutional violation, not a style bug.

### 1.3 Cognitive contrast rules

1. **One family per territory.** A page in /earth/* renders green-blue chrome; a stray institutional blue card inside it is a border incident.
2. **Cross-links carry their home color.** A link from /earth/geox to /institution/wealth keeps the blue chip — you see the border before you cross it. This is the visual analog of the URL alias table.
3. **Mixtures only where the trinity mixes.** The AAA bridge (center tile) may blend blue→teal because it is the membrane. Nothing else blends.
4. **Dark mode = value inversion, never hue shift.** Amber stays amber on carbon; it does not become gold-orange-pink.

---

## 2. Typography — one superfamily, three voices

**IBM Plex** — a single superfamily with Sans, Serif, and Mono cut on the same skeleton. One geometry, three registers. Open license, full Malay/English Latin coverage, tabular figures. (Self-host the subset woff2 in web-canon so all organs render identical type with zero external calls — sovereign typography.)

| Voice | Face | Use |
|---|---|---|
| Human voice | Plex Sans | UI, navigation, body on all public pages |
| Doctrine voice | Plex Serif | /laws, /arif/writings, doctrine, long-form — the written word gets serifs, like a sealed document |
| Machine voice | Plex Mono | data, code, telemetry, verdict chips, MCP surfaces, footers with vault refs |

**Scale — fractal** (ratio √2 ≈ 1.414, the octave of paper sizes):

| Token | Size | Use |
|---|---|---|
| t--1 | 11.9px | captions, vault refs (mono) |
| t-0 | 16.8px | body |
| t+1 | 23.8px | section titles |
| t+2 | 33.6px | page titles |
| t+3 | 47.6px | trinity tile heroes |

Line-height 1.5 body / 1.15 titles. Measure ≤ 68ch for doctrine voice. Numerals in data always `font-feature-settings: "tnum"` — columns of NPV and depth must align like a well log.

---

## 3. Geometry — orthogonal fractals × toroidals

The federation's form language: the grid is orthogonal and fractal; the cycle is toroidal. Law is square; life is round; and every page shows both.

### 3.1 Orthogonal fractal grid

- Base unit **u = 4px**. Spacing scale is fractal doubling: 1u, 2u, 4u, 8u, 16u, 32u, 64u (4→256px). No arbitrary margins, ever.
- Layout grid: 12 columns on desktop, collapsing 12→6→1. Breakpoints at 640 / 1024 / 1440.
- **Fractal corner notch**: the signature motif. Cards and panels carry a stepped square notch (8u → 4u → 2u) cut into one corner — an orthogonal fractal (H-tree echo) that is recognizably federation at any size. The notch is generated from one SVG path token, so it is identical everywhere.
- Borders: 1px *-300, never 2px, never dashed except for 888_HOLD (dashed = not yet ratified).

### 3.2 Toroidal cycle

- **Radii system** — this is where tactile life enters:
  - Human side: radius-md = **12px** on interactive elements (buttons, inputs, chips) — the torus cross-section: soft, pressable, alive.
  - Agent/data side: radius-sm = **2px** — machined, square, orthogonal.
  - Full torus (radius-full) reserved for the mission wheel and trinity ring only.
- **The Trinity Ring**: homepage and every organ page header carries the torus mark — three arcs (yellow, blue, green-blue) forming a broken ring around the AAA bridge center. It is the federation's coat of arms; drawn once in canon as SVG, imported by all.
- **Mission wheel**: /missions/ six missions arranged on a torus (Investigate · Interpret · Decide · Build · Monitor · Remember). Selecting a mission rotates the wheel — the same component reused in AAA cockpit at radius-sm square form for agents.

### 3.3 Composition rule

Every page = orthogonal body + one toroidal anchor. The fractal grid carries content (law); exactly one toroidal element per view carries meaning (cycle) — the ring, the wheel, or a radial status dial. **Two toruses per page is a design VOID.**

---

## 4. Tactility — buttons as physical switches

The federation judges like a BOP: positive travel, audible detent, visible state. Buttons are modeled as machined keys with 2px of travel.

### 4.1 The four states (all interactive elements)

| State | Transform | Shadow |
|---|---|---|
| REST | translateY(0) | 0 2px 0 family-700 (keycap sits proud) |
| HOVER | translateY(-1px) | 0 3px 0 family-700 (key rises to meet) |
| ACTIVE | translateY(2px) | 0 0 0 + inset 0 2px 4px (full travel, seat the contact) |
| DISABLED | opacity .45, no shadow, cursor: not-allowed | key removed from panel |

Timing: transform 90ms cubic-bezier(.2,.9,.3,1) — fast, mechanical, no bounce. Bounce is for toys; this is a console.

### 4.2 The three button grades

| Grade | Look | Use |
|---|---|---|
| SEAL (primary) | solid *-500, ink text, 2px travel shadow in *-700 | one per view — the committing action |
| HOLD (secondary) | paper fill, 1px *-500 border, dashed on hover | pending, reversible, draft actions — dashed = not yet ratified |
| VOID (danger) | r-500 fill — the only red button in the federation | irreversible actions; requires hold-to-confirm (800ms press) like a real BOP panel |

Focus ring: 2px offset in family-500 + 2px paper gap — keyboard users get the same tactile certainty as pointer users. `prefers-reduced-motion` collapses all travel to opacity-only.

### 4.3 Verdict chips (cross-site constant)

`999_SEAL` solid family-500 · `888_HOLD` dashed r-500 border · `VOID` solid r-900. Mono font, uppercase, radius-sm even on human side — verdicts are machine objects surfaced to humans; they keep the machine's square geometry. This is the contrast made tangible.

---

## 5. The two renderings — human side vs agent side

| Token | Human side | Agent side |
|---|---|---|
| Canvas | paper #FAF7F0 | carbon #101216 |
| Text | ink #1A1712 | bone #E8E6DF |
| Geometry | radius 12px (toroidal) | 2px (orthogonal) |
| Density | spacious, 4u–32u rhythm | compact, 1u–8u rhythm |
| Type voice | Plex Sans | Plex Mono |
| Color role | wayfinding & warmth | channel & verdict |
| Motion | 90ms mechanical | none (instant state) |
| Elevation | travel shadows (tactile) | flat, 1px borders (machined) |

Agent side = AAA cockpit, /opencode/, observatory snapshots, status pages, any surface whose primary reader is a machine-assisted operator. It is deliberately less comfortable — the human side invites you in; the agent side assumes you're working.

**Structural contrast (the agent's real "design")**: agents don't see color — they read canon. The design system's machine twin:

- color → `channel` field in every JSON surface (`"channel": "earth"` ≡ green-blue)
- font → stable schema version (`schema: canon/v2026.08`)
- tactile state → explicit state: `rest|hold|sealed|void` enums, never implicit
- navigation flow → missions.json + capability.json graph — an agent traverses the federation exactly as a human traverses the trinity nav, through the same canon registry. **One IA, two sensory modalities.**

---

## 6. Flow navigation — all sites, one nervous system

Navigation is generated from canon/navigation.json — no organ invents its own chrome.

The universal frame (every page, every organ):

1. **Sovereign strip** (top, 32px, maroon r-700): Arif · Sovereign → /arif + current release tag from releases.json + verdict chip of the page's own seal status. Thin, always present, the only permanent red.
2. **Trinity nav** (below strip): HUMAN (amber) · INSTITUTION (blue) · EARTH (teal) tiles + AAA bridge center. Active territory shown by filled tile; others outlined.
3. **Breadcrumb = URL = canon path.** /earth/geox/basins/kinabalu renders as three chips, each in its territory color. The breadcrumb is generated from the path, not hand-written — if URL and breadcrumb ever disagree, that's a sentinel-firable offense.
4. **Mission footer** (every page): the six missions as text links + federation map (organ chips in their colors). A lost human is always one click from a mission; a lost agent is one fetch from /missions.json.

Flow rules:

- Any page reachable in ≤3 clicks from a trinity tile.
- Cross-territory links announce themselves (colored chip, §1.3 rule 2).
- Dead ends forbidden: every 404/410 renders the trinity nav + mission footer (tombstone pages included — a 410 is a sealed page, it gets the maroon strip and a VOID chip, not an apology).
- Keyboard: 1/2/3 jumps to trinity territories, 0 to sovereign strip, ? opens mission wheel. Same shortcuts everywhere.

---

## 7. Token deliverable (drop into web-canon)

```json
// canon/design-tokens.json (sketch — full file generated from this primer)
{
  "schema": "canon/design-tokens/v2026.08",
  "color": {
    "human":       { "100": "#FBF3D9", "300": "#F2D98C", "500": "#D9A62E", "700": "#8F6A14", "900": "#4A3608" },
    "institution": { "100": "#E4EBF2", "300": "#9DB8CE", "500": "#2E5F8A", "700": "#1B3A57", "900": "#0C1F31" },
    "earth":       { "100": "#DFF0EA", "300": "#8CC3B2", "500": "#2E8A70", "700": "#17584A", "900": "#0A2E27" },
    "sovereign":   { "300": "#D97B6C", "500": "#B3362B", "700": "#7A1F18", "900": "#3D0E0A" },
    "neutral":     { "paper": "#FAF7F0", "ink": "#1A1712", "carbon": "#101216", "bone": "#E8E6DF" }
  },
  "font": { "family": "IBM Plex", "voices": { "human": "Sans", "doctrine": "Serif", "machine": "Mono" },
            "scale_ratio": 1.414, "base_px": 16.8 },
  "geometry": { "unit_px": 4, "spacing": [1,2,4,8,16,32,64], "radius": { "human": 12, "machine": 2, "torus": "full" },
                "motif": { "notch": "fractal-corner-8-4-2", "ring": "trinity-torus", "wheel": "mission-torus" } },
  "motion": { "travel_ms": 90, "easing": "cubic-bezier(.2,.9,.3,1)", "press_travel_px": 2 },
  "territory_map": { "/human": "human", "/institution": "institution", "/earth": "earth", "/arif": "sovereign", "/laws": "doctrine" },
  "machine_twin": { "channel_field": "channel", "state_enum": ["rest","hold","sealed","void"] }
}
```

CI lint (web-canon pipeline): contrast ratios ≥ AA, one torus per view, red usage only in sovereign/verdict scopes, radii ∈ {2, 12, full}. A failing page does not deploy — F4 enforced at build time.

---

## 8. Summary — the primer in one breath

> Yellow is the human, blue is the institution, green-blue is the earth, and red — rationed — is the sovereign's verdict. One Plex family speaks three voices. The grid is an orthogonal fractal; the ring is a torus; every button travels 2px like a machined key. Humans navigate by color and touch; agents navigate the same canon by channel and state. Two renderings, one law.

DITEMPA BUKAN DIBERI — even the pixels are forged, not given.

---

*SEALED 2026-08-01 · ARIF F13 · PRIMER-1 v1.0.0 · ratified into canon/design-primer.md*
