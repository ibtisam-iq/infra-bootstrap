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

# Ensure modprobe is available
if ! command -v modprobe >/dev/null 2>&1; then
    info "Installing kmod (required for modprobe)..."
    apt-get update -qq >/dev/null
    apt-get install -yq apt-utils >/dev/null
    apt-get install -yq kmod >/dev/null
fi

# Load modules immediately
modprobe overlay
modprobe br_netfilter

ok "Kernel modules loaded: overlay, br_netfilter"
blank
