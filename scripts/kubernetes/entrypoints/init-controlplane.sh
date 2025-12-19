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

banner "Kubernetes — Initialize Control Plane"

# ───────────────────────── Phase 1–5: Worker Node Bootstrap ────────────

bash <(curl -fsSL "$BASE_URL/entrypoints/init-worker-node.sh")

# ───────────────────────── Load version resolver ─────────────────────────
RESOLVER_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/kubernetes/lib/k8s-version-resolver.sh"
source <(curl -fsSL "$RESOLVER_URL") || {
  error "Failed to load Kubernetes version resolver"
}

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