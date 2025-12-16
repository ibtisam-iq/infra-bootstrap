#!/usr/bin/env bash
# ==================================================
# infra-bootstrap — Install containerd (Package-Managed)
#
# Method:
#   - Uses Docker official APT repository
#   - Installs containerd.io (includes runc)
#   - Industry-standard, production-stable approach
#
# Note:
#   Binary-based installation exists but is NOT used here.
# ==================================================

set -Eeuo pipefail
IFS=$'\n\t'

LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common library"
  exit 1
}

info "Container runtime installation"
info "Method: PACKAGE-MANAGED (industry standard)"
info "Repository: Docker official APT repository"
info "APT format: Deb822 (.sources)"

# ───────────────────────── Preflight ─────────────────────────
command -v apt >/dev/null 2>&1 || error "APT not available on this system"

# ───────────────────────── Dependencies ─────────────────────────
info "Installing required system packages"
apt-get update -yq >/dev/null || error "Failed to update APT repositories"
apt-get install -yq ca-certificates curl gnupg lsb-release >/dev/null || error "Failed to install required packages"

# ───────────────────────── Docker Repository ─────────────────────────
info "Adding Docker APT repository"

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
mkdir -p /etc/apt/sources.list.d
tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt-get update -yq >/dev/null || error "Failed to update APT repositories"

# ───────────────────────── Install containerd ─────────────────────────
info "Installing containerd (containerd.io package)"
apt-get install -yq containerd.io >/dev/null || error "Failed to install containerd"

blank
