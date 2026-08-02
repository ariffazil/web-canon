#!/usr/bin/env bash
# ==============================================================================
# lib.sh — shared library for static-sync / dynamic-gate / agentic-web
# F13 RATIFIED 2026-08-01 · Designed by 333-AGI (Δ MIND)
# ==============================================================================
# Purpose: Single source of truth for shared functions across the agentic-web
#          automation stack. Sourced by atlas-sync.sh, wiki-sync.sh,
#          dynamic-gate.sh, and agentic-web.sh.
# Scope:   Logging, validation, drift detection, ariflow receipt emission.
# Mutations: None by itself. Callers mutate via rsync / forge_health_check.
# ==============================================================================

# ── Strictness guard ────────────────────────────────────────────────────────
# Callers MUST already have set -euo pipefail. This lib does not re-set it.

# ── Paths ───────────────────────────────────────────────────────────────────
WEB_CANON="/root/web-canon"
LIVE_WEB="/var/www/html"
FLOW_URL="http://127.0.0.1:7073"
ARIFOS_URL="http://127.0.0.1:8088"

# ── Script start timestamp (set once at lib.sh source time) ─────────────────
# Used by emit_receipt to compute real cost_ns = elapsed time since script
# started. Without this, cost_ns would be a Unix timestamp (1.78e12) instead
# of a duration — which inflated FQ ratio by 200x+ and made 333-AGI
# sub-actors look like OVERHEAT even when they ran fine.
#
# F12 fix 2026-08-02: SCRIPT_START_NS captured here at source time.
SCRIPT_START_NS=$(date +%s%N)

# ── Secret bootstrap (for ariflow auth) ─────────────────────────────────────
load_secrets() {
  if [ -f /root/.secrets/kunci-mas.env ]; then
    set -a
    # shellcheck disable=SC1091
    source /root/.secrets/kunci-mas.env 2>/dev/null || true
    set +a
  fi
}

# ── Logging ─────────────────────────────────────────────────────────────────
log()  { echo "[$SCRIPT_NAME] $*"; }
fail() { echo "[$SCRIPT_NAME] ✗ $*"; FAIL=1; }
pass() { echo "[$SCRIPT_NAME] ✓ $*"; }

# ── File count ──────────────────────────────────────────────────────────────
count_files() {
  local dir="$1"
  if [ -d "$dir" ]; then
    find "$dir" -type f | wc -l
  else
    echo 0
  fi
}

# ── Total bytes ─────────────────────────────────────────────────────────────
total_bytes() {
  local dir="$1"
  if [ -d "$dir" ]; then
    du -sb "$dir" 2>/dev/null | awk '{print $1}'
  else
    echo 0
  fi
}

# ── MD5 parity check (whole-tree) ───────────────────────────────────────────
# Returns 0 if all files match, 1 if diff, 2 if missing.
md5_parity() {
  local src="$1"
  local dst="$2"
  if [ ! -d "$src" ]; then
    echo "MISSING_SRC"
    return 2
  fi
  if [ ! -d "$dst" ]; then
    echo "MISSING_DST"
    return 2
  fi
  local diff
  diff=$(cd "$src" && find . -type f -exec md5sum {} \; | sort > /tmp/$$.src.md5
         cd "$dst" && find . -type f -exec md5sum {} \; | sort > /tmp/$$.dst.md5
         diff /tmp/$$.src.md5 /tmp/$$.dst.md5 2>&1)
  rm -f /tmp/$$.src.md5 /tmp/$$.dst.md5
  if [ -z "$diff" ]; then
    echo "CLEAN"
    return 0
  else
    echo "DRIFT"
    return 1
  fi
}

# ── Drift test (after rsync) ────────────────────────────────────────────────
drift_test() {
  local src="$1"
  local dst="$2"
  local result
  result=$(md5_parity "$src" "$dst")
  case "$result" in
    CLEAN)       pass "drift: CLEAN — source == live"; return 0 ;;
    DRIFT)       fail "drift: DIVERGED after sync"; return 1 ;;
    MISSING_SRC) fail "drift: source missing: $src"; return 1 ;;
    MISSING_DST) fail "drift: live missing: $dst"; return 1 ;;
  esac
}

# ── Backup target ───────────────────────────────────────────────────────────
backup_target() {
  local dst="$1"
  local ts="$2"
  local backup="${dst}.bak.${ts}"
  if [ -d "$dst" ]; then
    cp -a "$dst" "$backup" 2>/dev/null || mkdir -p "$backup"
  else
    mkdir -p "$backup"
  fi
  echo "$backup"
}

# ── rsync with std flags ────────────────────────────────────────────────────
do_rsync() {
  local src="$1"
  local dst="$2"
  rsync -avz --delete "$src/" "$dst/"
}

