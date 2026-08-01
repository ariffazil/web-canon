#!/usr/bin/env bash
# ==============================================================================
# dynamic-gate.sh — Agentic web dynamic layer health gate
# F13 RATIFIED 2026-08-01 · Designed by 333-AGI (Δ MIND)
# ==============================================================================
# Purpose: One-shot liveness probe for all dynamic organ surfaces.
#          Compensates for static-sync gates by verifying the 5 organs,
#          arifFlow, and the A-FORGE actuator are all alive.
# Scope:   Parallel curl /health probes, FQ state from arifFlow, verdict.
# Mutations: None. Read-only.
# Reversibility: N/A — observation only.
# ==============================================================================
# Usage:
#   dynamic-gate.sh                              # full probe
#   DYNAMIC_GATE_VERBOSE=1 dynamic-gate.sh      # verbose retry info
# ==============================================================================

set -euo pipefail
umask 077

SCRIPT_NAME="dynamic-gate"
# shellcheck disable=SC1091
source "$(dirname "$0")/lib.sh"

load_secrets

banner "DYNAMIC GATE — $(date -u +%Y%m%dT%H%M%SZ)"

# ── Organ registry (canonical port map from /root/AGENTS.md §1.1) ──────────
declare -A ORGANS=(
  ["arifOS"]="8088"
  ["A-FORGE"]="7071"
  ["AAA"]="3001"
  ["GEOX"]="8081"
  ["WEALTH"]="18082"
  ["WELL"]="18083"
)
MCP_PORTS=(
  "7072"  # A-FORGE MCP
  "7073"  # arifFlow
)

HEALTHY=0
TOTAL=0
FAIL=0

# ── 1. Probe organs ─────────────────────────────────────────────────────────
log "1. Organ liveness probe"
for name in "${!ORGANS[@]}"; do
  port="${ORGANS[$name]}"
  TOTAL=$((TOTAL + 1))
  if probe_health "$name" "$port"; then
    HEALTHY=$((HEALTHY + 1))
  else
    FAIL=$((FAIL + 1))
  fi
done

# ── 2. Probe MCP doors ──────────────────────────────────────────────────────
log "2. MCP doors"
for port in "${MCP_PORTS[@]}"; do
  TOTAL=$((TOTAL + 1))
  if probe_health "MCP-${port}" "$port"; then
    HEALTHY=$((HEALTHY + 1))
  else
    FAIL=$((FAIL + 1))
  fi
done

# ── 3. arifFlow FQ ──────────────────────────────────────────────────────────
log "3. arifFlow FQ (Flow Quotient)"
FQ_BODY=$(curl -s --max-time 3 "$FLOW_URL/health" 2>/dev/null || echo "")
FQ=$(echo "$FQ_BODY" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('fq', d.get('flow_quotient', 'unknown')))" 2>/dev/null || echo "unknown")
FQ_STATE=$(echo "$FQ_BODY" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('state', 'unknown'))" 2>/dev/null || echo "unknown")
log "   FQ: ${FQ}  state: ${FQ_STATE}"

# ── 4. Verdict ──────────────────────────────────────────────────────────────
log "4. Verdict"
PASS_RATE=$(python3 -c "print(f'{${HEALTHY}/${TOTAL}*100:.1f}%')" 2>/dev/null || echo "n/a")
log "   healthy: ${HEALTHY}/${TOTAL} (${PASS_RATE})"

if [ "$FAIL" -eq 0 ]; then
  VERDICT="Pass"
  log "ALL GREEN — dynamic layer is alive"
else
  VERDICT="Hold"
  log "${FAIL} organ(s) unreachable — dynamic layer degraded"
fi

# ── 5. ariflow receipt ──────────────────────────────────────────────────────
log "5. Emit ariflow receipt"
emit_receipt "333-AGI/dynamic-gate" "dynamic layer gate" "federation" \
  "$TOTAL" "fq=${FQ};state=${FQ_STATE}" "$VERDICT"

# ── 6. Exit code ────────────────────────────────────────────────────────────
if [ "$FAIL" -eq 0 ]; then
  exit 0
else
  exit 1
fi
