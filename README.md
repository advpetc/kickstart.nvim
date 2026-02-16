# Neovim Configuration

A personalized Neovim configuration based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), tailored for Java and Go development with a focus on clean keybindings, git integration, and a minimal UI.

## Quick Install

One-liner that installs all dependencies and clones the config (supports **macOS** and **CentOS/RHEL**):

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/advpetc/kickstart.nvim/master/install.sh)"
```

This will:
- Install Neovim (latest stable)
- Install system tools (`git`, `make`, `gcc`, `ripgrep`, `fd`, `gh`)
- Install Node.js, Go, and JDK 21 (interactive prompt for JDK method)
- Install JetBrainsMono Nerd Font
- Clone this config to `~/.config/nvim/` (backs up any existing config)
- Install all plugins, LSP servers, and Treesitter parsers

After installation, run `:checkhealth` inside Neovim to verify everything is working.

### Manual Install

If you prefer to install dependencies yourself:

```sh
# 1. Clone the config
git clone https://github.com/advpetc/kickstart.nvim.git ~/.config/nvim

# 2. Install dependencies (macOS example)
brew install neovim ripgrep fd gh node go
brew install --cask font-jetbrains-mono-nerd-font

# 3. Open Neovim — plugins install automatically
nvim
```

<details><summary>CentOS / RHEL</summary>

```sh
# Neovim (from GitHub release — repos have outdated versions)
curl -fsSL https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tar.gz
sudo mkdir -p /opt/nvim && sudo tar -xzf /tmp/nvim.tar.gz -C /opt/nvim --strip-components=1
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

# System tools
sudo dnf install -y git make gcc gcc-c++ unzip curl ripgrep fd-find nodejs
```

</details>

## Plugins

| Plugin | Purpose |
|--------|---------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Completion (LSP, snippets, paths) |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) + [mason.nvim](https://github.com/mason-org/mason.nvim) | LSP management and auto-install |
| [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) | Java LSP (Eclipse JDT LS) |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) + [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | Debug adapter protocol |
| [nvim-dap-go](https://github.com/leoluz/nvim-dap-go) | Go debugging (delve) |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File explorer |
| [mini.nvim](https://github.com/echasnovski/mini.nvim) | Statusline, surround, AI text objects, sessions |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git signs, hunk operations, inline blame |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | Git diff viewer |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatting (stylua for Lua) |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | Linting (markdownlint) |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding hints |
| [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Color scheme (tokyonight-night) |
| [guess-indent.nvim](https://github.com/NMAC427/guess-indent.nvim) | Auto-detect indentation |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-pair brackets |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | Indentation guides |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight TODO/FIXME/NOTE |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine |
| [fidget.nvim](https://github.com/j-hui/fidget.nvim) | LSP progress notifications |

## Keymaps

Leader key is `<Space>`.

### Search (`<leader>s`)

| Keymap | Action |
|--------|--------|
| `<leader>sf` | Search files |
| `<leader>sg` | Search by grep (live) |
| `<leader>sw` | Search current word |
| `<leader>sh` | Search help |
| `<leader>sk` | Search keymaps |
| `<leader>sc` | Search commands |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Search resume |
| `<leader>s.` | Search recent files |
| `<leader>sn` | Search Neovim config files |
| `<leader>s/` | Search in open files |
| `<leader>/` | Fuzzy search in current buffer |
| `<leader><leader>` | Find open buffers |

### Git (`<leader>g`, `<leader>h`)

| Keymap | Action |
|--------|--------|
| `<leader>gd` | Open diff view |
| `<leader>gh` | File history |
| `<leader>gH` | Branch history |
| `<leader>gc` | Close diff view |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hu` | Undo stage hunk |
| `<leader>hR` | Reset buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff against index |
| `<leader>tb` | Toggle inline blame |
| `]c` / `[c` | Next/prev git change |

### LSP

| Keymap | Action |
|--------|--------|
| `grd` | Go to definition |
| `gri` | Go to implementation |
| `grr` | Go to references |
| `grt` | Go to type definition |
| `grD` | Go to declaration |
| `grn` | Rename symbol |
| `gra` | Code action |
| `gO` | Document symbols |
| `gW` | Workspace symbols |
| `<leader>th` | Toggle inlay hints |

### Java (`<leader>j`)

| Keymap | Action |
|--------|--------|
| `<leader>jo` | Organize imports |
| `<leader>jv` | Extract variable |
| `<leader>jm` | Extract method (visual) |
| `<leader>jx` | Clear jdtls cache |

### Debug (`<leader>d`)

| Keymap | Action |
|--------|--------|
| `<leader>dc` | Continue / Start |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dl` | Log point |
| `<leader>dr` | Open REPL |
| `<leader>du` | Toggle debug UI |
| `<leader>dt` | Test nearest method (Java) |
| `<leader>dT` | Test class (Java) |
| `<leader>dx` | Terminate |

### Session (`<leader>q`)

| Keymap | Action |
|--------|--------|
| `<leader>qs` | Save session |
| `<leader>qr` | Restore session |
| `<leader>qd` | Delete session |

### Other

| Keymap | Action |
|--------|--------|
| `<leader>f` | Format buffer |
| `<leader>cp` | Copy relative file path |
| `<leader>cP` | Copy absolute file path |
| `<leader>cl` | Copy GitHub permalink |
| `\` | Toggle file explorer |

## LSP Servers

| Server | Language | Installed via |
|--------|----------|---------------|
| `lua_ls` | Lua | Mason |
| `jdtls` | Java | Mason + nvim-jdtls |

### Mason-Managed Tools

| Tool | Type |
|------|------|
| `stylua` | Formatter (Lua) |
| `java-debug-adapter` | DAP |
| `java-test` | DAP |
| `delve` | DAP (Go) |

## Statusline

Layout: `Mode │ git │ filename │ filetype encoding │ line:col`

- Directory names are abbreviated to 2 characters (e.g., `~/Do/ts/src/main.java`)
- Modified buffers show `[+]`
- Nerd Font icons enabled

## Sessions

Sessions are stored in `~/.local/state/nvim/sessions/` via `mini.sessions`:

- Auto-saves on exit if a session is active
- Neo-tree buffers are automatically cleaned up on save/restore

## Java Setup

The Java configuration uses [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) with:

- **JDK 21** (Microsoft build) at `/Library/Java/JavaVirtualMachines/jdk21.0.6-msft.jdk/Contents/Home`
- **Gradle & Maven** import support with source downloading
- **DAP debugging** with hot code replace
- **Workspace**: `~/.local/share/nvim/jdtls-workspace/`

> Run `./gradlew build` before opening a project to generate required jars.
> Use `<leader>jx` (`:JdtlsClearCache`) to reset the jdtls workspace if things go wrong.

## File Structure

```
~/.config/nvim/
├── init.lua                        Main config (~1000 lines)
├── install.sh                      Dependency installer
├── lazy-lock.json                  Plugin lock file
├── .stylua.toml                    Lua formatter config
└── lua/
    ├── custom/plugins/
    │   ├── git.lua                 diffview.nvim
    │   └── java.lua                nvim-jdtls + Java DAP
    └── kickstart/
        ├── health.lua              Health check
        └── plugins/
            ├── autopairs.lua       nvim-autopairs
            ├── debug.lua           nvim-dap + dap-ui + dap-go
            ├── gitsigns.lua        Gitsigns keymaps
            ├── indent_line.lua     Indent guides
            ├── lint.lua            nvim-lint
            └── neo-tree.lua        File explorer
```

## Uninstall

```sh
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```
