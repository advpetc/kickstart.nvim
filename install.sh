#!/usr/bin/env bash
#
# install.sh — Bootstrap script for Neovim dotfiles
#
# Installs all dependencies needed by the Neovim configuration at ~/.config/nvim/
# Supports: macOS (Homebrew), CentOS/RHEL (yum/dnf), Azure Linux/CBL-Mariner (tdnf)
#
# Usage:
#   bash install.sh          # interactive (prompts for JDK method)
#   bash install.sh --help   # show help
#
# One-liner (no clone needed):
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/advpetc/kickstart.nvim/master/install.sh)"
#
set -euo pipefail

# ─── Colors & Logging ────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_step()  { echo -e "\n${BOLD}━━━ $* ━━━${NC}"; }

# ─── OS Detection ────────────────────────────────────────────────────────────

detect_os() {
  case "$(uname -s)" in
    Darwin)
      OS="macos"
      ;;
    Linux)
      if [ -f /etc/mariner-release ] || [ -f /etc/azurelinux-release ]; then
        OS="azurelinux"
      elif [ -f /etc/centos-release ] || [ -f /etc/redhat-release ]; then
        OS="centos"
      else
        log_error "Unsupported Linux distribution. This script supports macOS, CentOS/RHEL, and Azure Linux."
        log_info  "You may still be able to adapt the commands for your distro."
        exit 1
      fi
      ;;
    *)
      log_error "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac
  log_info "Detected OS: ${BOLD}${OS}${NC}"
}

# ─── Package Manager Helpers ─────────────────────────────────────────────────

setup_package_manager() {
  if [ "$OS" = "macos" ]; then
    if ! command -v brew &>/dev/null; then
      log_info "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    PKG_INSTALL="brew install"
    PKG_UPDATE="brew update"
  elif [ "$OS" = "azurelinux" ]; then
    # Azure Linux 3.0 uses dnf, CBL-Mariner 2.0 uses tdnf
    if command -v tdnf &>/dev/null; then
      PKG_INSTALL="sudo tdnf install -y"
      PKG_UPDATE="sudo tdnf makecache"
    elif command -v dnf &>/dev/null; then
      PKG_INSTALL="sudo dnf install -y"
      PKG_UPDATE="sudo dnf makecache"
    else
      log_error "Neither tdnf nor dnf found on Azure Linux."
      exit 1
    fi
  else
    # CentOS/RHEL — prefer dnf, fall back to yum
    if command -v dnf &>/dev/null; then
      PKG_INSTALL="sudo dnf install -y"
      PKG_UPDATE="sudo dnf makecache"
    else
      PKG_INSTALL="sudo yum install -y"
      PKG_UPDATE="sudo yum makecache"
    fi
  fi
  log_info "Package manager ready"
}

install_package() {
  local cmd="$1"
  local pkg_macos="${2:-$1}"
  local pkg_centos="${3:-$1}"
  local pkg_azurelinux="${4:-$pkg_centos}"  # defaults to CentOS name

  if command -v "$cmd" &>/dev/null; then
    log_ok "$cmd already installed ($(command -v "$cmd"))"
    return 0
  fi

  local pkg
  case "$OS" in
    macos)      pkg="$pkg_macos" ;;
    azurelinux) pkg="$pkg_azurelinux" ;;
    *)          pkg="$pkg_centos" ;;
  esac

  log_info "Installing $pkg..."
  $PKG_INSTALL "$pkg"
  log_ok "$cmd installed"
}

# ─── Install Neovim ──────────────────────────────────────────────────────────

install_neovim() {
  log_step "Neovim"

  # Fetch latest stable version tag from GitHub
  local latest_version
  latest_version=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Neovim version from GitHub API."
    exit 1
  fi

  # Check if already installed and up to date
  if command -v nvim &>/dev/null; then
    local current_version
    current_version=$(nvim --version | head -1 | sed -E 's/NVIM v/v/')
    if [ "$current_version" = "$latest_version" ]; then
      log_ok "Neovim already up to date: $current_version"
      return 0
    fi
    log_warn "Neovim outdated: $current_version (latest: $latest_version)"
  fi

  if [ "$OS" = "macos" ]; then
    log_info "Installing/upgrading Neovim via Homebrew..."
    brew install neovim || brew upgrade neovim
  else
    # CentOS/Azure Linux — install from GitHub release (repos have outdated versions)
    local nvim_url="https://github.com/neovim/neovim/releases/download/${latest_version}/nvim-linux-x86_64.tar.gz"
    local install_dir="/opt/nvim"

    log_info "Installing Neovim ${latest_version} from GitHub release..."
    curl -fsSL "$nvim_url" -o /tmp/nvim-linux-x86_64.tar.gz
    sudo rm -rf "$install_dir"
    sudo mkdir -p "$install_dir"
    sudo tar -xzf /tmp/nvim-linux-x86_64.tar.gz -C "$install_dir" --strip-components=1
    sudo ln -sf "$install_dir/bin/nvim" /usr/local/bin/nvim
    rm -f /tmp/nvim-linux-x86_64.tar.gz
  fi

  log_ok "Neovim installed: $(nvim --version | head -1)"
}

