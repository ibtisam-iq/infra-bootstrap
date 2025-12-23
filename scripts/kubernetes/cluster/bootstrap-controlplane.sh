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

# ───────────────────────── Load cluster parameters ─────────────────────────
info "Loading cluster parameters..."
source "$(curl -fsSL $K8S_BASE_URL/cluster-params.sh)"
blank

# ───────────────────────── Validate cluster parameters ───────────────────────
: "${CONTROL_PLANE_IP:?Missing CONTROL_PLANE_IP}"
: "${NODE_NAME:?Missing NODE_NAME}"
: "${POD_CIDR:?Missing POD_CIDR}"
: "${K8S_VERSION:?Missing K8S_VERSION}"

# ───────────────────────── Load version resolver ─────────────────────────
source <(curl -fsSL "$VERSION_RESOLVER_URL") || {
  error "Failed to load Kubernetes version resolver"
}

# ───────────────────────── Validate resolver outputs ───────────────────────
: "${K8S_PATCH_VERSION:?Missing K8S_PATCH_VERSION}"
: "${K8S_IMAGE_TAG:?Missing K8S_IMAGE_TAG}"

ok "Cluster parameters loaded"
blank

# ───────────────────────── Display summary ─────────────────────────

item "Control Plane IP"     "$CONTROL_PLANE_IP"
item "Node Name"            "$NODE_NAME"
item "Pod CIDR"             "$POD_CIDR"
item "Kubernetes Version"   "$K8S_PATCH_VERSION"
blank

# ───────────────────────── kubeadm init ─────────────────────────
info "Initializing Kubernetes control plane"

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
blank

# ───────────────────────────── Post-init guidance ─────────────────────────────
banner "Post-bootstrap guidance"

printf "%bPrimary next step (RECOMMENDED)%b\n" "$C_BOLD" "$C_RESET"
blank
echo "• Follow the kubeadm instructions printed above to:"
echo "  - configure kubeconfig for your user"
echo "  - join worker or additional control-plane nodes"
echo
echo "• These instructions are authoritative and should be preferred."
blank

printf "%bOptional helper: kubeconfig setup%b\n" "$C_BOLD" "$C_RESET"
blank
echo "• infra-bootstrap provides a helper to configure kubeconfig safely."
echo "• This helper:"
echo "  - detects the real user (even if run with sudo)"
echo "  - verifies kubectl access"
echo "  - provides guidance if no CNI is installed"
echo
cmd "curl -fsSL $K8S_BASE_URL/cluster/kubeconfig-helper.sh | bash"
blank

printf "%bOptional next step: install a CNI%b\n" "$C_BOLD" "$C_RESET"
blank
echo "• Kubernetes requires a CNI plugin before pods can be scheduled."
echo "• Supported CNIs: Calico, Flannel"
echo
cmd "curl -fsSL $INSTALL_CNI_URL | bash"
blank

footer "Kubernetes control plane bootstrap completed"

exit 0