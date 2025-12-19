#!/usr/bin/env bash
# ============================================================================
# infra-bootstrap — Kubernetes kubeconfig Setup
# Configures ~/.kube/config for kubectl access
# ============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Source common library ─────────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common.sh"
  exit 1
}

info "Phase 10 — Configuring kubeconfig for administrator access"

# ───────────────────────── Determine execution user ──────────────────────────
REAL_USER=""
REAL_HOME=""

if [[ "${EUID}" -eq 0 ]]; then
  # Running as root (sudo bash)
  if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    warn "Script is running with sudo."
    warn "kubeconfig should belong to user: ${SUDO_USER}"
    echo
    read -rp "Proceed configuring kubeconfig for '${SUDO_USER}'? (yes/no): " CONFIRM < /dev/tty
    echo
    if [[ "${CONFIRM,,}" != "yes" ]]; then
      warn "User declined. Exiting without changes."
      exit 0
    fi
    REAL_USER="${SUDO_USER}"
    REAL_HOME="$(eval echo "~${SUDO_USER}")"
  else
    error "Running as root without a real user context is unsafe."
  fi
else
  # Normal user execution (recommended)
  REAL_USER="$(whoami)"
  REAL_HOME="$HOME"
  ok "Running as user: ${REAL_USER}"
fi

# ───────────────────────── Preconditions ─────────────────────────────────────
if [[ ! -f /etc/kubernetes/admin.conf ]]; then
  error "/etc/kubernetes/admin.conf not found. Control plane may not be initialized."
fi

# ───────────────────────── Setup kubeconfig ───────────────────────────────────
info "Configuring kubeconfig for user: ${REAL_USER}"

KUBE_DIR="${REAL_HOME}/.kube"
KUBE_CONFIG="${KUBE_DIR}/config"

sudo mkdir -p "${KUBE_DIR}"
sudo cp -f /etc/kubernetes/admin.conf "${KUBE_CONFIG}"
sudo chown -R "${REAL_USER}:${REAL_USER}" "${KUBE_DIR}"
chmod 700 "${KUBE_CONFIG}"

ok "kubeconfig copied to ${KUBE_CONFIG}"
blank

# ───────────────────────── Verify cluster access ──────────────────────────────
info "Verifying kubectl access (this may take up to 60 seconds)..."
export KUBECONFIG="${KUBE_CONFIG}"

sleep 10
if kubectl cluster-info >/dev/null 2>&1; then
  ok "kubectl access verified successfully"
else
  warn "kubectl could not reach the cluster yet"
  warn "The control plane may still be initializing"
fi

# ───────────────────────── CNI Detection & Guidance ─────────────────────────
blank

CNI_CONFIG_COUNT=$(sudo sh -c 'ls -1 /etc/cni/net.d/*.conf /etc/cni/net.d/*.conflist 2>/dev/null | wc -l')

if [[ "$CNI_CONFIG_COUNT" -eq 0 ]]; then
  warn "No CNI plugin configuration detected."
  info "Kubernetes requires a CNI plugin before pods can be scheduled."

  blank
  info "To install a CNI using infra-bootstrap, run:"
  hr
  info "curl -fsSL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/kubernetes/cni/install-cni | sudo bash"
  hr
else
  ok "CNI plugin configuration detected ($CNI_CONFIG_COUNT config file(s) found)."
fi

blank
ok "kubeconfig setup completed successfully"
exit 0
