#!/usr/bin/env bash
# ============================================================================
# infra-bootstrap — Initialize Kubernetes Control Plane
#
# ENTRYPOINT SCRIPT (curl | bash compatible)
#
# Responsibilities:
#   • Bootstrap node as Kubernetes worker (base layers)
#   • Install control-plane CLI tooling
#   • Ensure required Kubernetes services are active
#   • Perform cluster cleanup (explicit, pre-bootstrap)
#   • Initialize Kubernetes control plane (kubeadm init)
#   • Configure kubeconfig for administrative access
#
# Design principles:
#   • Strict phase ordering
#   • No local filesystem assumptions
#   • No user interaction
#   • Fail fast on any error
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

banner "Kubernetes — Initialize Control Plane"

# ───────────────────────── Phase 1: Cluster Parameters ──────────────────────

info "Phase 1 — Importing cluster parameters"
source <(curl -fsSL "$BASE_URL/cluster/cluster-params.sh") || {
  error "Failed to load cluster parameters"
}
blank

info "Control plane initialization started"
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

# ───────────────────────── Load version resolver ─────────────────────────
info "Resolving Kubernetes versions (environment context)"

source <(curl -fsSL "$BASE_URL/lib/k8s-version-resolver.sh") || {
  error "Failed to load Kubernetes version resolver"
}

info "Kubernetes version context resolved"
blank

# ───────────────────────── Phase 5: Kubernetes Components ───────────────────
info "Phase 5 — Kubernetes node components"

bash <(curl -fsSL "$BASE_URL/packages/install-kubeadm-kubelet.sh")
blank

# ───────────────────────── Phase 6: Control Plane CLI Tooling ───────────
info "Phase 6 — Installing control-plane CLI tools"

bash <(curl -fsSL "$BASE_URL/packages/install-controlplane-cli.sh")
ll
ok "Control-plane CLI tools installed"
blank

# ───────────────────────── Phase 7: Ensure Kubernetes Services ──────────
info "Phase 7 — Ensuring Kubernetes services are active"

bash <(curl -fsSL "$BASE_URL/cluster/ensure-k8s-services.sh")

ok "Kubernetes services verified"
blank

# ───────────────────────── Phase 8: Pre-bootstrap Cleanup ───────────────
info "Phase 8 — Pre-bootstrap cluster cleanup (guarded)"

# bash <(curl -fsSL "$BASE_URL/maintenance/cleanup-cluster.sh")

ok "Cluster cleanup completed (if required)"
blank

# ───────────────────────── Phase 9: Bootstrap Control Plane ─────────────
info "Phase 9 — Bootstrapping Kubernetes control plane"

bash <(curl -fsSL "$BASE_URL/cluster/bootstrap-controlplane.sh") 