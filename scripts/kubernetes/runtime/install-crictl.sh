#!/usr/bin/env bash
# ==================================================
# infra-bootstrap — Install crictl (CRI CLI)
#
# Method:
#   - Binary installation from official cri-tools releases
#
# Note:
#   crictl requires explicit runtime endpoint configuration
# ==================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Load common library ─────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || {
  echo "FATAL: Unable to load common library"
  exit 1
}

# ───────────────────────── Intro ─────────────────────────
info "CRI tooling installation"
info "Installing crictl (CRI command-line tool)"
info "Source: kubernetes-sigs/cri-tools (official)"

# ───────────────────────── Configuration ─────────────────────────
CRICTL_VERSION="${CRICTL_VERSION:-v1.30.0}"
TMP_DIR="/tmp/crictl-install"

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  *)
    error "Unsupported architecture: $(uname -m)"
    ;;
esac

TARBALL="crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz"
BASE_URL="https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}"
DOWNLOAD_URL="${BASE_URL}/${TARBALL}"
CHECKSUM_URL="${BASE_URL}/${TARBALL}.sha256"

# ───────────────────────── Preflight ─────────────────────────
if command -v crictl >/dev/null 2>&1; then
  CURRENT_VERSION="$(crictl --version | awk '{print $3}' | sed 's/^v//')"
  ok "crictl already installed (${CURRENT_VERSION}) — skipping"
  exit 0
fi

mkdir -p "$TMP_DIR"

# ───────────────────────── Download ─────────────────────────
info "Downloading crictl binary"
curl -fsSL "$DOWNLOAD_URL" -o "${TMP_DIR}/${TARBALL}" \
  || error "Failed to download crictl tarball"

info "Downloading checksum"
curl -fsSL "$CHECKSUM_URL" -o "${TMP_DIR}/${TARBALL}.sha256" \
  || error "Failed to download crictl checksum"

# ───────────────────────── Verify ─────────────────────────
info "Verifying checksum"

EXPECTED_HASH="$(cat "${TMP_DIR}/${TARBALL}.sha256")"
ACTUAL_HASH="$(sha256sum "${TMP_DIR}/${TARBALL}" | awk '{print $1}')"

[[ "$EXPECTED_HASH" == "$ACTUAL_HASH" ]] \
  || error "Checksum verification failed"

ok "Checksum verified"

# ───────────────────────── Install ─────────────────────────
info "Installing crictl to /usr/local/bin"
tar -xzf "${TMP_DIR}/${TARBALL}" -C /usr/local/bin \
  || error "Failed to extract crictl"

# ───────────────────────── Cleanup ─────────────────────────
rm -rf "$TMP_DIR"

# ───────────────────────── Validation ─────────────────────────
command -v crictl >/dev/null 2>&1 || error "crictl not found after installation"

INSTALLED_VERSION="$(crictl --version | awk '{print $3}' | sed 's/^v//')"

ok "crictl installed successfully"
info "crictl version: ${INSTALLED_VERSION}"
blank
