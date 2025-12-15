#!/usr/bin/env bash
# ==================================================
# infra-bootstrap — Configure crictl
#
# Purpose:
#   - Explicitly configure CRI runtime endpoints
#   - Ensure crictl works reliably with containerd
# ==================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Load common library ─────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common library"
  exit 1
}

# ───────────────────────── Configuration ─────────────────────────
CRICTL_CONFIG="/etc/crictl.yaml"
RUNTIME_ENDPOINT="unix:///run/containerd/containerd.sock"
IMAGE_ENDPOINT="unix:///run/containerd/containerd.sock"

# ───────────────────────── Preflight ─────────────────────────
info "Configuring crictl"

command -v crictl >/dev/null 2>&1 || error "crictl is not installed"
[[ -S /run/containerd/containerd.sock ]] || error "containerd socket not found"

# ───────────────────────── Write Config ─────────────────────────
info "Writing crictl configuration to ${CRICTL_CONFIG}"

cat >"$CRICTL_CONFIG" <<EOF
runtime-endpoint: ${RUNTIME_ENDPOINT}
image-endpoint: ${IMAGE_ENDPOINT}
timeout: 10
debug: false
pull-image-on-create: false
EOF

# ───────────────────────── Validation ─────────────────────────
info "Validating crictl configuration"

crictl info >/dev/null \
  || error "crictl failed to communicate with containerd"

ok "crictl configured successfully"
blank