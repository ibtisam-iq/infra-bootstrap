#!/usr/bin/env bash
# ==================================================
# infra-bootstrap — Load Kernel Modules for Kubernetes
# ==================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Load common library ─────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || { echo "FATAL: Unable to load common library"; exit 1; }

info "Loading required kernel modules..."

# Persist module loading
cat <<EOF | tee /etc/modules-load.d/k8s.conf > /dev/null
overlay
br_netfilter
EOF

# Load modules immediately
modprobe overlay
modprobe br_netfilter

ok "Kernel modules loaded: overlay, br_netfilter"
blank
