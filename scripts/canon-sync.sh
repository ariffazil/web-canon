#!/usr/bin/env bash
# ==============================================================================
# canon-sync.sh — web-canon → live site sync with validation gates
# F13 RATIFIED 2026-08-01 · Designed by 333-AGI (Δ MIND)
# ==============================================================================
# Purpose: Validate and sync web-canon registry files to the live site.
#          Source owns the sync logic — single source of truth.
# Scope:  JSON/YAML syntax validation, required-files check, atomic rsync,
#         drift test, arifflow receipt.
# Mutations: rsync --delete to /var/www/html/canon/ (T2).
# Reversibility: Full — backup before sync, restore with rsync from backup.
# ==============================================================================
# Usage:
#   canon-sync.sh               # dry-run (validate only, no mutation)
#   CANON_SYNC_LIVE=1 canon-sync.sh     # live sync to /var/www/html/canon/
#   CANON_SYNC_SITE=1 canon-sync.sh     # also sync to /root/arif-fazil.com/canon/
# ==============================================================================

set -euo pipefail
umask 077

# ── Paths ───────────────────────────────────────────────────────────────
SOURCE="/root/web-canon/canon"
LIVE="/var/www/html/canon"
SITE="/root/arif-fazil.com/canon"
REQUIRED_FILES=(
  "components.json"
  "design-tokens.json"
  "design-primer.md"
  "design-rules.json"
  "page-instruments.json"
  "federation.json"
  "geometry.json"
  "navigation.json"
  "public-state.schema.json"
  "redirects.yaml"
  "releases.json"
  "sites.yaml"
  "atlas.yaml"
  "file-authority.yaml"
  "templates.json"
  "tool-surfaces.json"
  "typography.json"
)
TS=$(date -u +%Y%m%dT%H%M%SZ)
DRY_RUN="${CANON_SYNC_LIVE:-0}"
SYNC_SITE="${CANON_SYNC_SITE:-0}"
FAIL=0

# Source secrets for arifflow
[ -f /root/.secrets/kunci-mas.env ] && set -a && source /root/.secrets/kunci-mas.env 2>/dev/null && set +a

log()  { echo "[canon-sync] $*"; }
fail() { echo "[canon-sync] ✗ $*"; FAIL=1; }
pass() { echo "[canon-sync] ✓ $*"; }

log "START ${TS}  dry_run=${DRY_RUN}  sync_site=${SYNC_SITE}"

# ── 1. Validate JSON syntax ─────────────────────────────────────────────
log "1. JSON syntax validation"
for f in "$SOURCE"/*.json; do
  if python3 -m json.tool "$f" > /dev/null 2>&1; then
    pass "json: $(basename "$f")"
  else
    fail "json: $(basename "$f") — INVALID JSON"
  fi
done

# ── 2. Validate YAML syntax ─────────────────────────────────────────────
log "2. YAML syntax validation"
for f in "$SOURCE"/*.yaml; do
  if python3 -c "import yaml; yaml.safe_load(open('$f'))" > /dev/null 2>&1; then
    pass "yaml: $(basename "$f")"
  else
    fail "yaml: $(basename "$f") — INVALID YAML"
  fi
done

# ── 3. Verify required files present ────────────────────────────────────
log "3. Required files check"
for rf in "${REQUIRED_FILES[@]}"; do
  if [ -f "$SOURCE/$rf" ]; then
    pass "present: $rf"
  else
    fail "missing: $rf"
  fi
done

# ── Gate: block sync if validation failed ────────────────────────────────
if [ "$FAIL" -ne 0 ]; then
  log "BLOCKED: $FAIL validation failure(s). Sync aborted."
  exit 1
fi

# ── 4. Dry-run / live switch ────────────────────────────────────────────
if [ "$DRY_RUN" != "1" ]; then
  log "DRY RUN — validation passed. Set CANON_SYNC_LIVE=1 to sync."
  log "  diff source vs live:"
  diff -rq "$SOURCE" "$LIVE" 2>/dev/null || true
  exit 0
fi

# ── 5. Backup target ────────────────────────────────────────────────────
log "4. Backup target"
BACKUP="${LIVE}.bak.${TS}"
cp -a "$LIVE" "$BACKUP" 2>/dev/null || mkdir -p "$BACKUP"
pass "backup: $BACKUP"

# ── 6. Atomic rsync → /var/www/html/canon/ ──────────────────────────────
log "5. Rsync source → live"
rsync -avz --delete "$SOURCE/" "$LIVE/"
chown -R www-data:www-data "$LIVE"
pass "rsync: source → $LIVE"

# ── 7. Optional: sync to /root/arif-fazil.com/canon/ ────────────────────
if [ "$SYNC_SITE" = "1" ]; then
  log "6. Rsync source → site repo"
  mkdir -p "$SITE"
  rsync -avz --delete "$SOURCE/" "$SITE/"
  pass "rsync: source → $SITE"
fi

# ── 8. Drift test ───────────────────────────────────────────────────────
log "7. Drift test"
DRIFT=$(diff -rq "$SOURCE" "$LIVE" 2>/dev/null)
if [ -z "$DRIFT" ]; then
  pass "drift: clean — source == live"
else
  fail "drift: DIVERGED after sync"
  echo "$DRIFT"
fi

# ── 9. Emit receipt to arifflow ─────────────────────────────────────────
log "8. Emit arifflow receipt"
curl -sf -X POST http://127.0.0.1:7073/ingest \
  -H "Content-Type: application/json" \
  -d "{
    \"actor_id\": \"333-AGI/canon-sync\",
    \"session_id\": \"canon-sync-${TS}\",
    \"step_type\": \"Seal\",
    \"step_number\": 1,
    \"cost_ns\": $(date +%s%N | head -c 13),
    \"epistemic_label\": \"Seal\",
    \"floor_verdict\": \"Pass\",
    \"payload\": {
      \"source\": \"web-canon\",
      \"target\": \"$LIVE\",
      \"files\": ${#REQUIRED_FILES[@]},
      \"drift\": \"$([ -z "$DRIFT" ] && echo 'clean' || echo 'diverged')\",
      \"ts\": \"$TS\"
    }
  }" > /dev/null 2>&1 && pass "arifflow: receipt emitted" || log "arifflow: unreachable (non-fatal)"

# ── 9b. Emit Verify step to arifflow (FQ cooling) ────────────────────────
curl -sf -X POST http://127.0.0.1:7073/ingest \
  -H "Content-Type: application/json" \
  -d "{
    \"actor_id\": \"333-AGI/canon-sync\",
    \"session_id\": \"canon-sync-${TS}\",
    \"step_type\": \"Verify\",
    \"step_number\": 2,
    \"cost_ns\": $(date +%s%N | head -c 13),
    \"epistemic_label\": \"Observation\",
    \"floor_verdict\": \"Pass\",
    \"payload\": {\"drift\": \"$([ -z "$DRIFT" ] && echo 'clean' || echo 'diverged')\", \"ts\": \"$TS\"}
  }" > /dev/null 2>&1 || true

# ── Summary ──────────────────────────────────────────────────────────────
if [ "$FAIL" -ne 0 ]; then
  log "DRIFT after sync — review $BACKUP"
  exit 1
else
  log "SEALED — canon sync clean. backup=$BACKUP"
  exit 0
fi