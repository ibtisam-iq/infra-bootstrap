#!/usr/bin/env bash
# ==================================================
# infra-bootstrap — Configure containerd for Kubernetes
# ==================================================

set -Eeuo pipefail
IFS=$'\n\t'

LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common library"
  exit 1
}

info "Configuring containerd for Kubernetes"

CONFIG_FILE="/etc/containerd/config.toml"

# ───────────────────────── Preflight ─────────────────────────
command -v containerd >/dev/null 2>&1 || error "containerd not installed"

mkdir -p /etc/containerd

# ───────────────────────── Generate Default Config ─────────────────────────
info "Generating default containerd configuration"
containerd config default > "$CONFIG_FILE"

# ───────────────────────── Kubernetes Requirements ─────────────────────────
info "Enabling systemd cgroup driver"
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' "$CONFIG_FILE"

# ───────────────────────── Enable Service ─────────────────────────
info "Enabling containerd service"
systemctl enable containerd --now

# ───────────────────────── Restart Service ─────────────────────────
info "Restarting containerd"
systemctl restart containerd

systemctl is-active --quiet containerd || error "containerd failed to restart"

ok "containerd configured successfully"
blank
exit 0