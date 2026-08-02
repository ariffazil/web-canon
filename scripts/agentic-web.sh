#!/usr/bin/env bash
# ==============================================================================
# agentic-web.sh — Single-entry orchestrator for the agentic web automation
# F13 RATIFIED 2026-08-01 · Designed by 333-AGI (Δ MIND)
# ==============================================================================
# Purpose: Run static + dynamic phases in sequence and emit a unified verdict.
#          Replaces ad-hoc manual invocation of canon-sync.sh with a single
#          cron entry. Idempotent. Reversible.
# Scope:   Static sync (canon + atlas + wiki) + dynamic health gate.
# Mutations: rsync --delete (T2) on static surfaces; read-only on dynamic.
# Reversibility: git revert on source repos; rsync from backup on live.
# ==============================================================================
# Usage:
#   agentic-web.sh                  # dry-run (all static sync + dynamic gate)
#   AGENTIC_WEB_LIVE=1 agentic-web.sh    # live sync + dynamic gate
#   AGENTIC_WEB_STATIC_ONLY=1 ...        # skip dynamic phase
#   AGENTIC_WEB_DYNAMIC_ONLY=1 ...       # skip static phase
# ==============================================================================

set -euo pipefail
umask 077

SCRIPT_NAME="agentic-web"
# shellcheck disable=SC1091
source "$(dirname "$0")/lib.sh"

load_secrets

LIVE="${AGENTIC_WEB_LIVE:-0}"
STATIC_ONLY="${AGENTIC_WEB_STATIC_ONLY:-0}"
DYNAMIC_ONLY="${AGENTIC_WEB_DYNAMIC_ONLY:-0}"
TS=$(date -u +%Y%m%dT%H%M%SZ)

banner "AGENTIC WEB — $TS"

# ── Phase 0: announce ───────────────────────────────────────────────────────
log "live=${LIVE}  static_only=${STATIC_ONLY}  dynamic_only=${DYNAMIC_ONLY}"

STATIC_RC=0
DYNAMIC_RC=0

# ── Phase 1: STATIC ─────────────────────────────────────────────────────────
if [ "$DYNAMIC_ONLY" != "1" ]; then
  banner "PHASE 1 — STATIC"

  # 1a. canon-sync (JSON/YAML validation)
  log "1a. canon-sync (JSON/YAML canon)"
  if [ "$LIVE" = "1" ]; then
    CANON_SYNC_LIVE=1 bash "${SCRIPT_DIR:-$(dirname "$0")}/canon-sync.sh" || STATIC_RC=$?
  else
    bash "${SCRIPT_DIR:-$(dirname "$0")}/canon-sync.sh" || STATIC_RC=$?
  fi

  # 1b. atlas-sync (markdown docs)
  log "1b. atlas-sync (markdown docs)"
  if [ "$LIVE" = "1" ]; then
    ATLAS_SYNC_LIVE=1 bash "${SCRIPT_DIR:-$(dirname "$0")}/atlas-sync.sh" || STATIC_RC=$?
  else
    bash "${SCRIPT_DIR:-$(dirname "$0")}/atlas-sync.sh" || STATIC_RC=$?
  fi

  # 1c. wiki-sync (wiki mirror)
  log "1c. wiki-sync (wiki mirror)"
  if [ "$LIVE" = "1" ]; then
    WIKI_SYNC_LIVE=1 bash "${SCRIPT_DIR:-$(dirname "$0")}/wiki-sync.sh" || STATIC_RC=$?
  else
    bash "${SCRIPT_DIR:-$(dirname "$0")}/wiki-sync.sh" || STATIC_RC=$?
  fi

  log "STATIC phase: rc=${STATIC_RC}"
fi

# ── Phase 2: DYNAMIC ────────────────────────────────────────────────────────
if [ "$STATIC_ONLY" != "1" ]; then
  banner "PHASE 2 — DYNAMIC"

  bash "${SCRIPT_DIR:-$(dirname "$0")}/dynamic-gate.sh" || DYNAMIC_RC=$?

  log "DYNAMIC phase: rc=${DYNAMIC_RC}"
fi

# ── Phase 3: UNIFIED VERDICT ────────────────────────────────────────────────
banner "PHASE 3 — VERDICT"

if [ "$STATIC_RC" -eq 0 ] && [ "$DYNAMIC_RC" -eq 0 ]; then
  VERDICT="Pass"
  log "✅ AGENTIC WEB — clean"
  log "   static:  PASS"
  log "   dynamic: PASS"
  emit_receipt "333-AGI/agentic-web" "agentic-web full cycle" "federation" \
    "0" "clean" "Pass"
  # FQ cooling: emit Verify step
  curl -sf -X POST http://127.0.0.1:7073/ingest \
    -H "Content-Type: application/json" \
    -d "{\"actor_id\":\"333-AGI/agentic-web\",\"session_id\":\"agentic-web-$(date -u +%Y%m%dT%H%M%SZ)\",\"step_type\":\"Verify\",\"step_number\":2,\"cost_ns\":$(date +%s%N | head -c 13),\"epistemic_label\":\"Observation\",\"floor_verdict\":\"Pass\",\"payload\":{\"verdict\":\"Pass\"}}" > /dev/null 2>&1 || true
  exit 0
else
  VERDICT="Hold"
  log "⚠️  AGENTIC WEB — degraded"
  log "   static:  rc=${STATIC_RC}"
  log "   dynamic: rc=${DYNAMIC_RC}"
  emit_receipt "333-AGI/agentic-web" "agentic-web full cycle" "federation" \
    "0" "static=${STATIC_RC};dynamic=${DYNAMIC_RC}" "Hold"
  # FQ cooling: emit Verify step even on degraded
  curl -sf -X POST http://127.0.0.1:7073/ingest \
    -H "Content-Type: application/json" \
    -d "{\"actor_id\":\"333-AGI/agentic-web\",\"session_id\":\"agentic-web-$(date -u +%Y%m%dT%H%M%SZ)\",\"step_type\":\"Verify\",\"step_number\":2,\"cost_ns\":$(date +%s%N | head -c 13),\"epistemic_label\":\"Observation\",\"floor_verdict\":\"Hold\",\"payload\":{\"verdict\":\"Hold\",\"static_rc\":\"${STATIC_RC}\",\"dynamic_rc\":\"${DYNAMIC_RC}\"}}" > /dev/null 2>&1 || true
  exit 1
fi
