#!/usr/bin/env bash
# ==================================================
# infra-bootstrap — Containerd Runtime Installation
#
# Entry point script (curl | bash compatible)
#
# This script dispatches containerd installation
# based on a pre-selected method.
#
# Expected environment variable:
#   CONTAINERD_INSTALL_METHOD=package|binary
# ==================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Load common library ─────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common library"
  exit 1
}

# ───────────────────────── Validation ─────────────────────────
: "${CONTAINERD_INSTALL_METHOD:?CONTAINERD_INSTALL_METHOD is not set}"

BASE_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/kubernetes/runtime"

info "Container runtime installation started"
info "Selected method: $CONTAINERD_INSTALL_METHOD"
blank

# ───────────────────────── Dispatcher ─────────────────────────
case "$CONTAINERD_INSTALL_METHOD" in
  package)
    info "Using package-managed containerd installation"
    blank

    bash <(curl -fsSL "$BASE_URL/install-containerd-package.sh")
    bash <(curl -fsSL "$BASE_URL/config-containerd-package.sh")
    ;;
  
  binary)
    info "Using binary-managed containerd installation"
    blank

    bash <(curl -fsSL "$BASE_URL/install-runc.sh")
    bash <(curl -fsSL "$BASE_URL/install-containerd-binary.sh")
    bash <(curl -fsSL "$BASE_URL/config-containerd-binary.sh")
    ;;
  
  *)
    error "Invalid CONTAINERD_INSTALL_METHOD: $CONTAINERD_INSTALL_METHOD"
    ;;
esac

# ───────────────────────── Enable Service ─────────────────────────
info "Enabling containerd service"
systemctl enable containerd --now

# ───────────────────────── Final Validation ─────────────────────────
if systemctl is-active --quiet containerd; then
  ok "containerd service is running"
else
  error "containerd service is not running"
fi

CONTAINERD_VERSION="$(containerd --version 2>/dev/null | awk '{print $3}' | sed 's/^v//')"
RUNC_VERSION="$(runc --version 2>/dev/null | awk 'NR==1{print $3}')"

info "containerd version: ${CONTAINERD_VERSION:-unknown}"
info "runc version: ${RUNC_VERSION:-unknown}"
blank

ok "Containerd runtime installation completed successfully"