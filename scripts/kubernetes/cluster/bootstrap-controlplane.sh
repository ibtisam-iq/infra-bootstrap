#!/usr/bin/env bash
# ============================================================================
# infra-bootstrap — Kubernetes Control Plane Bootstrap (kubeadm)
# ----------------------------------------------------------------------------
# Initializes a Kubernetes control plane node using kubeadm.
#
# This script:
#  - Resolves exact Kubernetes patch version via official API
#  - Runs kubeadm init with pinned version
#  - DOES NOT configure kubeconfig automatically
#  - DOES NOT install CNI automatically
#  - Respects kubeadm’s own output and instructions
#
# Clear post-init guidance is printed after completion.
# ============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Load common library ─────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common library"
  exit 1
}

require_root

# ───────────────────────── Load version resolver ─────────────────────────
RESOLVER_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/kubernetes/lib/k8s-version-resolver.sh"
source <(curl -fsSL "$RESOLVER_URL") || {
  error "Failed to load Kubernetes version resolver"
}

# Resolver exports:
#   K8S_MAJOR_MINOR
#   K8S_PATCH_VERSION
#   K8S_IMAGE_TAG

# ───────────────────────── Load cluster parameters ─────────────────────────
info "Loading cluster parameters..."
eval "$(curl -fsSL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/kubernetes/cluster-params.sh)"

: "${CONTROL_PLANE_IP:?Missing CONTROL_PLANE_IP}"
: "${NODE_NAME:?Missing NODE_NAME}"
: "${POD_CIDR:?Missing POD_CIDR}"
: "${K8S_PATCH_VERSION:?Missing K8S_PATCH_VERSION}"
: "${K8S_IMAGE_TAG:?Missing K8S_IMAGE_TAG}"

ok "Cluster parameters loaded"
blank

item "Control Plane IP"     "$CONTROL_PLANE_IP"
item "Node Name"            "$NODE_NAME"
item "Pod CIDR"             "$POD_CIDR"
item "Kubernetes Version"   "$K8S_PATCH_VERSION"
blank

# ───────────────────────── kubeadm init ─────────────────────────
section "Initializing Kubernetes control plane"

info "Using Kubernetes version: ${K8S_IMAGE_TAG}"
info "Pre-pulling Kubernetes control plane images"

kubeadm config images pull \
  --kubernetes-version "${K8S_IMAGE_TAG}" \
  --cri-socket unix:///var/run/containerd/containerd.sock

ok "Control plane images pulled successfully"
blank

info "Running kubeadm init (this may take a few minutes)..."
blank

kubeadm init \
  --control-plane-endpoint "${CONTROL_PLANE_IP}:6443" \
  --upload-certs \
  --pod-network-cidr "${POD_CIDR}" \
  --apiserver-advertise-address "${CONTROL_PLANE_IP}" \
  --kubernetes-version "${K8S_IMAGE_TAG}" \
  --node-name "${NODE_NAME}" \
  --cri-socket unix:///var/run/containerd/containerd.sock

# ───────────────────────────── Post-init guidance ─────────────────────────────
hr
info "Next steps — choose your path"
hr
blank

printf "%bOption A (RECOMMENDED — Manual & Transparent)%b\n" "$C_BOLD" "$C_RESET"
echo "• Use the kubeadm instructions printed above to:"
echo "  - configure kubeconfig"
echo "  - join worker or additional control-plane nodes"
blank

printf "%bOption B (Assisted — Not recommended for production)%b\n" "$C_BOLD" "$C_RESET"
echo "• Configure kubeconfig automatically using infra-bootstrap:"
echo
echo "  curl -fsSL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/kubernetes/cluster/kubeconfig-helper.sh | bash"
blank

printf "%bOptional: Install a CNI using infra-bootstrap%b\n" "$C_BOLD" "$C_RESET"
echo "• Choose and install a CNI (Calico / Flannel / Weave):"
echo
echo "  curl -fsSL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/kubernetes/cni/install-cni | bash"
blank

hr
ok "Control plane bootstrap completed"
blank

exit 0