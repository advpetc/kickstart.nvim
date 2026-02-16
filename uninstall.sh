#!/usr/bin/env bash
#
# uninstall.sh — Remove Neovim configuration and associated data
#
# Usage:
#   bash uninstall.sh          # interactive (confirms before each step)
#   bash uninstall.sh --all    # remove everything without prompting
#   bash uninstall.sh --help   # show help
#
set -euo pipefail

# ─── Colors & Logging ────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_step()  { echo -e "\n${BOLD}━━━ $* ━━━${NC}"; }

# ─── Helpers ─────────────────────────────────────────────────────────────────

FORCE=false

confirm() {
  if [ "$FORCE" = true ]; then
    return 0
  fi
  local msg="$1"
  read -rp "$(echo -e "${YELLOW}$msg [y/N]:${NC} ")" answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

remove_dir() {
  local dir="$1"
  local label="${2:-$1}"
  if [ -d "$dir" ]; then
    if confirm "Remove $label ($dir)?"; then
      rm -rf "$dir"
      log_ok "Removed $dir"
    else
      log_info "Skipped $dir"
    fi
  else
    log_info "$label not found, skipping"
  fi
}

# ─── Main ────────────────────────────────────────────────────────────────────

show_help() {
  echo "Usage: bash uninstall.sh [OPTIONS]"
  echo ""
  echo "Removes the Neovim configuration and all associated data."
  echo ""
  echo "What gets removed:"
  echo "  ~/.config/nvim/              Neovim configuration"
  echo "  ~/.local/share/nvim/         Plugins, Mason tools, lazy.nvim data"
  echo "  ~/.local/state/nvim/         Sessions, shada, logs"
  echo "  ~/.cache/nvim/               Cache files"
  echo ""
  echo "Options:"
  echo "  --all     Remove everything without prompting"
  echo "  --help    Show this help message"
}

main() {
  case "${1:-}" in
    --help) show_help; exit 0 ;;
    --all)  FORCE=true ;;
  esac

  echo -e "${BOLD}"
  echo "╔══════════════════════════════════════════════╗"
  echo "║   Neovim Dotfiles — Uninstaller              ║"
  echo "╚══════════════════════════════════════════════╝"
  echo -e "${NC}"

  log_step "Neovim Data"

  remove_dir "$HOME/.config/nvim"          "Neovim config"
  remove_dir "$HOME/.local/share/nvim"     "Plugin data (lazy.nvim, Mason tools)"
  remove_dir "$HOME/.local/state/nvim"     "State (sessions, shada, logs)"
  remove_dir "$HOME/.cache/nvim"           "Cache"

  log_step "Done"
  echo ""
  echo -e "${GREEN}${BOLD}✓ Uninstall complete.${NC}"
  echo ""
  echo -e "  ${BOLD}Note:${NC} System tools (Neovim, ripgrep, fd, Node.js, Go, JDK, etc.)"
  echo "  were NOT removed. Uninstall them via your package manager if needed."
  echo ""
}

main "$@"
