#!/bin/sh

set -eu

fail=0

check_ok() {
  printf 'OK   %s\n' "$1"
}

check_warn() {
  printf 'WARN %s\n' "$1"
}

check_fail() {
  printf 'FAIL %s\n' "$1"
  fail=1
}

if command -v mpirun >/dev/null 2>&1 || command -v mpiexec >/dev/null 2>&1; then
  check_ok "MPI runtime found"
else
  check_fail "MPI runtime not found; SBCC rules require teams to run MPI"
fi

if [ -n "${SBCC_SOCKET_COUNT:-}" ]; then
  if [ "${SBCC_SOCKET_COUNT}" -ge 4 ] 2>/dev/null; then
    check_ok "socket count declared as ${SBCC_SOCKET_COUNT}"
  else
    check_fail "socket count declared as ${SBCC_SOCKET_COUNT}; SBCC minimum is 4"
  fi
else
  check_warn "SBCC_SOCKET_COUNT not set; cannot verify 4-socket minimum"
fi

if [ -n "${SBCC_SOCKET_TYPE:-}" ]; then
  check_ok "socket type declared as ${SBCC_SOCKET_TYPE}"
else
  check_warn "SBCC_SOCKET_TYPE not set; cannot verify same-socket-type requirement"
fi

if [ -n "${SBCC_CLUSTER_WATTS:-}" ]; then
  if [ "${SBCC_CLUSTER_WATTS}" -le 250 ] 2>/dev/null; then
    check_ok "cluster power declared as ${SBCC_CLUSTER_WATTS} W"
  else
    check_fail "cluster power declared as ${SBCC_CLUSTER_WATTS} W; SBCC limit is 250 W"
  fi
else
  check_warn "SBCC_CLUSTER_WATTS not set; cannot verify 250 W limit"
fi

if [ -n "${SBCC_CLUSTER_MSRP_USD:-}" ]; then
  if [ "${SBCC_CLUSTER_MSRP_USD}" -le 6000 ] 2>/dev/null; then
    check_ok "cluster MSRP declared as \$${SBCC_CLUSTER_MSRP_USD}"
  else
    check_fail "cluster MSRP declared as \$${SBCC_CLUSTER_MSRP_USD}; SBCC limit is \$6000"
  fi
else
  check_warn "SBCC_CLUSTER_MSRP_USD not set; cannot verify \$6000 MSRP limit"
fi

if [ -r /proc/device-tree/model ]; then
  model="$(tr -d '\000' </proc/device-tree/model)"
  case "$model" in
    *Apple*|*M1*|*M2*|*M3*|*M4*|*M5*)
      check_fail "local hardware looks like Apple silicon: ${model}"
      ;;
    *)
      check_ok "local hardware is not Apple M1-M5: ${model}"
      ;;
  esac
else
  check_warn "cannot read /proc/device-tree/model; Apple hardware exclusion not checked locally"
fi

check_warn "competition-hour and physical-access rules are operational constraints; this script cannot enforce them"
check_warn "D-LLAMA in this repo uses socket transport; SBCC-level MPI compliance must be satisfied by the full cluster workflow"

if [ "$fail" -ne 0 ]; then
  exit 1
fi
