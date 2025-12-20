#!/usr/bin/env bash
# ===============================================================
#  infra-bootstrap : Kubernetes Helper Library
#  Provides:
#    • kubeconfig resolution
#    • kubectl safety helpers
# ===============================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ========================= Load Common Library ==================
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common.sh"
  exit 1
}

# ===================== Kubeconfig Resolution =====================
ensure_kubeconfig() {
  if [[ -n "${SUDO_USER:-}" ]]; then
    local user_home
    user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)

    [[ -n "$user_home" ]] || error "Unable to resolve home for SUDO_USER=$SUDO_USER"

    export KUBECONFIG="$user_home/.kube/config"
  else
    export KUBECONFIG="$HOME/.kube/config"
  fi

  [[ -f "$KUBECONFIG" ]] || error "Kubeconfig not found at: $KUBECONFIG"
}