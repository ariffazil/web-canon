#!/usr/bin/env bash
# ==============================================================================
# atlas-sync.sh — web-canon/atlas → live /var/www/html/canon/atlas
# F13 RATIFIED 2026-08-01 · Designed by 333-AGI (Δ MIND)
# ==============================================================================
# Purpose: Sync canonical long-form docs (atlas/) to live mirror.
#          Companion to canon-sync.sh (which handles JSON/YAML canon).
# Scope:   Markdown/text validation, required-files check, atomic rsync,
#          drift test, arifflow receipt.
# Mutations: rsync --delete to /var/www/html/canon/atlas/ (T2).
# Reversibility: Full — backup before sync, restore with rsync from backup.
# ==============================================================================
# Usage:
#   atlas-sync.sh              # dry-run (validate only, no mutation)
#   ATLAS_SYNC_LIVE=1 atlas-sync.sh    # live sync
# ==============================================================================

set -euo pipefail
umask 077

SCRIPT_NAME="atlas-sync"
# shellcheck disable=SC1091
source "$(dirname "$0")/lib.sh"

load_secrets

# ── Paths ───────────────────────────────────────────────────────────────────
SOURCE="${WEB_CANON}/atlas"
LIVE="${LIVE_WEB}/canon/atlas"
TS=$(date -u +%Y%m%dT%H%M%SZ)
DRY_RUN="${ATLAS_SYNC_LIVE:-0}"
FAIL=0

banner "ATLAS SYNC — $TS"

# ── 1. Validate markdown structure ──────────────────────────────────────────
log "1. MarkDown file count"
N=$(count_files "$SOURCE")
log "   files: ${N}"
if [ "$N" -lt 1 ]; then
  fail "atlas: source is empty (no .md files)"
fi

# ── 2. Existence check (supreme constitution + subordinate doctrine) ───────
log "2. Required docs (supreme constitution + subordinate doctrine)"
# Supreme: WEB_ATLAS.md is the F13 SEAL constitution. Required.
if [ -f "$SOURCE/WEB_ATLAS.md" ]; then
  pass "supreme: WEB_ATLAS.md (F13 SEAL — §2 row 14)"
else
  fail "missing: WEB_ATLAS.md (the supreme constitution)"
fi
# Subordinate: STATIC_VS_DYNAMIC.md is the automation paradox doctrine (§2 row 15).
if [ -f "$SOURCE/STATIC_VS_DYNAMIC.md" ]; then
  pass "subordinate: STATIC_VS_DYNAMIC.md (the automation paradox doctrine)"
else
  fail "missing: STATIC_VS_DYNAMIC.md"
fi

# ── 3. No-non-md gate (atlas is .md only) ───────────────────────────────────
log "3. Non-markdown check"
NON_MD=$(find "$SOURCE" -type f ! -name "*.md" 2>/dev/null | wc -l)
if [ "$NON_MD" -gt 0 ]; then
  log "   warning: ${NON_MD} non-.md files found in atlas/"
  find "$SOURCE" -type f ! -name "*.md" 2>/dev/null | sed 's/^/     /'
fi

# ── Gate ────────────────────────────────────────────────────────────────────
if [ "$FAIL" -ne 0 ]; then
  log "BLOCKED: $FAIL validation failure(s). Sync aborted."
  exit 1
fi

# ── 4. Dry-run switch ───────────────────────────────────────────────────────
if [ "$DRY_RUN" != "1" ]; then
  log "DRY RUN — validation passed. Set ATLAS_SYNC_LIVE=1 to sync."
  log "  diff source vs live:"
  diff -rq "$SOURCE" "$LIVE" 2>/dev/null || true
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
emit_receipt "333-AGI/atlas-sync" "atlas sync" "$LIVE" "$N" "$DRIFT_RESULT" "Pass"

# ── Summary ─────────────────────────────────────────────────────────────────
log "SEALED — atlas sync clean. backup=${BACKUP}"
exit 0
