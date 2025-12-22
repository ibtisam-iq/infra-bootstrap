#!/usr/bin/env bash
# ===============================================================
#  infra-bootstrap : Shared Core Library (common.sh)
#  Provides:
#    • Standard colors
#    • Logging functions
#    • Error handling
#    • UI helpers (banner, hr, blank)
#    • Basic validation & fetch helpers
# ===============================================================

# Safety for any script that sources this
set -Eeuo pipefail
IFS=$'\n\t'

# ========================= Colors ==============================
if [[ -t 1 ]]; then  # Only colorize when output is a TTY
  readonly C_RESET="\033[0m"
  readonly C_BOLD="\033[1m"
  readonly C_DIM="\033[2m"
  readonly C_RED="\033[31m"
  readonly C_GREEN="\033[32m"
  readonly C_YELLOW="\033[33m"
  readonly C_BLUE="\033[34m"
  readonly C_MAGENTA="\033[35m"
  readonly C_CYAN="\033[36m"
else
  readonly C_RESET='' C_BOLD='' C_DIM='' C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_MAGENTA='' C_CYAN=''
fi

# ========================= Logging =============================
info()  { printf "%b[INFO]%b    %s\n" "$C_BLUE"   "$C_RESET" "$*"; }
ok()    { printf "%b[ OK ]%b    %s\n" "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf "%b[WARN]%b    %s\n" "$C_YELLOW" "$C_RESET" "$*"; }
error() { printf "%b[ERR ]%b    %s\n" "$C_RED"   "$C_RESET" "$*" >&2; exit 1; }

# Bullet-style list entry (e.g. for tool/version lines)
item()  { printf " %b•%b %-14s %s\n" "$C_CYAN" "$C_RESET" "$1:" "$2"; }

# Simple blank line
blank() { printf "\n"; }

# Horizontal rule
hr() {
  printf "%b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n" "$C_MAGENTA" "$C_RESET"
}

# Full line coloring
cmd() {
  printf "%b%b[CMD ]    %s%b\n" \
    "$C_BOLD" \
    "$C_CYAN" \
    "$*" \
    "$C_RESET"
}

# ========================= Section Heading ======================
section() {
  hr
  printf "%b[INFO]%b    %s\n" "$C_BLUE" "$C_RESET" "$1"
}

footer() {
  hr
  printf "%b[ OK ]%b    %s\n\n" "$C_GREEN" "$C_RESET" "$1"
}

# ======================= System Validation ======================
require_root() {
  [[ ${EUID:-$(id -u)} -eq 0 ]] || error "This command must be run as root."
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || error "Required command missing: $1"
}

# ===================== Prevent Privileged Execution =====================
forbid_sudo() {

  # Block ONLY when: running as root, invoked via sudo, and original user was NOT root
  if [[ ${EUID:-$(id -u)} -eq 0 ]] \
     && [[ -n "${SUDO_USER:-}" ]] \
     && [[ "${SUDO_USER}" != "root" ]]; then
    error "This script must NOT be run with sudo. Please run it as a normal user."
  fi
}

# ===================== Privileged Execution Confirmation =====================
confirm_sudo_execution() {

  # Trigger ONLY when: running as root, invoked via sudo, and original user was NOT root
  if [[ ${EUID:-$(id -u)} -eq 0 ]] \
     && [[ -n "${SUDO_USER:-}" ]] \
     && [[ "${SUDO_USER}" != "root" ]]; then

    # warn "This script is running with elevated privileges via sudo."
    printf "%b[CONF]%b    Press Enter to continue, or Ctrl+C to abort..." \
      "$C_YELLOW" "$C_RESET"
    read -r
    blank
  fi
}

# ===================== Execution Visibility =====================
print_execution_user() {
  local effective_user invoking_user

  # Effective user (who the process is actually running as)
  effective_user="$(id -un 2>/dev/null || echo unknown)"

  # Always print the effective execution user
  info "Execution user: ${effective_user}"

  # If running as root via sudo by a non-root user, print extra context
  if [[ "${effective_user}" == "root" ]] && [[ -n "${SUDO_USER:-}" ]] && [[ "${SUDO_USER}" != "root" ]]; then
    warn "Script invoked via sudo privileges by user '${SUDO_USER}'"
    blank
  fi
}

# ========================== Remote Fetch =========================
fetch() {
  local url=$1
  curl -fsSL "$url" || error "Failed to fetch: $url"
}

run_remote() {
  local url=$1
  bash <(fetch "$url") || error "Remote execution failed: $url"
}

# ============================ UI ================================
banner() {
  # $1 = Title text
  printf "\n%b%s%b\n" "$C_CYAN" "╔════════════════════════════════════════════════════════╗" "$C_RESET"
  printf "%b║ infra-bootstrap — %s%b\n" "$C_CYAN" "$1" "$C_RESET"
  printf "%b%s%b\n" "$C_CYAN" "╚════════════════════════════════════════════════════════╝" "$C_RESET"
  blank
}

# ======================== Confirmation Prompt ========================

confirm_or_abort() {
  local prompt="$1"
  local max_attempts="${2:-3}"

  local attempt=1
  local response

  while [[ $attempt -le $max_attempts ]]; do
    read -rp "$prompt ($attempt of $max_attempts): " response

    if [[ "$response" == "YES" ]]; then
      return 0
    fi
    
    # Only warn if another attempt is still available
    if [[ $attempt -lt $max_attempts ]]; then
      blank
      warn "Invalid input. You must type exactly 'YES' to proceed."
      blank
    fi

    ((attempt++))
  done
  blank
  warn "Maximum confirmation attempts exceeded."
  warn "Operation aborted. No changes were made."
  blank
  return 1
}

export K8S_BASE_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/kubernetes"