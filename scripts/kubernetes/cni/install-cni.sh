#!/usr/bin/env bash
# ============================================================================
# infra-bootstrap — CNI Installation Entrypoint
# ----------------------------------------------------------------------------
# Supported CNIs:
#   • Calico
#   • Flannel
#
# This script:
#   - Requires an existing Kubernetes cluster
#   - Supports ONLY Calico and Flannel
#   - Can remove ONLY Calico or Flannel
#   - Will NOT attempt to remove unknown CNIs
#
# Responsibilities:
#   - Verify cluster availability
#   - Ensure CNI binaries are installed
#   - Detect leftover CNI filesystem state
#   - Detect active Calico / Flannel pods
#   - Perform safe, operator-approved cleanup
#   - Install selected CNI
# ============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Load common library ──────────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common.sh"
  exit 1
}

# ───────────────────────── Load ensure_kubeconfig lib ───────────────────────
source <(curl -fsSL "$ENSURE_KUBECONFIG_URL") || {
  echo "FATAL: Unable to load ensure_kubeconfig.sh"
  exit 1
}

require_root
print_execution_user
confirm_sudo_execution

exec </dev/tty || true

# ───────────────────────── Constants ────────────────────────────────────────
CNI_BIN_DIR="/opt/cni/bin"
CNI_CONFIG_DIR="/etc/cni/net.d"
CALICO_LABEL="k8s-app=calico-node"
FLANNEL_LABEL="app=flannel"

# ───────────────────────── Header & Disclaimer ──────────────────────────────
info "infra-bootstrap — CNI Installation"
blank

warn "DISCLAIMER"
blank
echo "  • This script supports installation ONLY for the following CNIs:"
echo "      - Calico"
echo "      - Flannel"
blank
echo "  • It can REMOVE only Calico or Flannel."
echo "  • It will NOT remove or detect other CNIs."
echo "  • If another CNI is installed, this script is NOT suitable."
blank

read -rp "Press Enter to continue, or Ctrl+C to abort: " _
blank

# ───────────────────────── Phase 1: Cluster detection ───────────────────────
info "Verifying Kubernetes cluster availability..."

ensure_kubeconfig

if ! kubectl get ns kube-system &>/dev/null; then
  warn "No Kubernetes cluster detected."
  blank
  info "Please initialize the cluster first:"
  blank
  cmd "curl -fsSL $INIT_CONTROL_PLANE_URL | sudo bash"
  blank
  exit 1
fi

ok "Kubernetes cluster detected"
blank

# ───────────────────────── Phase 2: Ensure CNI binaries ─────────────────────
info "Checking CNI binaries directory..."

if [[ ! -d "$CNI_BIN_DIR" ]] || [[ -z "$(ls -A "$CNI_BIN_DIR" 2>/dev/null)" ]]; then
  warn "CNI binaries not found in $CNI_BIN_DIR"
  blank
  read -rp "Press Enter to install CNI binaries, or Ctrl+C to abort: " _
  blank
  bash <(curl -fsSL "$K8S_RUNTIME_URL/install-cni-binaries.sh")
  blank
else
  ok "CNI binaries detected in $CNI_BIN_DIR"
fi
blank

# ───────────────────────── Phase 3: Detect CNI filesystem residue ───────────
info "Checking for leftover CNI configuration files..."

CNI_FS_RESIDUE=false

if compgen -G "$CNI_CONFIG_DIR/*.conf" > /dev/null || \
   compgen -G "$CNI_CONFIG_DIR/*.conflist" > /dev/null; then
  CNI_FS_RESIDUE=true
fi

#if [[ -d "$CNI_CONFIG_DIR" ]] && \
#   ls "$CNI_CONFIG_DIR"/*.conf "$CNI_CONFIG_DIR"/*.conflist &>/dev/null; then
#  CNI_FS_RESIDUE=true
#fi

if [[ "$CNI_FS_RESIDUE" == true ]]; then
  warn "CNI configuration files detected in $CNI_CONFIG_DIR"
  info "This may be leftover configuration from a previous installation."
  blank

  read -rp "Press Enter to remove CNI configuration files, or Ctrl+C to abort: " _
  blank

  rm -f "$CNI_CONFIG_DIR"/*.conf "$CNI_CONFIG_DIR"/*.conflist 2>/dev/null || true
  ok "CNI configuration files removed"
  blank
else
  ok "No CNI filesystem residue detected at: $CNI_CONFIG_DIR"
  blank
fi

# ───────────────────────── Phase 4: Detect active CNI pods ──────────────────
info "Checking for active CNI pods..."

# Detect both CNIs independently

FOUND_CALICO=false
FOUND_FLANNEL=false

if kubectl -n calico-system get ds calico-node &>/dev/null; then
  FOUND_CALICO=true
fi

if kubectl -n kube-flannel get ds kube-flannel-ds &>/dev/null; then
  FOUND_FLANNEL=true
fi

# Decide what to reset (no guessing)

if [[ "$FOUND_CALICO" == false && "$FOUND_FLANNEL" == false ]]; then
  ok "No active supported CNI detected"
  blank
else
  warn "Existing CNI detected"
  blank

  if [[ "$FOUND_CALICO" == true ]]; then
    echo "  • Calico detected"
  fi

  if [[ "$FOUND_FLANNEL" == true ]]; then
    echo "  • Flannel detected"
  fi

  blank

  if ! confirm_or_abort "Type 'YES' to reset detected CNI components"; then
    warn "CNI reset aborted by operator"
    exit 0
  fi
  blank
fi

# Reset only what exists

if [[ "$FOUND_CALICO" == true ]]; then
  info "Resetting Calico CNI..."
  bash <(curl -fsSL "$K8S_MAINTENANCE_URL/reset-calico.sh")
  ok "Calico reset completed"
  blank
fi

if [[ "$FOUND_FLANNEL" == true ]]; then
  info "Resetting Flannel CNI..."
  bash <(curl -fsSL "$K8S_MAINTENANCE_URL/reset-flannel.sh")
  ok "Flannel reset completed"
  blank
fi

# ───────────────────────── Phase 5: CNI selection & install ─────────────────
while true; do
  info "Select CNI plugin to install"
  blank
  echo "  1) Calico (default)"
  echo "  2) Flannel"
  echo "  0) Exit"
  blank

  read -rp "Enter your choice [1]: " CHOICE _
  blank

  CHOICE="${CHOICE:-1}"

  case "$CHOICE" in
    1)
      info "Installing Calico..."
      bash <(curl -fsSL "$K8S_CNI_URL/install-calico.sh")
      break
      ;;
    2)
      info "Installing Flannel..."
      bash <(curl -fsSL "$K8S_CNI_URL/install-flannel.sh")
      break
      ;;
    0)
      info "Exiting CNI installer"
      exit 0
      ;;
    *)
      warn "Invalid selection. Please try again."
      blank
      ;;
  esac
done

blank
ok "CNI installation flow completed successfully"
exit 0
