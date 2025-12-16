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

# ───────────────────────── Preflight (silent) ────────────────────────────────
info "Running system preflight..."
if bash <(curl -fsSL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/system-checks/preflight.sh) \
    >/dev/null 2>&1; then
    ok "Preflight passed."
else
    error "Preflight failed — node not suitable."
fi
blank

banner "Kubernetes — Initialize Worker Node"

# ───────────────────────── Phase 1: Cluster Parameters ──────────────────────

info "Phase 1 — Cluster parameters"
source <(curl -fsSL "$BASE_URL/cluster/cluster-params.sh")
blank

info "Worker node initialization started"
info "Node name: $NODE_NAME"
info "Kubernetes version: $K8S_VERSION"
info "Control plane IP: $CONTROL_PLANE_IP"
info "Containerd method: $CONTAINERD_INSTALL_METHOD"
blank

# ───────────────────────── Phase 2: Node Preparation ────────────────────────
info "Phase 2 — Node preparation"

bash <(curl -fsSL "$BASE_URL/node/disable-swap.sh")
bash <(curl -fsSL "$BASE_URL/node/load-kernel-modules.sh")
bash <(curl -fsSL "$BASE_URL/node/apply-sysctl.sh")
blank

# ───────────────────────── Phase 3: Container Runtime Prerequisites ─────────
info "Phase 3 — Container runtime prerequisites"

bash <(curl -fsSL "$BASE_URL/runtime/install-cni-binaries.sh")
bash <(curl -fsSL "$BASE_URL/runtime/install-crictl.sh")
blank

# ───────────────────────── Phase 4: Container Runtime ───────────────────────
info "Phase 4 — Container runtime installation"

bash <(curl -fsSL "$BASE_URL/runtime/install-containerd.sh")
bash <(curl -fsSL "$BASE_URL/runtime/config-crictl.sh")
blank

# ───────────────────────── Phase 5: Kubernetes Components ───────────────────
info "Phase 5 — Kubernetes node components"

bash <(curl -fsSL "$BASE_URL/packages/install-kubeadm-kubelet.sh")
blank

# ───────────────────────── Final State ──────────────────────────────────────
ok "Worker node initialization completed successfully"
blank