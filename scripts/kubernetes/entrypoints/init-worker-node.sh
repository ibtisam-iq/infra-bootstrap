#!/usr/bin/env bash
# ============================================================================
# infra-bootstrap — Initialize Kubernetes Worker Node
#
# ENTRYPOINT SCRIPT (curl | bash compatible)
#
# Responsibilities:
#   • Orchestrate worker-node bootstrap in strict order
#   • No user interaction
#   • No local file assumptions
#   • Fail fast on any error
#
# Expected inputs (exported earlier):
#   CONTROL_PLANE_IP
#   K8S_VERSION
#   NODE_NAME
#   POD_CIDR
#   CONTAINERD_INSTALL_METHOD
# ============================================================================

set -Eeuo pipefail
IFS=$'\n\t'
BASE_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/kubernetes"

# ───────────────────────── Load common library ─────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common library"
  exit 1
}

require_root

banner "Kubernetes — Initialize Worker Node"

# ───────────────────────── Preflight (silent) ────────────────────────────────
info "Running system preflight..."
if bash <(curl -fsSL $PREFLIGHT_URL) >/dev/null 2>&1; then
    ok "Preflight passed."
else
    error "Preflight failed — node not suitable."
fi
blank

# ───────────────────────── Phase 1: Cluster Parameters ──────────────────────

info "Phase 1 — Importing cluster paramesters"
blank

source <(curl -fsSL "$K8S_BASE_URL/cluster/cluster-params.sh") || {
  error "Failed to load cluster parameters"
}
blank

info "Worker node initialization started"
info "Node name: $NODE_NAME"
info "Kubernetes version: $K8S_VERSION"
info "Control plane IP: $CONTROL_PLANE_IP"
info "Containerd method: $CONTAINERD_INSTALL_METHOD"
blank

# ───────────────────────── Phase 2: Node Preparation ────────────────────────
info "Phase 2 — Node preparation"

bash <(curl -fsSL "$K8S_BASE_URL/node/disable-swap.sh")
bash <(curl -fsSL "$K8S_BASE_URL/node/load-kernel-modules.sh")
bash <(curl -fsSL "$K8S_BASE_URL/node/apply-sysctl.sh")
blank

# ───────────────────────── Phase 3: Container Runtime Prerequisites ─────────
info "Phase 3 — Container runtime prerequisites"

bash <(curl -fsSL "$K8S_RUNTIME_URL/install-cni-binaries.sh")
bash <(curl -fsSL "$K8S_RUNTIME_URL/install-crictl.sh")
blank

# ───────────────────────── Phase 4: Container Runtime ───────────────────────
info "Phase 4 — Container runtime installation"

bash <(curl -fsSL "$K8S_RUNTIME_URL/install-containerd.sh")
bash <(curl -fsSL "$K8S_RUNTIME_URL/config-crictl.sh")
blank

# ───────────────────────── Load version resolver ─────────────────────────
info "Resolving Kubernetes versions (environment context)"

source <(curl -fsSL "$VERSION_RESOLVER_URL") || {
  error "Failed to load Kubernetes version resolver"
}

info "Kubernetes version context resolved"
blank

# ───────────────────────── Phase 5: Kubernetes Components ───────────────────
info "Phase 5 — Kubernetes node components"

bash <(curl -fsSL "$K8S_PACKAGES_URL/install-kubeadm-kubelet.sh")
blank

# ───────────────────────── Final State ──────────────────────────────────────
ok "Worker node initialization completed successfully"
blank