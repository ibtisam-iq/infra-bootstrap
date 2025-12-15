#!/usr/bin/env bash
# ==================================================
# infra-bootstrap — Disable Swap (Kubernetes Requirement)
# ==================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Load common library ─────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || { echo "FATAL: Unable to load common library"; exit 1; }

info "Disabling swap (required by Kubernetes)..."

# Disable swap immediately
swapoff -a || warn "swapoff returned non-zero (swap may already be disabled)"

# Persist swap disable across reboots
if grep -qE '^\s*[^#].*\s+swap\s+' /etc/fstab; then
    sed -i '/\s\+swap\s\+/d' /etc/fstab
    ok "Swap entries removed from /etc/fstab"
else
    ok "No active swap entries found in /etc/fstab"
fi

ok "Swap disabled successfully"
blank