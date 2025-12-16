#!/usr/bin/env bash
# ==================================================
# infra-bootstrap — Apply sysctl Parameters for Kubernetes
# ==================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Load common library ─────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || { echo "FATAL: Unable to load common library"; exit 1; }

info "Applying sysctl parameters required by Kubernetes..."

cat <<EOF | tee /etc/sysctl.d/k8s.conf > /dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl -p /etc/sysctl.d/k8s.conf > /dev/null || error "Failed to apply sysctl parameters"

ok "sysctl parameters applied successfully"
blank