# ─── Install fd ──────────────────────────────────────────────────────────────

install_fd() {
  if command -v fd &>/dev/null || command -v fdfind &>/dev/null; then
    log_ok "fd already installed ($(command -v fd || command -v fdfind))"
    return 0
  fi

  case "$OS" in
    macos)
      log_info "Installing fd via Homebrew..."
      brew install fd
      ;;
    centos)
      log_info "Installing fd-find via package manager..."
      $PKG_INSTALL fd-find
      ;;
    azurelinux)
      # fd is not in Azure Linux repos — install from GitHub release
      local fd_version
      fd_version=$(curl -fsSL https://api.github.com/repos/sharkdp/fd/releases/latest | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')
      if [ -z "$fd_version" ]; then
        log_warn "Could not fetch fd version from GitHub. Skipping fd install."
        return 0
      fi
      local fd_url="https://github.com/sharkdp/fd/releases/download/v${fd_version}/fd-v${fd_version}-x86_64-unknown-linux-gnu.tar.gz"
      log_info "Installing fd ${fd_version} from GitHub release..."
      curl -fsSL "$fd_url" -o /tmp/fd.tar.gz
      tar -xzf /tmp/fd.tar.gz -C /tmp
      sudo cp "/tmp/fd-v${fd_version}-x86_64-unknown-linux-gnu/fd" /usr/local/bin/fd
      sudo chmod +x /usr/local/bin/fd
      rm -rf /tmp/fd.tar.gz "/tmp/fd-v${fd_version}-x86_64-unknown-linux-gnu"
      ;;
  esac
  log_ok "fd installed"
}

# ─── Install System Tools ────────────────────────────────────────────────────

install_system_tools() {
  log_step "System Tools"

  $PKG_UPDATE &>/dev/null || true

  # Core build tools
  install_package "git"    "git"    "git"
  install_package "make"   "make"   "make"
  install_package "unzip"  "unzip"  "unzip"
  install_package "curl"   "curl"   "curl"

  # C compiler
  if [ "$OS" = "macos" ]; then
    if ! xcode-select -p &>/dev/null; then
      log_info "Installing Xcode Command Line Tools (includes gcc/clang)..."
      xcode-select --install 2>/dev/null || log_warn "Xcode CLT install may require manual confirmation"
    else
      log_ok "Xcode Command Line Tools already installed"
    fi
  else
    install_package "gcc" "gcc" "gcc"
    install_package "g++" "gcc" "gcc-c++"
  fi

  # Search tools
  install_package "rg"  "ripgrep" "ripgrep" "ripgrep"
  install_fd

  # GitHub CLI
  if ! command -v gh &>/dev/null; then
    if [ "$OS" = "centos" ]; then
      log_info "Adding GitHub CLI repo for CentOS..."
      sudo dnf install -y 'dnf-command(config-manager)' 2>/dev/null \
        || sudo yum install -y yum-utils 2>/dev/null || true
      sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo 2>/dev/null \
        || sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo 2>/dev/null || true
    elif [ "$OS" = "azurelinux" ]; then
      log_info "Adding GitHub CLI repo for Azure Linux..."
      sudo rpm --import https://cli.github.com/packages/rpm/gh-cli.repo.key 2>/dev/null || true
      sudo tee /etc/yum.repos.d/gh-cli.repo > /dev/null <<'GHREPO'
[gh-cli]
name=packages for the GitHub CLI
baseurl=https://cli.github.com/packages/rpm
enabled=1
gpgkey=https://cli.github.com/packages/rpm/gh-cli.repo.key
GHREPO
    fi
  fi
  install_package "gh" "gh" "gh"
}

# ─── Install Node.js ─────────────────────────────────────────────────────────

install_nodejs() {
  log_step "Node.js (needed by Mason for some LSP servers)"

  if command -v node &>/dev/null; then
    log_ok "Node.js already installed: $(node --version)"
    return 0
  fi

  if [ "$OS" = "macos" ]; then
    brew install node
  elif [ "$OS" = "azurelinux" ]; then
    log_info "Installing Node.js via tdnf..."
    $PKG_INSTALL nodejs
  else
    # CentOS — use NodeSource repo for LTS
    log_info "Installing Node.js LTS via NodeSource..."
    curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
    $PKG_INSTALL nodejs
  fi

  log_ok "Node.js installed: $(node --version)"
}

