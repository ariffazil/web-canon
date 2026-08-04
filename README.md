# web-canon

> Shared **law** for the arif-fazil.com web federation — registries, not pages.  
> **DITEMPA BUKAN DIBERI**

## What this is

| Path | Role |
|------|------|
| `canon/` | Machine-readable SOT: navigation, design tokens, sites, redirects, file-authority |
| `atlas/` | Human maps and invariants |
| `scripts/` | `canon-sync`, design verify, lint, gates |
| `docs/` | Contracts and authority matrix |

**Not this repo:** React pages, deploy tree, Makcik articles — those live in **`ariffazil/arif-fazil.com`**.

There is **no** `packages/` tree yet. Do not invent shared UI packages until a second surface needs them.

## Doctrine

```
web-canon      = CANON law     (what must be true)
arif-fazil.com = IMPLEMENTATION (must match or fail build)
live /var/www  = VERIFY only
```

- **Nav SOT:** `canon/navigation.json` → site `generate-nav-canon.cjs` → `navCanon.ts` → ArrowNavbar/Footer  
- **Hybrid IA (LIVE):** Earth · Economics · World · Writing · Doctrine · Missions · 999  
- **Trinity IA:** `DRAFT_FUTURE` — do not render until product paths exist  
- **Preserve:** politics, MakcikGPT, commodities, PETRONAS `/vitals/`, `/000`, `/999`, agent doors  

## Wire

```bash
# Validate JSON
python3 -m json.tool canon/navigation.json >/dev/null

# Sync registries to live + site copy (VPS)
CANON_SYNC_LIVE=1 CANON_SYNC_SITE=1 ./scripts/canon-sync.sh

# Site prebuild already runs:
#   node /root/web-canon/scripts/verify-design-canon.cjs
```

## Related

- **Site (body):** https://github.com/ariffazil/arif-fazil.com  
- **Kernel:** https://github.com/ariffazil/arifOS  
- **Actuator:** https://github.com/ariffazil/A-FORGE  
- **Live:** https://arif-fazil.com  

## Branches

Default: **`main` only.** Feature branches delete after merge.

---

*Canon Manifest under arifOS F1–F13. v4.0.0 hybrid nav 2026-08-04.*
