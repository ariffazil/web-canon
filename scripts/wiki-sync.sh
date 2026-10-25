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
# SOURCE reconciled with the real producer (2026-10-25).
# /root/scripts/wiki-build.sh runs `mkdocs build -f <cfg>` with
# site_dir=${LIVE_WEB}/wiki — it never writes ${WEB_CANON}/wiki-build.
# Pointing the gate at a path nothing creates made it block on correct
# state and print an instruction that could not satisfy the check.
# Producer owns the write; this lane validates the produced tree.
SOURCE="${LIVE_WEB}/wiki"
LIVE="${LIVE_WEB}/wiki"
TS=$(date -u +%Y%m%dT%H%M%SZ)
DRY_RUN="${WIKI_SYNC_LIVE:-0}"
FAIL=0

banner "WIKI SYNC — $TS"

# ── 1. Source check ─────────────────────────────────────────────────────────
# DEFECT 2026-10-22: this lane used to "self-heal" by adopting the live
# mirror as its source when the staging dir was absent. That turned the
# validator into a no-op copier — it could only re-copy what was already
# live, so new content could never arrive and absence looked healthy.
# Fail loudly instead. Absent live tree = the build lane is dead, which is
# the fault worth reporting.
log "1. Source check"
if [ ! -d "$SOURCE" ]; then
  log "   source not present: ${SOURCE}"
  log "   the live wiki is produced by /root/scripts/wiki-build.sh"
  log "   (regen index -> mkdocs build -f ${WEB_CANON}/wiki-mkdocs.yml)"
  fail "wiki: build artifact absent — run wiki-build.sh, then re-run this check"
  exit 1
fi

# ── 2. Required entities check (Karpathy-style) ─────────────────────────────
log "2. Required entities check"
# 2026-10-25: reconciled with the ACTUAL source (/root/AAA/wiki) and the
# current producer output. The previous set (atlas / constitution /
# federation / llms.txt) described the retired 2026-08 arif-fazil-wiki
# layout; no build has emitted those paths since the source moved, so the
# gate could only ever fail. A validator that names entities nobody
# produces is a lying gate.
REQUIRED=(
  "index.html"
  "404.html"
  "sitemap.xml"
  "INDEX"
  "arifos"
  "axioms"
  "concepts"
  "entities"
  "scars"
  "skills"
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
  log "DRY RUN — validation passed. Set WIKI_SYNC_LIVE=1 to (re)promote."
  log "  producer owns the write: /root/scripts/wiki-build.sh -> ${LIVE}"
  exit 0
fi

# SOURCE == LIVE by construction (the producer builds straight into the
# served tree). A backup+rsync here would copy a directory onto itself and
# report SEALED for zero work. Say what is true: nothing to promote.
if [ "$SOURCE" = "$LIVE" ]; then
  log "4. Promote — SKIPPED (single writer)"
  log "   source and target are the same tree; wiki-build.sh is the only writer."
  log "   Validation above is the whole contract of this lane."
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