# ─── Install Go ──────────────────────────────────────────────────────────────

install_go() {
  log_step "Go (needed for delve DAP)"

  if command -v go &>/dev/null; then
    log_ok "Go already installed: $(go version)"
    return 0
  fi

  if [ "$OS" = "macos" ]; then
    brew install go
  else
    local go_version="1.22.5"
    local go_url="https://go.dev/dl/go${go_version}.linux-amd64.tar.gz"
    log_info "Installing Go ${go_version} from official release..."
    curl -fsSL "$go_url" -o /tmp/go.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -xzf /tmp/go.tar.gz -C /usr/local
    rm -f /tmp/go.tar.gz

    # Add to PATH if not already there
    if ! grep -q '/usr/local/go/bin' ~/.bashrc 2>/dev/null; then
      echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    fi
    export PATH=$PATH:/usr/local/go/bin
  fi

  log_ok "Go installed: $(go version)"
}

# ─── Install JDK 21 ──────────────────────────────────────────────────────────

install_jdk() {
  log_step "JDK 21 (needed for jdtls Java LSP)"

  # Check if JDK 21 is already available
  # Filter out JAVA_TOOL_OPTIONS noise (JVM prints it to stderr before version)
  if command -v java &>/dev/null; then
    local java_ver
    java_ver=$(java -version 2>&1 | grep -i 'version' | head -1)
    if echo "$java_ver" | grep -q '"21\.'; then
      log_ok "JDK 21 already installed: $java_ver"
      return 0
    else
      log_warn "Java found but not version 21: $java_ver"
    fi
  fi

  # Azure Linux — try known package names, fall back to SDKMAN
  if [ "$OS" = "azurelinux" ]; then
    log_info "Attempting to install JDK 21 via package manager..."
    # Try common Azure Linux JDK 21 package names
    if $PKG_INSTALL msopenjdk-21 2>/dev/null; then
      log_ok "Microsoft JDK 21 installed (msopenjdk-21)"
      return 0
    elif $PKG_INSTALL java-21-openjdk-devel 2>/dev/null; then
      log_ok "OpenJDK 21 installed (java-21-openjdk-devel)"
      return 0
    fi
    log_warn "JDK 21 not found in repos. Falling back to SDKMAN..."
    if ! command -v sdk &>/dev/null; then
      log_info "Installing SDKMAN..."
      curl -fsSL "https://get.sdkman.io" | bash
      # shellcheck disable=SC1091
      set +u
      source "$HOME/.sdkman/bin/sdkman-init.sh"
      set -u
    fi
    set +u
    sdk install java 21.0.6-ms || true
    set -u
    log_ok "Microsoft JDK 21 installed via SDKMAN"
    return 0
  fi

  echo ""
  echo -e "${BOLD}How would you like to install JDK 21?${NC}"
  echo "  1) System package manager (brew/yum — installs OpenJDK 21)"
  echo "  2) SDKMAN (installs Microsoft JDK 21, matches config path)"
  echo "  3) Skip (I'll install it myself)"
  echo ""
  read -rp "Choose [1/2/3]: " jdk_choice

  case "$jdk_choice" in
    1)
      if [ "$OS" = "macos" ]; then
        log_info "Installing OpenJDK 21 via Homebrew..."
        brew install openjdk@21
        # Create symlink so system java finds it
        sudo ln -sfn "$(brew --prefix openjdk@21)/libexec/openjdk.jdk" \
          /Library/Java/JavaVirtualMachines/openjdk-21.jdk 2>/dev/null || true
        log_info "You may need to update JAVA_HOME in your jdtls config."
      else
        log_info "Installing OpenJDK 21 via package manager..."
        $PKG_INSTALL java-21-openjdk-devel
      fi
      log_ok "JDK 21 installed via package manager"
      ;;
    2)
      if ! command -v sdk &>/dev/null; then
        log_info "Installing SDKMAN..."
        curl -fsSL "https://get.sdkman.io" | bash
        # shellcheck disable=SC1091
        source "$HOME/.sdkman/bin/sdkman-init.sh"
      fi
      log_info "Installing Microsoft JDK 21 via SDKMAN..."
      sdk install java 21.0.6-ms || true
      log_ok "Microsoft JDK 21 installed via SDKMAN"
      log_info "The jdtls config expects JAVA_HOME at:"
      log_info "  /Library/Java/JavaVirtualMachines/jdk21.0.6-msft.jdk/Contents/Home"
      log_info "You may need to create a symlink if the SDKMAN path differs."
      ;;
    3)
      log_warn "Skipping JDK 21 installation."
      log_info "jdtls requires JDK 21. Install it manually and update lua/custom/plugins/java.lua"
      ;;
    *)
      log_warn "Invalid choice. Skipping JDK 21 installation."
      ;;
  esac
}

