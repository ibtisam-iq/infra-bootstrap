#!/usr/bin/env bash
# ============================================================================
# infra-bootstrap — Kubernetes Existing Cluster Detection
# ----------------------------------------------------------------------------
# Purpose:
#   Detect whether Kubernetes cluster state already exists on this node
#   and prevent unsafe kubeadm init execution.
#
# Behavior:
#   • Read-only detection
#   • Interactive remediation option
#   • Operator-controlled cleanup
# ============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Load common library ──────────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common.sh"
  exit 1
}

require_root

# Ensure interactive input works with curl | bash
exec </dev/tty || true

# ───────────────────────── Internal state ───────────────────────────────────
FOUND=false
declare -a DETECTED_ITEMS=()

# ───────────────────────── Known Artifacts ──────────────────────────────────

# Strong indicators (existence alone is enough)
K8S_STRONG_PATHS=(
  "/etc/kubernetes/admin.conf"
  "/etc/kubernetes/manifests"
  "/etc/kubernetes/pki/"
  "/var/lib/etcd"
)

# Weak indicators (must contain data)
K8S_WEAK_PATHS=(
  "/var/lib/kubelet"
  "/home/${SUDO_USER:-$USER}/.kube"
  "/etc/cni/net.d"
)

# Ports
K8S_PORTS=(
  6443   # kube-apiserver
  2379   # etcd
  2380
  10250  # kubelet
  10257
  10259
)

# ───────────────────────── Filesystem Detection ─────────────────────────────

for path in "${K8S_STRONG_PATHS[@]}"; do
  if [[ -e "$path" ]]; then
    FOUND=true
    DETECTED_ITEMS+=("Existing Kubernetes control plane files found at: $path")
  fi
done

for path in "${K8S_WEAK_PATHS[@]}"; do
  if [[ -d "$path" ]] && [[ -n "$(ls -A "$path" 2>/dev/null)" ]]; then
    FOUND=true
    DETECTED_ITEMS+=("Kubernetes node or configuration state detected at: $path")
  fi
done

# ───────────────────────── Port Detection ───────────────────────────────────
for port in "${K8S_PORTS[@]}"; do
  if ss -ltnp 2>/dev/null | grep -q ":$port "; then
    PROC=$(ss -ltnp | grep ":$port " | head -n1 | sed 's/.*users:(//;s/).*//')
    FOUND=true
    DETECTED_ITEMS+=("Port $port in use → $PROC")
  fi
done

# ───────────────────────── Decision Gate ────────────────────────────────────
if [[ "$FOUND" == false ]]; then
  ok "No existing Kubernetes cluster detected"
  blank
  exit 0
fi

warn "Existing Kubernetes cluster detected on this node"
blank

info "Detected artifacts:"
blank
for item in "${DETECTED_ITEMS[@]}"; do
  echo "  • $item"
done

blank
warn "This node is NOT safe for a fresh kubeadm init in its current state."
blank

info "Options:"
blank
echo "  1) Abort now and clean up manually"
echo "  2) Press Enter to automatically reset this node"
blank

read -rp "Press Enter to continue with automatic cleanup, or Ctrl+C to abort: " _
blank

if ! confirm_or_abort "Type 'YES' to confirm full cluster reset"; then
  blank
  exit 0
fi

blank
info "Starting automatic cluster reset..."
blank

bash <(curl -fsSL "$K8S_MAINTENANCE_URL/reset-cluster.sh")

ok "Cluster reset completed successfully"

exit 0