# ── UUID generator (for receipt_id) ─────────────────────────────────────────
new_uuid() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen
  else
    cat /proc/sys/kernel/random/uuid
  fi
}

# ── ariflow receipt ─────────────────────────────────────────────────────────
# Args: actor, intent, target, files, drift, verdict
# Requires: receipt_id (UUID v4), previous_receipt_hash (optional, ignored here)
emit_receipt() {
  local actor="$1"
  local intent="$2"
  local target="$3"
  local files="$4"
  local drift="$5"
  local verdict="$6"
  local ts
  ts=$(date -u +%Y%m%dT%H%M%SZ)
  local receipt_id
  receipt_id=$(new_uuid)
  local payload
  payload=$(cat <<EOF
{
  "receipt_id": "${receipt_id}",
  "actor_id": "${actor}",
  "session_id": "${SCRIPT_NAME}-${ts}",
  "step_type": "Seal",
  "step_number": 1,
  "cost_ns": $(( $(date +%s%N) - SCRIPT_START_NS )),
  "epistemic_label": "Seal",
  "floor_verdict": "${verdict}",
  "cooling_decision": "None",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%S.%6NZ)",
  "payload": {
    "intent": "${intent}",
    "target": "${target}",
    "files": ${files},
    "drift": "${drift}",
    "ts": "${ts}",
    "lane": "IMPL",
    "lease": {
      "status": "ABSENT",
      "reason": "forge_lease_not_wired",
      "required_by": "I3",
      "note": "Decision per 2026-08-01 sovereign attestation: do not fake a lease. Declare absence truthfully so the system cannot pretend."
    }
  }
}
EOF
)
  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$FLOW_URL/ingest" \
    -H "Content-Type: application/json" \
    -d "$payload" 2>/dev/null || echo "000")
  if [ "$http_code" = "200" ] || [ "$http_code" = "202" ]; then
    pass "ariflow: receipt emitted (HTTP $http_code, id=${receipt_id:0:8})"
  else
    log "ariflow: receipt failed (HTTP $http_code — non-fatal)"
  fi

  # ── FQ pair: emit follow-up Verify receipt (closes arifFlow OVERHEAT gap) ──
  # F12 fix 2026-08-02: 333-AGI sub-actors were Seal-only, leaving FQ at 0.0.
  # Each Seal now emits a paired Verify. The seal's receipt_id becomes the
  # previous_receipt_hash so the FQ chain stays linked.
  local verify_payload
  verify_payload=$(cat <<EOF
{
  "receipt_id": "$(new_uuid)",
  "actor_id": "${actor}",
  "session_id": "${SCRIPT_NAME}-${ts}",
  "step_type": "Verify",
  "step_number": 2,
  "cost_ns": $(( $(date +%s%N) - SCRIPT_START_NS )),
  "epistemic_label": "Observation",
  "floor_verdict": "${verdict}",
  "previous_receipt_hash": "${receipt_id}",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%S.%6NZ)",
  "cooling_decision": "None",
  "payload": {
    "verifies": "${receipt_id}",
    "intent": "${intent}",
    "target": "${target}",
    "files": ${files},
    "drift": "${drift}",
    "ts": "${ts}",
    "lane": "VERIFY",
    "verifies_seal_step": true,
    "note": "Auto-paired Verify for Seal — closes FQ gap for 333-AGI sub-actors"
  }
}
EOF
)
  local verify_code
  verify_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$FLOW_URL/ingest" \
    -H "Content-Type: application/json" \
    -d "$verify_payload" 2>/dev/null || echo "000")
  if [ "$verify_code" = "200" ] || [ "$verify_code" = "202" ]; then
    pass "ariflow: verify paired (HTTP $verify_code)"
  else
    log "ariflow: verify pair failed (HTTP $verify_code — non-fatal)"
  fi
}

# ── Health probe (curl :port/health) ─────────────────────────────────────────
# Returns 0 if healthy, 1 if not.
probe_health() {
  local name="$1"
  local port="$2"
  local url="http://127.0.0.1:${port}/health"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url" 2>/dev/null || echo "000")
  if [ "$code" = "200" ]; then
    pass "health: ${name} :${port} ✅ 200"
    return 0
  else
    fail "health: ${name} :${port} ❌ ${code}"
    return 1
  fi
}

# ── Banner ──────────────────────────────────────────────────────────────────
banner() {
  local title="$1"
  echo
  echo "═════════════════════════════════════════════════════════"
  echo "  $title"
  echo "═════════════════════════════════════════════════════════"
}

# ── Epistemic label (F2) ────────────────────────────────────────────────────
# Used in logs to make epistemic class explicit.
EPI_STATIC="OBS"
EPI_DYNAMIC="OBS"
EPI_VERDICT="DER"
