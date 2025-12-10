#!/usr/bin/env bash
# ============================================================================
# infra-bootstrap — kind (Kubernetes-in-Docker) Installer
# Installs latest stable kind release for Linux amd64
# ============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ───────────────────────── Source shared library ─────────────────────────────
LIB_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"
source <(curl -fsSL "$LIB_URL") || { echo "FATAL: Unable to load core library"; exit 1; }

banner "Installing: kind"


info "Running preflight..."
if bash <(curl -fsSL "https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/system-checks/preflight.sh") >/dev/null 2>&1; then
    ok "Preflight passed."
else
    error "Preflight failed — aborting."
fi
blank


# ─────────────────────── Skip if already installed ───────────────────────────
if command -v kind >/dev/null 2>&1; then
    CURRENT=$(kind version 2>/dev/null | sed -n 's/^kind v//p' | awk '{print $1}')
    warn "kind is already installed ($CURRENT)"
    hr
    item "kind" "$CURRENT"
    hr
    ok "No installation performed"
    blank
    exit 0
fi

# ───────────────────────────── Architecture Check ────────────────────────────
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "amd64" ]]; then
    error "kind supports amd64 only — detected $ARCH"
fi

# ───────────────────────── Obtain latest release dynamically ─────────────────
info "Fetching latest kind release version..."
LATEST_KIND=$(curl -fsSL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest \
                 | grep '"tag_name"' | cut -d '"' -f4 | sed 's/^v//' | head -n1)

if [[ -z "${LATEST_KIND:-}" ]]; then
    error "Unable to fetch latest version metadata"
fi

ok "Latest version: $LATEST_KIND"
blank

# ───────────────────────────── Install kind binary ───────────────────────────
info "Downloading kind-amd64..."
curl -fsSL -o kind "https://kind.sigs.k8s.io/dl/v${LATEST_KIND}/kind-linux-amd64" \
    || error "Download failed"

chmod +x kind
sudo mv kind /usr/local/bin/kind

ok "kind installed."
blank

# ───────────────────────────── Version Summary ───────────────────────────────
PAD=16
item_ver() { printf " %b•%b %-*s %s\n" "$C_CYAN" "$C_RESET" "$PAD" "$1:" "$2"; }

KIND_VERSION=$(kind version 2>/dev/null | sed -n 's/^kind v//p' | awk '{print $1}')
KIND_VERSION="${KIND_VERSION:-unknown}"

hr
item_ver "kind" "$KIND_VERSION"
hr
ok "kind installation complete"
blank

exit 0