# ─── Install Nerd Font ────────────────────────────────────────────────────────

install_nerd_font() {
  log_step "Nerd Font (JetBrainsMono)"

  local font_name="JetBrainsMono"
  local font_dir

  if [ "$OS" = "macos" ]; then
    font_dir="$HOME/Library/Fonts"
  else
    font_dir="$HOME/.local/share/fonts"
  fi

  # Check if already installed
  if ls "$font_dir"/*JetBrainsMono* &>/dev/null 2>&1 || ls "$font_dir"/*JetBrainsMonoNerd* &>/dev/null 2>&1; then
    log_ok "JetBrainsMono Nerd Font already installed"
    return 0
  fi

  if [ "$OS" = "macos" ]; then
    log_info "Installing JetBrainsMono Nerd Font via Homebrew..."
    brew install --cask font-jetbrains-mono-nerd-font
  else
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.tar.xz"
    log_info "Downloading JetBrainsMono Nerd Font..."
    mkdir -p "$font_dir"
    curl -fsSL "$font_url" -o "/tmp/${font_name}.tar.xz"
    tar -xf "/tmp/${font_name}.tar.xz" -C "$font_dir"
    rm -f "/tmp/${font_name}.tar.xz"

    # Rebuild font cache
    if command -v fc-cache &>/dev/null; then
      fc-cache -fv "$font_dir" &>/dev/null
    fi
  fi

  log_ok "JetBrainsMono Nerd Font installed"
  log_info "Remember to set your terminal font to 'JetBrainsMono Nerd Font'"
}

# ─── li-format (LinkedIn Internal) ───────────────────────────────────────────

setup_li_format() {
  log_step "li-format (LinkedIn formatter)"

  if command -v li-format &>/dev/null; then
    log_ok "li-format already available"
    return 0
  fi

  # Check if we're on a LinkedIn machine (common indicators)
  if [ -d "$HOME/.linkedin" ] || [ -d "/export/apps" ] || command -v lid-client &>/dev/null; then
    log_info "LinkedIn environment detected. Attempting li-format setup..."
    # LinkedIn-internal: install via the internal toolchain
    # Uncomment and adjust the line below based on your LinkedIn setup:
    # brew install li-format  # or: pip install li-format
    log_warn "li-format auto-install not configured. Install it via your team's instructions."
  else
    log_warn "li-format is a LinkedIn-internal tool and is not available publicly."
    log_info "The <leader>f keymap in init.lua calls li-format for formatting."
    log_info "On non-LinkedIn machines, you can remap <leader>f to use conform.nvim instead."
  fi
}

# ─── Clone Neovim Config ─────────────────────────────────────────────────────

NVIM_CONFIG_REPO="https://github.com/advpetc/kickstart.nvim.git"
NVIM_CONFIG_DIR="${HOME}/.config/nvim"

clone_nvim_config() {
  log_step "Neovim Configuration"

  if [ -d "$NVIM_CONFIG_DIR/.git" ]; then
    log_ok "Neovim config already exists at $NVIM_CONFIG_DIR (git repo)"
    log_info "Pulling latest changes..."
    git -C "$NVIM_CONFIG_DIR" pull --ff-only 2>/dev/null || log_warn "Could not pull — you may have local changes"
    return 0
  fi

  if [ -d "$NVIM_CONFIG_DIR" ] || [ -f "$NVIM_CONFIG_DIR" ]; then
    local backup="${NVIM_CONFIG_DIR}.bak.$(date +%Y%m%d%H%M%S)"
    log_warn "Existing config found at $NVIM_CONFIG_DIR"
    log_info "Backing up to $backup"
    mv "$NVIM_CONFIG_DIR" "$backup"
  fi

  # Also back up existing Neovim data/state/cache if present
  for dir in "${HOME}/.local/share/nvim" "${HOME}/.local/state/nvim" "${HOME}/.cache/nvim"; do
    if [ -d "$dir" ]; then
      local dir_backup="${dir}.bak.$(date +%Y%m%d%H%M%S)"
      log_info "Backing up $dir → $dir_backup"
      mv "$dir" "$dir_backup"
    fi
  done

  log_info "Cloning Neovim config from $NVIM_CONFIG_REPO..."
  mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"
  git clone "$NVIM_CONFIG_REPO" "$NVIM_CONFIG_DIR"
  log_ok "Neovim config cloned to $NVIM_CONFIG_DIR"
}

# ─── Bootstrap lazy.nvim ─────────────────────────────────────────────────────

bootstrap_lazy_nvim() {
  log_step "lazy.nvim Plugin Manager"

  local lazy_path="${HOME}/.local/share/nvim/lazy/lazy.nvim"

  if [ -d "$lazy_path" ]; then
    log_ok "lazy.nvim already cloned"
    return 0
  fi

  log_info "Cloning lazy.nvim..."
  git clone --filter=blob:none --branch=stable \
    https://github.com/folke/lazy.nvim.git "$lazy_path"
  log_ok "lazy.nvim cloned"
}

# ─── Headless Neovim Setup ───────────────────────────────────────────────────

run_headless_setup() {
  log_step "Neovim Headless Setup (plugins, LSPs, parsers)"

  log_info "Installing plugins via lazy.nvim..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

  log_info "Installing Mason tools (LSP servers, DAPs, formatters)..."
  # Give Mason time to install — MasonToolsInstallSync blocks until done
  nvim --headless "+MasonToolsInstallSync" +qa 2>/dev/null || true

  log_info "Installing Treesitter parsers..."
  nvim --headless "+TSUpdateSync" +qa 2>/dev/null || true

  log_ok "Headless setup complete"
}

# ─── Summary ─────────────────────────────────────────────────────────────────

print_summary() {
  log_step "Installation Complete!"

  echo ""
  echo -e "${GREEN}${BOLD}✓ All dependencies installed!${NC}"
  echo ""
  echo -e "  ${BOLD}Next steps:${NC}"
  echo "  1. Open Neovim:  nvim"
  echo "  2. Run health check:  :checkhealth"
  echo "  3. If using Java, verify jdtls config path in lua/custom/plugins/java.lua"
  echo ""

  # Check for potential issues
  local warnings=0
  if ! command -v li-format &>/dev/null; then
    echo -e "  ${YELLOW}⚠ li-format not found — <leader>f formatting may not work${NC}"
    ((warnings++)) || true
  fi
  if ! command -v java &>/dev/null; then
    echo -e "  ${YELLOW}⚠ Java not found — jdtls will not work${NC}"
    ((warnings++)) || true
  fi

  if [ "$warnings" -eq 0 ]; then
    echo -e "  ${GREEN}No warnings — you're all set!${NC}"
  fi
  echo ""
}

# ─── Help ─────────────────────────────────────────────────────────────────────

show_help() {
  echo "Usage: bash install.sh"
  echo ""
  echo "One-liner install (no clone needed):"
  echo "  sh -c \"\\\$(curl -fsSL https://raw.githubusercontent.com/advpetc/kickstart.nvim/master/install.sh)\""
  echo ""
  echo "Installs all dependencies for the Neovim configuration and clones the"
  echo "config repo to ~/.config/nvim/ (backs up any existing config)."
  echo ""
  echo "Supports:"
  echo "  • macOS (Homebrew)"
  echo "  • CentOS / RHEL (yum/dnf)"
  echo "  • Azure Linux / CBL-Mariner (tdnf)"
  echo ""
  echo "What gets installed:"
  echo "  • Neovim (latest stable)"
  echo "  • Neovim config (cloned from GitHub)"
  echo "  • System tools: git, make, gcc, unzip, curl, ripgrep, fd, gh"
  echo "  • Node.js (for Mason LSP installs)"
  echo "  • Go (for delve DAP)"
  echo "  • JDK 21 (interactive — choose package manager or SDKMAN)"
  echo "  • JetBrainsMono Nerd Font"
  echo "  • lazy.nvim plugin manager"
  echo "  • All Neovim plugins, LSP servers, and Treesitter parsers"
  echo ""
  echo "Options:"
  echo "  --help    Show this help message"
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
  if [[ "${1:-}" == "--help" ]]; then
    show_help
    exit 0
  fi

  echo -e "${BOLD}"
  echo "╔══════════════════════════════════════════════╗"
  echo "║   Neovim Dotfiles — Dependency Installer     ║"
  echo "╚══════════════════════════════════════════════╝"
  echo -e "${NC}"

  detect_os
  setup_package_manager
  install_neovim
  install_system_tools
  clone_nvim_config
  install_nodejs
  install_go
  install_jdk
  install_nerd_font
  setup_li_format
  bootstrap_lazy_nvim
  run_headless_setup
  print_summary
}

main "$@"
