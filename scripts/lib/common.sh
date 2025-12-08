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

# ======================= System Validation ======================
require_root() {
  [[ ${EUID:-$(id -u)} -eq 0 ]] || error "This command must be run as root."
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || error "Required command missing: $1"
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
