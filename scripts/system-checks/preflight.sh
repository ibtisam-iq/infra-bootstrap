#!/usr/bin/env bash
# ===============================================================
#  infra-bootstrap : Universal System Preflight Checks
#  Scope:
#    • Runs before any tool installer (components/, kubernetes/, services/)
#    • NOT Kubernetes-specific; generic infra readiness
# ===============================================================

set -Eeuo pipefail
IFS=$'\n\t'

# Where to load the shared library (common.sh) from
COMMON_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/lib/common.sh"

# Download and source common.sh safely (for curl | bash remote mode)
tmp_common="$(mktemp)"
if ! curl -fsSL "$COMMON_URL" -o "$tmp_common"; then
  echo "ERROR: Failed to download common library from: $COMMON_URL" >&2
  rm -f "$tmp_common"
  exit 1
fi
# shellcheck disable=SC1090
source "$tmp_common"
rm -f "$tmp_common"

banner "System Preflight Checks"
require_root

# ===================== 1. OS Compatibility ======================
if [[ ! -f /etc/os-release ]]; then
  error "/etc/os-release not found – cannot determine OS."
fi

# shellcheck source=/dev/null
source /etc/os-release

case "${ID,,}" in
  ubuntu|linuxmint|pop)
    ok "Supported OS detected: ${PRETTY_NAME:-$ID}"
    ;;
  *)
    error "Unsupported OS: ${PRETTY_NAME:-$ID}. Supported: Ubuntu, Linux Mint & Pop!_OS."
    ;;
esac

# ===================== 2. Required Commands =====================
required_cmds=(curl bash lsb_release uname)
missing=()

for cmd in "${required_cmds[@]}"; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

if (( ${#missing[@]} > 0 )); then
  warn "Missing core utilities: ${missing[*]}"
  require_cmd apt-get
  info "Installing missing dependencies via apt-get..."

  export DEBIAN_FRONTEND=noninteractive
  if apt-get update -qq && apt-get install -yqq "${missing[@]}" >/dev/null; then
    ok "Core utilities installed successfully."
  else
    error "Failed to install required utilities. Check your apt sources."
  fi
else
  ok "Core shell utilities are present."
fi

# ===================== 3. Internet + DNS ========================
info "Checking basic Internet connectivity (ICMP)..."
if ping -c1 -W3 8.8.8.8 >/dev/null 2>&1; then
  ok "Internet connectivity verified (ping to 8.8.8.8)."
else
  error "No network connectivity – cannot reach 8.8.8.8. Connect to the internet and retry."
fi

info "Checking DNS & HTTPS reachability..."
if curl -fsSL https://github.com >/dev/null 2>&1; then
  ok "DNS resolution and HTTPS access working (github.com)."
else
  warn "DNS/HTTPS check failed – remote downloads may fail (github.com unreachable)."
fi

# ===================== 4. Architecture ==========================
arch=$(uname -m)
case "$arch" in
  x86_64|amd64)
    ok "Architecture supported: $arch"
    ;;
  *)
    error "Unsupported architecture: $arch. This project supports x86_64 / amd64 only."
    ;;
esac

# ===================== 5. CPU / RAM / Disk ======================
cpus=$(nproc || echo 1)
ram_mb=$(awk '/MemTotal/{print int($2/1024)}' /proc/meminfo)
disk_gb=$(df -Pm / | awk 'NR==2{print int($4/1024)}')

info "Evaluating hardware capacity..."
(( cpus < 2 )) && warn "Low CPU cores: ${cpus}. Recommended: ≥ 2 for lab workloads."
(( ram_mb < 2000 )) && warn "Low RAM: ${ram_mb}MB. Recommended: ≥ 2048MB."
(( disk_gb < 10 )) && warn "Low disk space: ${disk_gb}GB free on /. Recommended: ≥ 10GB."

ok "Hardware checks completed."

# ===================== 6. Virtualization Support =================
info "Checking CPU virtualization support flags..."
if grep -Eq 'vmx|svm' /proc/cpuinfo; then
  ok "Virtualization extensions detected (vmx/svm)."
else
  warn "No virtualization flags detected (vmx/svm). Some tooling (VM-based labs) may be limited."
fi

# ===================== 7. Systemd Availability ===================
info "Checking init system (systemd)..."
if command -v systemctl >/dev/null 2>&1; then
  ok "systemd is available – service-based components can be managed."
else
  warn "systemd not found. Some services may not be controllable via systemctl."
fi

# ===================== Final Summary =============================
blank
ok "Preflight checks completed successfully."
info "Your system is ready to run infra-bootstrap scripts."
blank

exit 0

