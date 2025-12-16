#!/usr/bin/env bash
# ==================================================
# infra-bootstrap — Install kubelet & kubeadm
#
# Purpose:
#   - Install Kubernetes node components for WORKER nodes
#   - kubelet + kubeadm only (NO kubectl)
#
# Versioning:
#   - User provides MAJOR.MINOR (e.g. 1.34)
#   - Script resolves latest PATCH automatically (e.g. 1.34.3-1.1)
#
# Repository:
#   - Official Kubernetes pkgs.k8s.io
# ==================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Load common library ─────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common library"
  exit 1
}

# ───────────────────────── Preflight ─────────────────────────
info "Kubernetes node components installation"
info "Target role: WORKER NODE"
info "Components: kubelet, kubeadm"

: "${K8S_VERSION:?K8S_VERSION is required (e.g. 1.34)}"

# Validate input: MAJOR.MINOR only
if ! [[ "$K8S_VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
  error "K8S_VERSION must be MAJOR.MINOR (e.g. 1.34). Provided: ${K8S_VERSION}"
fi

K8S_MAJOR_MINOR="$K8S_VERSION"

info "Kubernetes version requested: ${K8S_VERSION}"
info "Repository track: v${K8S_MAJOR_MINOR}"

# ───────────────────────── Dependencies ─────────────────────────
info "Installing required system packages"

apt-get update -qq >/dev/null
apt-get install -yq ca-certificates curl gpg >/dev/null

# ───────────────────────── Kubernetes Repository ─────────────────────────
info "Adding Kubernetes APT repository (pkgs.k8s.io)"

install -m 0755 -d /etc/apt/keyrings

if [[ -f /etc/apt/sources.list.d/kubernetes.list ]]; then
  info "Removing legacy Kubernetes APT source (kubernetes.list)"
  rm -f /etc/apt/sources.list.d/kubernetes.list
fi

if [[ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]]; then
  curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${K8S_MAJOR_MINOR}/deb/Release.key" \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
fi

cat >/etc/apt/sources.list.d/kubernetes.sources <<EOF
Types: deb
URIs: https://pkgs.k8s.io/core:/stable:/v${K8S_MAJOR_MINOR}/deb/
Suites: /
Components:
Signed-By: /etc/apt/keyrings/kubernetes-apt-keyring.gpg
EOF

apt-get update -qq >/dev/null

# ───────────────────────── Resolve Latest Patch Version ─────────────────────────
info "Resolving latest patch version for Kubernetes ${K8S_VERSION}"

KUBE_PKG_VERSION="$(
  apt-cache madison kubeadm \
    | awk '{print $3}' \
    | grep "^${K8S_VERSION}\." \
    | head -n 1
)"

[[ -n "$KUBE_PKG_VERSION" ]] || error "No Kubernetes packages found for ${K8S_VERSION}"

info "Resolved Kubernetes package version: ${KUBE_PKG_VERSION}"

# ───────────────────────── Install kubelet & kubeadm ─────────────────────────
info "Installing kubelet and kubeadm"

apt-get install -yq \
  kubelet="${KUBE_PKG_VERSION}" \
  kubeadm="${KUBE_PKG_VERSION}" \
  >/dev/null

# ───────────────────────── Hold Versions ─────────────────────────
info "Holding Kubernetes packages to prevent auto-upgrade"

apt-mark hold kubelet kubeadm >/dev/null

# ───────────────────────── Enable kubelet ─────────────────────────
info "Enabling kubelet service"

systemctl enable kubelet >/dev/null

# ───────────────────────── Validation ─────────────────────────
KUBELET_VERSION="$(kubelet --version | awk '{print $2}' | sed 's/^v//')"
KUBEADM_VERSION="$(kubeadm version -o short | sed 's/^v//')"

ok "Kubernetes node components installed successfully"
info "kubelet version: ${KUBELET_VERSION}"
info "kubeadm version: ${KUBEADM_VERSION}"
blank
