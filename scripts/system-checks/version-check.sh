#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════════╗
# ║ infra-bootstrap – Version Check                        ║
# ║ (c) 2025 Muhammad Ibtisam Iqbal – MIT License          ║
# ╚════════════════════════════════════════════════════════╝
#
# Industry-grade tool version checker
# • Graceful handling of missing tools
# • Works in CI and locally
# • No fragile parsing – uses ${COMMAND:-} fallback pattern

set -euo pipefail
IFS=$'\n\t'

# ── Colors (only if terminal supports it) ─────────────────────────────────────
if [[ -t 1 ]]; then
  readonly C_RESET="\033[0m"
  readonly C_BOLD="\033[1m"
  readonly C_RED="\033[31m"
  readonly C_GREEN="\033[32m"
  readonly C_YELLOW="\033[33m"
  readonly C_BLUE="\033[34m"
  readonly C_MAGENTA="\033[35m"
  readonly C_CYAN="\033[36m"
else
  readonly C_RESET='' C_BOLD='' C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_MAGENTA='' C_CYAN=''
fi

# ── Helper: print with consistent formatting ──────────────────────────────────
log() {
  printf "%b\n" "$*"
}

# ── Helper: get version safely ────────────────────────────────────────────────
get_version() {
  local cmd=$1
  local fallback=${2:-"Not installed"}

  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf "%b" "${C_RED}${fallback}${C_RESET}"
    return
  fi

  local version
  case $cmd in
    ansible)    version=$(ansible --version | grep -E '^ansible ' | awk '{print $NF}' | tr -d ']') ;;
    aws)        version=$(aws --version | awk '{print $1}' | cut -d/ -f2) ;;
    docker)     version=$(docker --version | awk '{print $3}' | tr -d ',') ;;
    containerd) version=$(containerd --version | awk '{print $3}') ;;
    runc)       version=$(runc --version | awk '{print $3}') ;;
    git)        version=$(git --version | awk '{print $3}') ;;
    python3)    version=$(python3 --version | awk '{print $2}') ;;
    node)       version=$(node --version | cut -c2-) ;;
    npm)        version=$(npm --version) ;;
    helm)       version=$(helm version --short | awk '{print $2}' | cut -c2-) ;;
    jenkins)    version=$(java -jar /var/lib/jenkins/jenkins.war --version || echo "Not installed") ;;
    kubectl)    version=$(kubectl version --client --output=json 2>/dev/null | jq -r .clientVersion.gitVersion) ;;
    eksctl)     version=$(eksctl version 2>/dev/null) ;;
    terraform)  version=$(terraform --version | head -n1 | awk '{print $2}' | cut -c2-) ;;
    *)          version=$("$cmd" --version | head -n1 || echo "unknown") ;;
  esac

  if [[ -n $version && $version != "unknown" ]]; then
    printf "%b" "${C_GREEN}${version}${C_RESET}"
  else
    printf "%b" "${C_RED}Installed (no version)${C_RESET}"
  fi
}

# ── Main header (no clear; do NOT wipe terminal) ─────────────────────────────
log "${C_BOLD}${C_CYAN}
╔════════════════════════════════════════════════════════╗
║          infra-bootstrap – Tool Version Report         ║
║        (c) 2025 Muhammad Ibtisam Iqbal – MIT           ║
╚════════════════════════════════════════════════════════╝${C_RESET}
"

# ── Preflight (run quietly; show only status) ────────────────────────────────
REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/system-checks"

log "${C_BLUE}Running preflight system checks...${C_RESET}"
if command -v curl >/dev/null 2>&1 && command -v bash >/dev/null 2>&1; then
  if preflight_output=$(bash <(curl -fsSL "$REPO_URL/preflight.sh") 2>&1); then
    # Success: keep output clean, no spam from preflight
    log "${C_GREEN}Preflight passed!${C_RESET}"
    log ""  # blank line
  else
    # Failure: show details so user can debug
    log "${C_RED}Preflight failed! Showing details below:${C_RESET}"
    printf "%s\n\n" "$preflight_output"
  fi
else
  log "${C_YELLOW}curl or bash not available – skipping preflight${C_RESET}"
  log ""
fi

# ── Tool versions (aligned output) ───────────────────────────────────────────
log "${C_BOLD}${C_YELLOW}Installed Tools & Versions${C_RESET}"
log "${C_MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"

# cmd|Label format so labels can contain spaces
declare -a tools=(
  "ansible|Ansible"
  "aws|AWS CLI"
  "docker|Docker"
  "containerd|Containerd"
  "runc|Runc"
  "git|Git"
  "python3|Python3"
  "node|Node.js"
  "npm|npm"
  "helm|Helm"
  "kubectl|kubectl"
  "eksctl|eksctl"
  "terraform|Terraform"
)

# Column width for nice alignment
readonly NAME_COLUMN_WIDTH=14

for entry in "${tools[@]}"; do
  IFS='|' read -r cmd name <<< "$entry"
  version=$(get_version "$cmd")
  # Example line:  • Ansible:       2.10.0
  printf " %b•%b %-*s %s\n" \
    "${C_CYAN}" "${C_RESET}" \
    "$NAME_COLUMN_WIDTH" "${name}:" \
    "$version"
done

log "${C_MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
log ""
log "${C_BOLD}${C_GREEN}Version check completed successfully!${C_RESET}"
log "${C_BOLD}${C_BLUE}Happy Hacking!${C_RESET}"
log ""
