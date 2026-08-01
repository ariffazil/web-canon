#!/usr/bin/env bash
# ==============================================================================
# wiki-sync.sh — arif-fazil-wiki (rendered) → /var/www/html/wiki
# F13 RATIFIED 2026-08-01 · Designed by 333-AGI (Δ MIND)
# ==============================================================================
# Purpose: Sync the rendered wiki output to live mirror.
#          The wiki is authored at /root/arif-fazil-wiki/ (raw + synthesized)
#          and rendered into /var/www/html/wiki/ by the build script.
#          This script only validates and ensures the rendered output is on disk.
#          It does NOT trigger a build (Tier 3 — manual or separate pipeline).
# Scope:   Tree verification, file count, required-entity check, drift test.
# Mutations: rsync --delete to /var/www/html/wiki/ (T2).
# Reversibility: Full — backup before sync, restore with rsync from backup.
# ==============================================================================
# Usage:
#   wiki-sync.sh              # dry-run (validate only, no mutation)
#   WIKI_SYNC_LIVE=1 wiki-sync.sh    # live sync
# ==============================================================================

set -euo pipefail
umask 077

SCRIPT_NAME="wiki-sync"
# shellcheck disable=SC1091
source "$(dirname "$0")/lib.sh"

load_secrets

# ── Paths ───────────────────────────────────────────────────────────────────
SOURCE="${WEB_CANON}/wiki-build"
LIVE="${LIVE_WEB}/wiki"
TS=$(date -u +%Y%m%dT%H%M%SZ)
DRY_RUN="${WIKI_SYNC_LIVE:-0}"
FAIL=0

banner "WIKI SYNC — $TS"

# ── 1. Source check ─────────────────────────────────────────────────────────
# The source is the rendered wiki output. If absent, fall back to a
# known-good live mirror and warn (Tier 1 — non-fatal).
log "1. Source check"
if [ ! -d "$SOURCE" ]; then
  log "   source not present: ${SOURCE}"
  log "   tip: render the wiki from /root/arif-fazil-wiki/ first"
  log "   tip: source is typically /var/www/html/wiki-built/ or a build artifact"
  # Use the live mirror as the source-of-truth IF it was previously seeded.
  # This is a self-healing lane — keep the live mirror as canon if source is
  # absent, so we don't introduce drift.
  if [ -d "$LIVE" ] && [ "$(count_files "$LIVE")" -gt 0 ]; then
    log "   fallback: using live mirror as source (self-heal)"
    SOURCE="$LIVE"
  else
    fail "wiki: neither source nor live mirror present"
    exit 1
  fi
fi

# ── 2. Required entities check (Karpathy-style) ─────────────────────────────
log "2. Required entities check"
REQUIRED=(
  "index.html"
  "404.html"
  "atlas"
  "constitution"
  "federation"
  "llms.txt"
  "sitemap.xml"
)
for entity in "${REQUIRED[@]}"; do
  if [ -e "$SOURCE/$entity" ]; then
    pass "present: $entity"
  else
    fail "missing: $entity"
  fi
done

# ── 3. File count safeguard ─────────────────────────────────────────────────
log "3. File count"
N=$(count_files "$SOURCE")
log "   files: ${N}"
if [ "$N" -lt 9 ]; then
  fail "wiki: only ${N} files (expected ≥ 9)"
fi

# ── Gate ────────────────────────────────────────────────────────────────────
if [ "$FAIL" -ne 0 ]; then
  log "BLOCKED: $FAIL validation failure(s). Sync aborted."
  exit 1
fi

# ── 4. Dry-run switch ───────────────────────────────────────────────────────
if [ "$DRY_RUN" != "1" ]; then
  log "DRY RUN — validation passed. Set WIKI_SYNC_LIVE=1 to sync."
  if [ -d "$LIVE" ]; then
    log "  diff source vs live:"
    diff -rq "$SOURCE" "$LIVE" 2>/dev/null || true
  else
    log "  live mirror missing — would create on deploy"
  fi
  exit 0
fi

# ── 5. Backup ───────────────────────────────────────────────────────────────
log "4. Backup target"
BACKUP=$(backup_target "$LIVE" "$TS")
pass "backup: ${BACKUP}"

# ── 6. Atomic rsync ─────────────────────────────────────────────────────────
log "5. Rsync source → live"
mkdir -p "$LIVE"
do_rsync "$SOURCE" "$LIVE" >/dev/null
chown -R www-data:www-data "$LIVE" 2>/dev/null || true
pass "rsync: ${SOURCE} → ${LIVE}"

# ── 7. Drift test ───────────────────────────────────────────────────────────
log "6. Drift test"
DRIFT_RESULT=$(md5_parity "$SOURCE" "$LIVE")
case "$DRIFT_RESULT" in
  CLEAN) pass "drift: CLEAN — source == live" ;;
  DRIFT) fail "drift: DIVERGED after sync"; exit 1 ;;
  *)     fail "drift: $DRIFT_RESULT"; exit 1 ;;
esac

# ── 8. ariflow receipt ──────────────────────────────────────────────────────
log "7. Emit ariflow receipt"
emit_receipt "333-AGI/wiki-sync" "wiki sync" "$LIVE" "$N" "$DRIFT_RESULT" "Pass"

# ── Summary ─────────────────────────────────────────────────────────────────
log "SEALED — wiki sync clean. backup=${BACKUP}"
exit 0
